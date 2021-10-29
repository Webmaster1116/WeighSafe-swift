//
//  Step6ViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/21/19.
//  Copyright © 2019 Lemonadestand Inc. All rights reserved.
//

import UIKit

class Step6ViewController: UIViewController, UIScrollViewDelegate {
    
    let persistenceManager: PersistenceManager
    let defaults = UserDefaults.standard
    var configurations = [Configuration]()
    var configuration: Configuration?
    var activeField: UITextField = UITextField()
    var keyboardHeight: CGFloat = 0.0

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var rearAxleToEndOfReceiverField: UITextField!
    @IBOutlet weak var towBallToEndOfSpringBarsField: UITextField!
    @IBOutlet weak var towBallToTrailerAxleField: UITextField!
    @IBOutlet weak var twField: UITextField!
    @IBOutlet weak var targetTWField: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        self.persistenceManager = PersistenceManager.shared
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        configurations = persistenceManager.fetch(Configuration.self) // GET VEHICLES STORED IN COREDATA
        flashScrollBar()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        twField.delegate = self
        targetTWField.isHidden = true
        
        rearAxleToEndOfReceiverField.delegate = self
        towBallToTrailerAxleField.delegate = self
        towBallToEndOfSpringBarsField.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.stackView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.scrollView.flashScrollIndicators()
    }
    
    private func flashScrollBar() {
        self.scrollView.flashScrollIndicators()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
            self?.flashScrollBar()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        configuration = self.configurations[defaults.integer(forKey: "currentConfigIndex")]
        
        if let field = twField.text, !field.isEmpty {
            configuration?.tongueWeight = NSDecimalNumber(string: twField.text)
        }
        if let field = rearAxleToEndOfReceiverField.text, !field.isEmpty {
            configuration?.rearAxleToEndOfReceiver = NSDecimalNumber(string: rearAxleToEndOfReceiverField.text)
        }
        if let field = towBallToEndOfSpringBarsField.text, !field.isEmpty {
            configuration?.towBallToEndOfSpringBars = NSDecimalNumber(string: towBallToEndOfSpringBarsField.text)
        }
        if let field = towBallToTrailerAxleField.text, !field.isEmpty {
            configuration?.towBallToTrailerAxle = NSDecimalNumber(string: towBallToTrailerAxleField.text)
        }
        
        persistenceManager.save()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    @IBAction func exitGuide(_ sender: UIButton) {
        
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
//        tabBarController.selectedIndex = 2
//        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = tabBarController
        //dismiss(animated: true, completion: nil)
        
        let pageViewController = self.parent as! InstructionsPageViewController
        pageViewController.goToPreviousPage()
        
    }
    
    @IBAction func nextPage(_ sender: UIButton) {
        let pageViewController = self.parent as! InstructionsPageViewController
        pageViewController.goToNextPage()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHeight = keyboardRectangle.height
            self.scrollView.scrollToView(view: self.activeField, keyboardHeight: keyboardRectangle.height, animated: true)
        }
    }

}

extension Step6ViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.activeField = textField
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        if(textField.tag == 2){
            
            if let field = textField.text, !field.isEmpty {
                
                let trailer = persistenceManager.fetch(Trailer.self)[defaults.integer(forKey: "currentTrailerIndex")]
                let trailerEmptyWeightValue = Double(truncating: trailer.emptyWeight!)
                
                configuration = self.configurations[defaults.integer(forKey: "currentConfigIndex")]
                let cargos = persistenceManager.fetch(Cargo.self)
                let cargoActive = defaults.array(forKey: "currentCargoIndexes")! as Array
                var trailerCargo: Double = 0
                for i in cargoActive {
                    if cargos[i as! Int].type != "Vehicle" {
                        trailerCargo += Double(truncating: cargos[i as! Int].cargoWeight!)
                    }
                }
                trailerCargo += Double(truncating: configuration!.additionalTrailerWeight!)
                
                if trailerCargo < 0 {
                    trailerCargo = 0
                }
                
                let gtw = (trailerEmptyWeightValue - Double(truncating: trailer.loadCapacity!)) + trailerCargo
                let lowerRange = gtw * 0.10
                let upperRange = gtw * 0.15
                
                if let field = textField.text, !field.isEmpty {
                    let tongueWeight = Double(truncating: NSDecimalNumber(string: field))
                    
                    if(tongueWeight >= lowerRange && tongueWeight <= upperRange){
                        
                        self.targetTWField.isHidden = true
                        
                    } else {
                        
                        self.targetTWField.isHidden = false
                        self.targetTWField.text = "Your tongue weight should be between \(lowerRange.rounded()) lbs and \(upperRange.rounded()) lbs to ensure a safe tow"
                        
                    }
                    
                }
                
            }
            
        }
        
        if textField.tag == 3 {
            
            if let field = textField.text, !field.isEmpty {
                let value = Double(truncating: NSDecimalNumber(string: field))
                if value < 0 || value > 70 {
                    
                    Toast.show(message: "Incorrect Rear Vehicle Axle Center-line to Tow Ball measurement. Should be between 0 and 70 inches.", controller: self)
                    
                }
            }
            
        }
        
        if textField.tag == 4 {
            
            if let field = textField.text, !field.isEmpty {
                let value = Double(truncating: NSDecimalNumber(string: field))
                if value < 24 || value > 32 {
                    
                    Toast.show(message: "Incorrect Tow Ball to Spring Bar Connection measurement. Should be between 24 and 32 inches.", controller: self)
                    
                }
            }
            
        }
        
    }
    
}
