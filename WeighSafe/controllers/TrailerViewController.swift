//
//  TrailerViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/18/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import UIKit
import SCLAlertView

class TrailerViewController: UIViewController {
    
    let persistenceManager = PersistenceManager.shared
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    var hitches: [Hitch] = [Hitch]()
    var trailers: [Trailer] = [Trailer]()
    var trailer: Trailer?
    var trailerIndex = -1
    var keyboardHeight: CGFloat = 0.0
    var bottomSafeArea: CGFloat = 0.0
    var textFieldActive = UITextField()
    var infoButtonActive = 0
    let infoButtons: [[String:String]] = [
        ["title" : "Gross Trailer Weight Rating", "image" : "TrailerGVWR-"],
        ["title" : "Max Cargo Capacity", "image" : "TrailerLoading-"],
        ["title" : "Dry Boat Weight", "image" : "TruckTowBoatWeight"]
    ]
    weak var delegate: DataTransit? = nil
    @IBOutlet weak var couplerSegmentedControl: UISegmentedControl!
    var couplerOptions: [String] = [
        "2 5/16\"",
        "2\"",
        "1 7/8\""
    ]
    
    var typeOptions: [[String:String]] = [
        ["name" : "Boat Trailer", "value" : "boat"],
        ["name" : "Enclosed Trailer", "value" : "cargo"],
        ["name" : "Open Bed Trailer", "value" : "flat"],
        ["name" : "Horse Trailer", "value" : "horse"],
        ["name" : "RV Trailer", "value" : "rv"]
    ]
    let typePicker: UIPickerView = UIPickerView()
    
    @IBOutlet weak var customTitle: UINavigationItem!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var emptyWeightField: UITextField!
    @IBOutlet weak var cargoWeightView: UIView!
    @IBOutlet weak var cargoWeight: UITextField!
    @IBOutlet weak var loadCapacityField: UITextField!
    @IBOutlet weak var deleteView: UIView!
    
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var couplerView: UIView!
    
    @IBAction func saveButtonPress(_ sender: UIBarButtonItem) {
        
        do {
            
            if let trailer = trailer {
            
                trailer.name = nameField.text
                if let index = typeOptions.firstIndex(where: { $0["name"]! == typeField.text }) {
                    trailer.type = typeOptions[index]["value"]
                }
                
                if trailerIndex == -1 && nameField.text!.isEmpty {
                    trailer.name = "Trailer #\(self.trailers.count + 1)"
                }
                
                let emptyWeight = try emptyWeightField.validatedText(validationType: .requiredField(field: "Empty Weight"))
                trailer.emptyWeight = NSDecimalNumber(string: emptyWeight)
                
                if !cargoWeightView.isHidden {
                let cargoWeightField = try cargoWeight.validatedText(validationType: .requiredField(field: "Empty Weight"))
                trailer.cargoWeight = NSDecimalNumber(string: cargoWeightField)
                }
                
                let loadCapacity = try loadCapacityField.validatedText(validationType: .requiredField(field: "Load Capacity"))
                trailer.loadCapacity = NSDecimalNumber(string: loadCapacity)
                
                trailer.coupler = couplerOptions[couplerSegmentedControl.selectedSegmentIndex]
                
                persistenceManager.save()
                delegate?.event(type: "update", data: trailer)
                dismiss(animated: true){
                    self.trailerIndex = -1
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
        
        cargoWeightView.isHidden = true
        
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
        
        couplerSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: "#AB1E23".hexColor, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 13)!], for: .selected)

        self.trailers = self.persistenceManager.fetch(Trailer.self)
        self.hitches = self.persistenceManager.fetch(Hitch.self)
        
        typePicker.delegate = self
        typePicker.tag = 0
        typeField.inputView = typePicker
        
        emptyWeightField.delegate = self
        loadCapacityField.delegate = self
        
        couplerView.isHidden = false
        if self.hitches.indices.contains(defaults.integer(forKey: "currentHitchIndex")) {
            let hitch = hitches[defaults.integer(forKey: "currentHitchIndex")]
            if hitch.type == "Gooseneck" || hitch.type == "Fifth Wheel" {
                couplerView.isHidden = true
            }
        }
        
        if trailerIndex == -1 {
        
            trailer = Trailer(context: persistenceManager.context)
            
            deleteView.isHidden = true
            
        }
        
        if trailerIndex != -1 {
            
            deleteView.isHidden = false
            
            trailer = trailers[trailerIndex]
            
            customTitle.title = "Edit Trailer"
            
            if let editTrailer = trailer {
            
                nameField.text = editTrailer.name
                if let index = typeOptions.firstIndex(where: { $0["value"]! == editTrailer.type }) {
                    typeField.text = typeOptions[index]["name"]
                    typePicker.selectRow(index, inComponent: 0, animated: true)
                }
                if editTrailer.type == "boat" {
                    cargoWeightView.isHidden = false
                }
                cargoWeight.text = String(describing: editTrailer.cargoWeight!)
                emptyWeightField.text = String(describing: editTrailer.emptyWeight!)
                loadCapacityField.text = String(describing: editTrailer.loadCapacity!)
                if let couplerIndex = couplerOptions.firstIndex(of: editTrailer.coupler!) {
                    couplerSegmentedControl.selectedSegmentIndex = couplerIndex
                }
                
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
        
        if let firstResponder = self.findFirstResponder(inView: self.view){
            if firstResponder.tag == 2 && trailerIndex == -1 {
                  
                (firstResponder as! UITextField).text = typeOptions[typePicker.selectedRow(inComponent: 0)]["name"]
                
                if typeOptions[typePicker.selectedRow(inComponent: 0)]["value"] == "boat" {
                    cargoWeightView.isHidden = false
                }
                  
            }
        }
        
    }
    
    func findFirstResponder(inView view: UIView) -> UIView? {
        for subView in view.subviews {
            if subView.isFirstResponder {
                return subView
            }
            
            if let recursiveSubView = self.findFirstResponder(inView: subView) {
                return recursiveSubView
            }
        }
        
        return nil
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        scrollViewBottom.constant = 0
        
    }
    
    @IBAction func deleteButtonPress(_ sender: UIButton) {
        
        let alertView = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alertView.addButton("DELETE"){
            
            self.persistenceManager.delete(self.trailers[self.trailerIndex])
            
            let currentIndex = self.defaults.integer(forKey: "currentTrailerIndex")
            if self.trailerIndex == currentIndex && currentIndex > 0 {
                self.defaults.set(currentIndex - 1, forKey: "currentTrailerIndex")
            }
            
            self.delegate?.event(type: "delete", data: self.trailerIndex)
            self.dismiss(animated: true){
                self.trailerIndex = -1
            }
            
        }
        alertView.addButton("CANCEL", backgroundColor: "#eeeeee".hexColor) {
            alertView.hideView()
        }
        alertView.showWarning("Are you sure?", subTitle: "")
        
    }
    
    @IBAction func infoButtonPress(_ sender: UIButton) {
        
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
            showCircularIcon: false,
            shouldAutoDismiss: false,
            buttonsLayout: .horizontal
        )

        let alert = SCLAlertView(appearance: appearance)
        
        alert.addButton("CLOSE") {
            alert.hideView()
        }

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 60, height: 400))
        imageView.contentMode = .scaleAspectFit
        var imageName = infoButtons[sender.tag]["image"]!
        
