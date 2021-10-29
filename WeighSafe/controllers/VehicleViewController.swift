//
//  VehicleViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/18/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import UIKit
import SCLAlertView

class VehicleViewController: UIViewController {
    
    let persistenceManager = PersistenceManager.shared
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    var vehicles: [Vehicle] = [Vehicle]()
    var vehicle: Vehicle?
    var vehicleIndex = -1
    var keyboardHeight: CGFloat = 0.0
    var bottomSafeArea: CGFloat = 0.0
    var textFieldActive = UITextField()
    var infoButtonActive = 0
    let infoButtons: [[String:String]] = [
        ["title" : "Gross Vehicle Weight Rating", "description" : "The maximum amount of weight that your vehicle can handle safely specified by the vehicle manufacturer. It includes the vehicle's chassis, body, engine, fuel, accessories, driver, passengers, and cargo in the vehicle.", "image" : "TruckGVWR"],
        ["title" : "Gross Combined Weight Rating", "description" : "Gross Vehicle Weight + Weight of trailer and cargo.", "image" : "TruckTowVehicleGCW"],
        ["title" : "Max Cargo Capacity", "description" : "The combination weight of occupants and cargo.", "image" : "TruckTowVehicleLoading"],
        ["title" : "Type of Towing Receivers", "description" : "", "image" : "type-of-towing-receivers"]
    ]
    var vin: String = ""
    weak var delegate: DataTransit? = nil
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var customTitle: UINavigationItem!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var vinLookup: UIButton!
    @IBOutlet weak var gvwrField: UITextField!
    @IBOutlet weak var gcwrField: UITextField!
    @IBOutlet weak var mccField: UITextField!
    @IBOutlet weak var bumperMaxWeightRating: UITextField!
    @IBOutlet weak var bumperMaxTongueWeightRating: UITextField!
    
    @IBOutlet weak var distributedWeightRatingControl: UISegmentedControl!
    @IBOutlet weak var distributedGTWView: UIView!
    @IBOutlet weak var distributedTWView: UIView!
    
    @IBOutlet weak var bumperDistributedWeightRating: UITextField!
    @IBOutlet weak var bumperDistributedTongueWeightRating: UITextField!
    
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var bumperRatingView: UIView!
    
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    @IBAction func saveButtonPress(_ sender: UIBarButtonItem) {
        
        do {
            
            if let vehicle = vehicle {
            
                vehicle.name = nameField.text
                
                if vehicleIndex == -1 && nameField.text!.isEmpty {
                    vehicle.name = "Vehicle #\(self.vehicles.count + 1)"
                }
                
                let gvwr = try gvwrField.validatedText(validationType: .requiredField(field: "Gross Vehicle Weight Rating"))
                vehicle.gvwr = NSDecimalNumber(string: gvwr)
                
                let gcwr = try gcwrField.validatedText(validationType: .requiredField(field: "Gross Combined Weight Rating"))
                vehicle.gcwr = NSDecimalNumber(string: gcwr)
            
                let mcc = try mccField.validatedText(validationType: .requiredField(field: "Max Cargo Capacity"))
                vehicle.mcc = NSDecimalNumber(string: mcc)
            
                vehicle.haveDistributedRatings = NSNumber(value: distributedWeightRatingControl.selectedSegmentIndex)
                
                let bmwr = try bumperMaxWeightRating.validatedText(validationType: .requiredField(field: "Max Gross Trailer Weight"))
                vehicle.maxBumperWeightRating = NSDecimalNumber(string: bmwr)
                
//                if let field = bumperMaxWeightRating.text {
//                    let value = NSDecimalNumber(string: field)
//                    vehicle.maxBumperWeightRating = field.isEmpty ? 0 : value
//                }
                
                let bmtwr = try bumperMaxTongueWeightRating.validatedText(validationType: .requiredField(field: "Max Tongue Weight"))
                vehicle.maxBumperTongueWeightRating = NSDecimalNumber(string: bmtwr)
                
//                if let field = bumperMaxTongueWeightRating.text {
//                    let value = NSDecimalNumber(string: field)
//                    vehicle.maxBumperTongueWeightRating = field.isEmpty ? 0 : value
//                }
            
                if let field = bumperDistributedWeightRating.text {
                    let value = NSDecimalNumber(string: field)
                    vehicle.maxDistributedWeightRating = field.isEmpty ? 0 : value
                }
                
                if let field = bumperDistributedTongueWeightRating.text {
                    let value = NSDecimalNumber(string: field)
                    vehicle.maxDistributedTongueWeightRating = field.isEmpty ? 0 : value
                }
                
                persistenceManager.save()
                delegate?.event(type: "update", data: vehicle)
                dismiss(animated: true){
                    self.vehicleIndex = -1
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
    
    @IBAction func vinLookup(_ sender: UIButton) {
        
        let vc = VinLookupTableViewController.loadFromNib()
        vc.delegate = self
        present(vc, animated: true, completion: nil)
        
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
        
        bumperRatingView.isHidden = false
        distributedGTWView.isHidden = true
        distributedTWView.isHidden = true
        
        bumperMaxWeightRating.delegate = self
        bumperDistributedWeightRating.delegate = self
        gvwrField.delegate = self
        mccField.delegate = self
        gcwrField.delegate = self
        
        distributedWeightRatingControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: "#AB1E23".hexColor, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 13)!], for: .selected)
        
        vinLookup.setAttributedTitle(NSAttributedString(string: "VIN LOOKUP", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 12)!]), for: .normal)
        vinLookup.backgroundColor = .darkGray
        vinLookup.tintColor = .white
        vinLookup.layer.cornerRadius = 0.5 * vinLookup.bounds.size.height
        
