//
//  Step3ViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/21/19.
//  Copyright © 2019 Lemonadestand Inc. All rights reserved.
//

import UIKit

class Step3ViewController: UIViewController, UIScrollViewDelegate {
    
    let persistenceManager: PersistenceManager
    let defaults = UserDefaults.standard
    var configurations = [Configuration]()
    var configuration: Configuration?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var drawbarPositionControl: UISegmentedControl!
    @IBOutlet weak var stepperControl: UIStepper!
    @IBOutlet weak var visibleHolesField: UITextField!
    
    required init?(coder aDecoder: NSCoder) {
        self.persistenceManager = PersistenceManager.shared
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        configurations = persistenceManager.fetch(Configuration.self) // GET VEHICLES STORED IN COREDATA
        configuration = configurations[defaults.integer(forKey: "currentConfigIndex")]
        flashScrollBar()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        drawbarPositionControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        drawbarPositionControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
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
    
    override func viewDidDisappear(_ animated: Bool) {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    @IBAction func drawbarPositionPress(_ sender: UISegmentedControl) {
        configuration!.drawbarPosition = sender.selectedSegmentIndex as NSNumber
        
        persistenceManager.save()
    }
    
    @IBAction func stepperPress(_ sender: UIStepper) {
        if(sender.value == -0.5){
            self.visibleHolesField.text = "0 Holes"
        }else{
            self.visibleHolesField.text = "\(sender.value) Hole\(sender.value == 1 ? "" : "s")"
        }
        
        configuration!.holesVisible = NSDecimalNumber(string: String(sender.value))
        
        persistenceManager.save()
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
}