        if sender.tag == 0 || sender.tag == 1 {
//            if self.hitches.indices.contains(defaults.integer(forKey: "currentHitchIndex")) {
//                            let hitch = hitches[defaults.integer(forKey: "currentHitchIndex")]
//                if hitch.type == "Gooseneck" {
//                    imageName += "Gooseneck"
//                }
//                if hitch.type == "Fifth Wheel" {
//                    imageName += "FifthWheel"
//                }
//            }
            
            if let selected = typeOptions[typePicker.selectedRow(inComponent: 0)]["value"] {
                imageName += selected
            } else {
                imageName += "rv"
            }
        }
        
        imageView.image = UIImage(named: imageName)

        alert.customSubview = imageView

        alert.showCustom(infoButtons[sender.tag]["title"]!, subTitle: "", color: "#AB1E23".hexColor, icon: UIImage())
        
    }

}

extension TrailerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 0){
            return typeOptions.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        if pickerView.tag == 0 {
            label.text = self.typeOptions[row]["name"]
        }
        label.textAlignment = .center
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 0 {
            
            typeField.text = typeOptions[row]["name"]
            
            if typeOptions[row]["value"] == "boat" {
                cargoWeightView.isHidden = false
            } else {
                cargoWeightView.isHidden = true
            }
            
        }
    }
    
}

extension TrailerViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        do {
        
            if textField.tag == 4 {
                if let value = Int(textField.text ?? "0") {
                    let mccValue = loadCapacityField.text != nil && loadCapacityField.text != "" ? Int(loadCapacityField.text!) : 0
                    if value < mccValue! {
                        throw ValidationError("Warning: GVWR can't be less than Max Cargo Capacity")
                    }
                }
            }
            if textField.tag == 5 {
                if let value = Int(textField.text ?? "0") {
                    let gvwrValue = emptyWeightField.text != nil && emptyWeightField.text != "" ? Int(emptyWeightField.text!) : 0
                    if value > gvwrValue! {
                        throw ValidationError("Warning: Max Cargo Capacity can't be greater than GVWR")
                    }
                }
            }
            
        } catch(let error) {
    
            textField.text = ""
            
            textField.becomeFirstResponder()
            
            let alert = UIAlertController(title: "Invalid User Input", message: (error as! ValidationError).message, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))

            self.present(alert, animated: true)
            
        }
        
    }
}