        self.vehicles = self.persistenceManager.fetch(Vehicle.self)
        
        if vehicleIndex == -1 {
        
            vehicle = Vehicle(context: persistenceManager.context)
            
            deleteView.isHidden = true
            
        }
        
        if vehicleIndex != -1 {
            
            deleteView.isHidden = false
            
            vehicle = vehicles[vehicleIndex]
            
            customTitle.title = "Edit Vehicle"
            
            if let editVehicle = vehicle {
                nameField.text = editVehicle.name
                gvwrField.text = String(describing: editVehicle.gvwr!)
                gcwrField.text = String(describing: editVehicle.gcwr!)
                mccField.text = String(describing: editVehicle.mcc!)
                
                distributedWeightRatingControl.selectedSegmentIndex = editVehicle.haveDistributedRatings as! Int
                
                bumperMaxWeightRating.text = editVehicle.maxBumperWeightRating == 0 ? "" : String(describing: editVehicle.maxBumperWeightRating!)
                bumperMaxTongueWeightRating.text = editVehicle.maxBumperTongueWeightRating == 0 ? "" : String(describing: editVehicle.maxBumperTongueWeightRating!)
                
                bumperDistributedWeightRating.text = editVehicle.maxDistributedWeightRating == 0 ? "" : String(describing: editVehicle.maxDistributedWeightRating!)
                bumperDistributedTongueWeightRating.text = editVehicle.maxDistributedTongueWeightRating == 0 ? "" : String(describing: editVehicle.maxDistributedTongueWeightRating!)
                
                if editVehicle.haveDistributedRatings as! Int == 0 {
                    distributedGTWView.isHidden = true
                    distributedTWView.isHidden = true
                } else {
                    distributedGTWView.isHidden = false
                    distributedTWView.isHidden = false
                }
                
                if editVehicle.vin != nil {
                    gvwrField.isEnabled = false
                    gcwrField.isEnabled = false
                    mccField.isEnabled = false
                }
            }
        }
    }
    
    @IBAction func distributedWeightRatingChange(_ sender: UISegmentedControl) {
        distributedGTWView.isHidden = !distributedGTWView.isHidden
        distributedTWView.isHidden = !distributedTWView.isHidden
        
        if !distributedTWView.isHidden {
            scrollView.setContentOffset(CGPoint(x:0, y:distributedTWView.frame.origin.y), animated: true)
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
            
            self.persistenceManager.delete(self.vehicles[self.vehicleIndex])
            
            let currentIndex = self.defaults.integer(forKey: "currentVehicleIndex")
            if self.vehicleIndex == currentIndex && currentIndex > 0 {
                self.defaults.set(currentIndex - 1, forKey: "currentVehicleIndex")
            }
            
            self.delegate?.event(type: "delete", data: self.vehicleIndex)
            self.dismiss(animated: true){
                self.vehicleIndex = -1
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

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 60, height: 350))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: infoButtons[sender.tag]["image"]!)

        alert.customSubview = imageView

        alert.showCustom(infoButtons[sender.tag]["title"]!, subTitle: infoButtons[sender.tag]["description"]!, color: "#AB1E23".hexColor, icon: UIImage())
        
    }

}

extension VehicleViewController: DataTransit {
    func event(type: String, data: Any) {
        
        let convertedData = (data as! Dictionary<String, String>)
        
        if nameField.text != nil {
            nameField.text = convertedData["year"]! + " " + convertedData["make"]! + " " + convertedData["model"]!
        }
        gvwrField.isEnabled = false
        gvwrField.text = convertedData["Gross_Vehicle_Weight_Rating"]!
        gcwrField.isEnabled = false
        gcwrField.text = convertedData["Gross_Combined_Weight_Rating"]!
        mccField.isEnabled = false
        mccField.text = convertedData["Max_Payload"]!
        
        if let vehicle = vehicle {
            vehicle.vin = convertedData["vin"]!
            vehicle.year = convertedData["year"]!
            vehicle.make = convertedData["make"]!
            vehicle.model = convertedData["model"]!
        }
        
    }
}

extension VehicleViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 5 {
            if let text = bumperMaxWeightRating.text, !text.isEmpty {
                let maxTongueRating = Double(text)! * 0.1
                bumperMaxTongueWeightRating.text = String(describing: Int(maxTongueRating))
            }
        }
        if textField.tag == 7 {
            if let text = bumperDistributedWeightRating.text, !text.isEmpty {
                let maxDistributedTongueRating = Double(text)! * 0.1
                bumperDistributedTongueWeightRating.text = String(describing: Int(maxDistributedTongueRating))
            }
        }
        
        do {
            
            if textField.tag == 2 {
                if let value = Int(textField.text ?? "0") {
                    let mccValue = mccField.text != nil && mccField.text != "" ? Int(mccField.text!) : 0
                    if value < mccValue! {
                        throw ValidationError("Warning: GVWR can't be less than Max Cargo Capacity")
                    }
                }
            }
            if textField.tag == 3 {
                if let value = Int(textField.text ?? "0") {
                    let gvwrValue = gvwrField.text != nil && gvwrField.text != "" ? Int(gvwrField.text!) : 0
                    if value > gvwrValue! {
                        throw ValidationError("Warning: Max Cargo Capacity can't be greater than GVWR")
                    }
                }
            }
            if textField.tag == 4 {
                if let value = Int(textField.text ?? "0") {
                    let gvwrValue = gvwrField.text != nil && gvwrField.text != "" ? Int(gvwrField.text!) : 0
                    if value < gvwrValue! {
                        throw ValidationError("Warning: GCWR can't be less than GVWR")
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
