//
//  CargoViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/20/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import UIKit
import SCLAlertView

class CargoViewController: UIViewController {
    
    let persistenceManager = PersistenceManager.shared
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    var cargos: [Cargo] = [Cargo]()
    var cargo: Cargo?
    var cargoIndex = -1
    var keyboardHeight: CGFloat = 0.0
    var bottomSafeArea: CGFloat = 0.0
    var textFieldActive = UITextField()
    var infoButtonActive = 0
    weak var delegate: DataTransit? = nil
    var typeOptions: [String] = [
        "Vehicle",
        "Trailer"
    ]
    
    @IBOutlet weak var customTitle: UINavigationItem!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var typeField: UISegmentedControl!
    @IBOutlet weak var deleteView: UIView!
    
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!

    @IBAction func saveButtonPress(_ sender: UIBarButtonItem) {
        do {
            
            if let cargo = cargo {
            
                cargo.name = nameField.text
                
                let weight = try weightField.validatedText(validationType: .requiredField(field: "Weight of Cargo"))
                cargo.cargoWeight = NSDecimalNumber(string: weight)
                
                cargo.type = typeOptions[typeField.selectedSegmentIndex]
                
                if self.cargoIndex == -1 {
                    var cargoActive = defaults.array(forKey: "currentCargoIndexes")! as Array
                    cargoActive.append(self.cargos.count)
                    defaults.set(cargoActive, forKey: "currentCargoIndexes")
                    
                    var nsarray = [NSNumber]()
                    for i in cargoActive {
                        nsarray.append(i as! NSNumber)
                    }
                    let configurations = persistenceManager.fetch(Configuration.self)
                    let configuration = configurations[defaults.integer(forKey: "currentConfigIndex")]
                    configuration.cargo = nsarray
                }
                
                persistenceManager.save()
                
                delegate?.event(type: "update", data: cargo)
                
                dismiss(animated: true){
                    self.cargoIndex = -1
                }
                
            }
            
        } catch(let error) {
    
            let appearance = SCLAlertView.SCLAppearance(
                kCircleHeight: 0,
                kWindowWidth: view.frame.size.width - 40,
                kTextHeight: 65,
                kTextFieldHeight: 65,
                kTextViewdHeight: 65,
                kTitleFont: UIFont(name: "Roboto-Bold", size: 20)!,
                kTextFont: UIFont(name: "Roboto-Medium", size: 14)!,
                kButtonFont: UIFont(name: "Roboto-Bold", size: 14)!,
                showCloseButton: false,
                showCircularIcon: true,
                shouldAutoDismiss: false
            )

            let alert = SCLAlertView(appearance: appearance)
            alert.iconTintColor = "#AB1E23".hexColor
            alert.addButton("OK", backgroundColor: "#AB1E23".hexColor, textColor: .white) {
                alert.hideView()
            }
            alert.showWarning("Required Field", subTitle: (error as! ValidationError).message)
            
        }
    }
    
    @IBAction func closeButtonPress(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        typeField.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: "#AB1E23".hexColor, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 13)!], for: .selected)

        self.cargos = self.persistenceManager.fetch(Cargo.self)
        
        if cargoIndex == -1 {
        
            cargo = Cargo(context: persistenceManager.context)
            deleteView.isHidden = true
            
        }
        
        if cargoIndex != -1 {
            
            deleteView.isHidden = false
            
            cargo = cargos[cargoIndex]
            
            customTitle.title = "Edit Cargo"
            
            if let editCargo = cargo {
            
                nameField.text = editCargo.name
            
                weightField.text = String(describing: editCargo.cargoWeight!)
                
                typeField.selectedSegmentIndex = editCargo.type == "Vehicle" ? 0 : 1
                
            }
            
        }
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHeight = keyboardRectangle.height
            
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.windows[0]
                let safeFrame = window.safeAreaLayoutGuide.layoutFrame
                self.bottomSafeArea = window.frame.maxY - safeFrame.maxY
            }
            
            scrollViewBottom.constant = -(keyboardHeight - self.bottomSafeArea - 5)
        }
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        scrollViewBottom.constant = 0
        
    }
    
    @IBAction func deleteButtonPress(_ sender: UIButton) {
        
        let alertView = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alertView.addButton("DELETE"){
            
            self.persistenceManager.delete(self.cargos[self.cargoIndex])
            
            var cargoActive = self.defaults.array(forKey: "currentCargoIndexes")! as Array
            
            if let index = cargoActive.firstIndex(where: { $0 as! Int == self.cargoIndex }) {
                cargoActive.remove(at: index)
            }

            self.defaults.set(cargoActive, forKey: "currentCargoIndexes")
            
            self.delegate?.event(type: "delete", data: self.cargoIndex)
            self.dismiss(animated: true){
                self.cargoIndex = -1
            }
            
        }
        alertView.addButton("CANCEL", backgroundColor: "#eeeeee".hexColor) {
            alertView.hideView()
        }
        alertView.showWarning("Are you sure?", subTitle: "")
        
    }
}
