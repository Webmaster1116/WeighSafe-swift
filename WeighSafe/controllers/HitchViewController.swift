//
//  HitchViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/20/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import UIKit
import SCLAlertView

class HitchViewController: UIViewController {
    
    let persistenceManager = PersistenceManager.shared
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    var hitches: [Hitch] = [Hitch]()
    var hitch: Hitch?
    var hitchIndex = -1
    var keyboardHeight: CGFloat = 0.0
    var bottomSafeArea: CGFloat = 0.0
    var textFieldActive = UITextField()
    var infoButtonActive = 0
    let infoButtons: [[String:String]] = [
        ["title" : "Hitch Type", "image" : "hitchTypes"],
        ["title" : "Max Gross Trailer Weight Rating", "image" : "hitchRatings"],
        ["title" : "Max Tongue Weight", "image" : "hitchRatings"]
    ]
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
        let imageName = infoButtons[sender.tag]["image"]!
        
        imageView.image = UIImage(named: imageName)

        alert.customSubview = imageView

        alert.showCustom(infoButtons[sender.tag]["title"]!, subTitle: "", color: "#AB1E23".hexColor, icon: UIImage())
    }
    
    weak var delegate: DataTransit? = nil
    
    var activeModel = 0
    var modelNames: [String] = [
        "Weigh Safe Drop Hitch",
        "Steel Weigh Safe Drop Hitch",
        "Weigh Safe 180 Hitch",
        "Universal Tow Ball",
        "Fixed Height Ball Mount",
        "True Tow Weight Distribution Hitch",
        "Safe Load OEM Gooseneck Ball",
        "Safe Load ISR Gooseneck",
        "Safe Load BW Insert Gooseneck"
    ]
    var modelOptions: [[String:Any]] = [
        [
            "name" : "Weigh Safe Drop Hitch",
            "type" : "Bumper Pull",
            "mgtwr" : [
                "ball" : [7500, 8000, 12500],
                "shank" : [0, 6000, 8500]
            ],
            "mtw" : [
                "shank" : [1500, 2200, 2200]
            ],
            "guide" : "https://www.weigh-safe.com/wp-content/uploads/2018/05/Weigh-Safe-Instruction-Sheet-2018.pdf"
        ],
        [
            "name" : "Steel Weigh Safe Drop Hitch",
            "type" : "Bumper Pull",
            "mgtwr" : [
                "ball" : [7500, 8000, 12500],
                "shank" : [0, 6000]
            ],
            "mtw" : [
                "shank" : [1500, 2200]
            ],
            "guide" : "https://www.weigh-safe.com/wp-content/uploads/2018/05/Weigh-Safe-Instruction-Sheet-2018.pdf"
        ],
        [
            "name" : "Weigh Safe 180 Hitch",
            "type" : "Bumper Pull",
            "mgtwr" : [
                "ball" : [7500, 8000, 12500],
                "shank" : [0, 6000, 8500]
            ],
            "mtw" : [
                "shank" : [1500, 2200, 2200]
            ],
            "guide" : "https://www.weigh-safe.com/wp-content/uploads/2018/05/180-Hitch-Instruction-2018.pdf"
        ],
        [
            "name" : "Universal Tow Ball",
            "type" : "Bumper Pull",
            "mgtwr" : 10000,
            "mtw" : 1500,
            "guide" : "https://www.weigh-safe.com/product/universal-tow-ball/"
        ],
        [
            "name" : "Fixed Height Ball Mount",
            "type" : "Bumper Pull",
            "mgtwr" : 10000,
            "mtw" : 1500,
            "guide" : "https://www.weigh-safe.com/product/fixed-height-ball-mount/"
        ],
        [
            "name" : "True Tow Weight Distribution Hitch",
            "type" : "Weight Distribution",
            "mgtwr" : [
                "shank" : [15000, 20000]
            ],
            "mtw" : [
                "shank" : [1500, 2000]
            ],
            "guide" : "https://www.weigh-safe.com/wp-content/uploads/2020/02/weigh-safe-safe-tow-manual-facing-pages-updated-2-13.pdf"
        ],
        [
            "name" : "Safe Load OEM Gooseneck Ball",
            "type" : "Gooseneck",
            "mgtwr" : 30000,
            "mtw" : 7500,
            "guide" : "https://www.weigh-safe.com/wp-content/uploads/2020/09/OEM-Instruction-Manual-1.pdf"
        ],
        [
            "name" : "Safe Load ISR Gooseneck",
            "type" : "Gooseneck",
            "mgtwr" : 30000,
            "mtw" : 7500,
            "guide" : "https://www.weigh-safe.com/wp-content/uploads/2020/07/ISR-GOOSENECK-MANUAL.pdf"
        ],
        [
            "name" : "Safe Load BW Insert Gooseneck",
            "type" : "Gooseneck",
            "mgtwr" : 30000,
            "mtw" : 7500,
            "guide" : ""
        ]
    ]
    let modelPicker: UIPickerView = UIPickerView()
    
    var typeOptions: [String] = [
        "Bumper Pull",
        "Weight Distribution",
        "Gooseneck",
        "Fifth Wheel"
    ]
    let typePicker: UIPickerView = UIPickerView()
    
    
    @IBOutlet weak var ballSizeSegmentedControl: UISegmentedControl!
    var ballSizeOptions: [String] = [
        "2 5/16\"",
        "2\"",
        "1 7/8\""
    ]
    
    @IBOutlet weak var shankSizeSegmentedControl: UISegmentedControl!
    var shankSizeOptions: [String] = [
        "2\"",
        "2.5\"",
        "3\""
    ]
    
    @IBOutlet weak var customTitle: UINavigationItem!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var modelField: UITextField!
    @IBOutlet weak var gtwrField: UITextField!
    @IBOutlet weak var tongueWeightField: UITextField!
    @IBOutlet weak var brandField: UITextField!
    @IBOutlet weak var wsSwitch: UISwitch!
    @IBOutlet weak var wsLink: UIButton!
    @IBOutlet weak var deleteView: UIView!
    
    @IBOutlet var weighSafeViews: [UIView]!
    @IBOutlet var nonWeighSafeViews: [UIView]!
    @IBOutlet weak var ballSizeView: UIView!
    @IBOutlet weak var shankSizeView: UIView!
    @IBOutlet weak var hitchExtras: UIView!
    
    @IBAction func guideButtonPress(_ sender: UIButton) {
        if let url = URL(string: modelOptions[activeModel]["guide"] as! String) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    @IBAction func saveButtonPress(_ sender: UIBarButtonItem) {
        do {
            
            if let hitch = hitch {
            
                hitch.type = typeField.text
                hitch.brand = brandField.text
                
                if wsSwitch.isOn {
                    
                    if ( modelOptions[activeModel]["mgtwr"] is Int) {
                        
                        let mgtwr = modelOptions[activeModel]["mgtwr"] as! Int
                        hitch.maxGTWR = NSDecimalNumber(value: mgtwr)
                        
                    } else {
                        
                        if modelOptions[activeModel]["type"] as? String == "Weight Distribution" {
                            
                            let mgtwr = modelOptions[activeModel]["mgtwr"] as AnyObject
                            let shankWeight = (mgtwr["shank"] as! Array<Int>)[shankSizeSegmentedControl.selectedSegmentIndex]
                            hitch.maxGTWR = NSDecimalNumber(value: shankWeight)
                            
                        } else {
                            
                            let mgtwr = modelOptions[activeModel]["mgtwr"] as AnyObject
                            let ballWeight = (mgtwr["ball"] as! Array<Int>)[ballSizeSegmentedControl.selectedSegmentIndex]
                            let shankWeight = ballSizeSegmentedControl.selectedSegmentIndex == 2 ? (mgtwr["shank"] as! Array<Int>)[shankSizeSegmentedControl.selectedSegmentIndex] : 0
                            hitch.maxGTWR = NSDecimalNumber(value: (ballWeight + shankWeight))
                            
                        }
                        
                    }
                    
                    if ( modelOptions[activeModel]["mtw"] is Int) {
                        
                        let mtw = modelOptions[activeModel]["mtw"] as! Int
                        hitch.maxTongueWeight = NSDecimalNumber(value: mtw)
                        
                    } else {
                        
                        let mtw = modelOptions[activeModel]["mtw"] as AnyObject
                        let shankWeight = (mtw["shank"] as! Array<Int>)[shankSizeSegmentedControl.selectedSegmentIndex]
                        hitch.maxTongueWeight = NSDecimalNumber(value: shankWeight)
                        
                    }
                    
                    hitch.brand = modelOptions[activeModel]["name"] as? String
                    hitch.type = modelOptions[activeModel]["type"] as? String
                    
                } else {
                    let gtwr = try gtwrField.validatedText(validationType: .requiredField(field: "Max Gross Trailer Weight Rating"))
                    hitch.maxGTWR = NSDecimalNumber(string: gtwr)
                    
                    let tongueWeight = try tongueWeightField.validatedText(validationType: .requiredField(field: "Max Tongue Weight"))
                    hitch.maxTongueWeight = NSDecimalNumber(string: tongueWeight)
                }
                
                hitch.ballSize = ballSizeOptions[ballSizeSegmentedControl.selectedSegmentIndex]
                hitch.shankSize = shankSizeOptions[shankSizeSegmentedControl.selectedSegmentIndex]
                hitch.isWeighSafeHitch = wsSwitch.isOn ? 1 : 0
            
                persistenceManager.save()
                delegate?.event(type: "update", data: hitch)
                dismiss(animated: true){
                    self.hitchIndex = -1
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
        
        for wsView in weighSafeViews {
            wsView.isHidden = true
        }
        
        hitchExtras.isHidden = true
        
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
        
        ballSizeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: "#AB1E23".hexColor, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 13)!], for: .selected)
        shankSizeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: "#AB1E23".hexColor, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 13)!], for: .selected)
        
        wsLink.setAttributedTitle(NSAttributedString(string: "See how Weigh Safe hitches make towing safer", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 14)!, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue, NSAttributedString.Key.foregroundColor: "#AB1E23".hexColor]), for: .normal)
        
        typePicker.delegate = self
        typePicker.tag = 0
        typeField.inputView = typePicker
        
        modelPicker.delegate = self
        modelPicker.tag = 1
        modelField.inputView = modelPicker

        self.hitches = self.persistenceManager.fetch(Hitch.self)
        
        if hitchIndex == -1 {
        
            hitch = Hitch(context: persistenceManager.context)
            deleteView.isHidden = true
            
        }
        
        wsSwitch.setOn(false, animated: false)
        typeField.text = "Bumper Pull"
        
        if hitchIndex != -1 {
            
            deleteView.isHidden = false
            
            hitch = hitches[hitchIndex]
            
            customTitle.title = "Edit Hitch"
            
            if let editHitch = hitch {
            
                typeField.text = editHitch.type
                
                brandField.text = editHitch.brand
            
                gtwrField.text = String(describing: editHitch.maxGTWR!)
                
                tongueWeightField.text = String(describing: editHitch.maxTongueWeight!)
                
                wsSwitch.isOn = (editHitch.isWeighSafeHitch != nil && editHitch.isWeighSafeHitch == 1) ? true : false
                
                if (editHitch.isWeighSafeHitch != nil && editHitch.isWeighSafeHitch == 1) {
                    
                    hitchExtras.isHidden = false
                    for wsView in weighSafeViews {
                        wsView.isHidden = false
                    }
                    for nonWsView in nonWeighSafeViews {
                        nonWsView.isHidden = true
                    }
                    
                    if let brand = editHitch.brand{
                        
                        if modelNames.firstIndex(of: brand) != nil  {
                            let model = modelNames.firstIndex(of: brand)!
                            selectHitchModel(row: model)
                            modelField.text = modelOptions[model]["name"] as? String
                        } else {
                            selectHitchModel(row: 0)
                            modelField.text = "Weigh Safe Drop Hitch"
                        }

                    }
                    
                    ballSizeSegmentedControl.selectedSegmentIndex = ballSizeOptions.firstIndex(of: editHitch.ballSize!)!
                    shankSizeSegmentedControl.selectedSegmentIndex = shankSizeOptions.firstIndex(of: editHitch.shankSize!)!
                    
                }
                
            }
            
        }
    }

    @IBAction func wsSwiched(_ sender: UISwitch) {
        if(sender.isOn){
            hitchExtras.isHidden = false
            for wsView in weighSafeViews {
                wsView.isHidden = false
            }
            for nonWsView in nonWeighSafeViews {
                nonWsView.isHidden = true
            }
            if hitchIndex == -1 {
                modelField.text = "Weigh Safe Drop Hitch"
            }
        }else{
            hitchExtras.isHidden = true
            for wsView in weighSafeViews {
                wsView.isHidden = true
            }
            for nonWsView in nonWeighSafeViews {
                nonWsView.isHidden = false
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
    
    @IBAction func wsLinkPress(_ sender: UIButton) {
        
        var urlText = "https://www.weigh-safe.com"
        
        switch typeField.text {
        case "Weight Distribution":
            urlText = urlText + "/product/true-tow-weight-distribution-hitch/"
        case "Bumper Pull":
            urlText = urlText + "/ball-mounts/"
        case "Gooseneck":
            urlText = urlText + "/gooseneck/"
        default:
            urlText = "https://www.weigh-safe.com"
        }
        
        if let url = URL(string: urlText) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
    
    @IBAction func deleteButtonPress(_ sender: UIButton) {
        
        let alertView = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alertView.addButton("DELETE"){
            
            self.persistenceManager.delete(self.hitches[self.hitchIndex])
            
            let currentIndex = self.defaults.integer(forKey: "currentHitchIndex")
            if self.hitchIndex == currentIndex && currentIndex > 0 {
                self.defaults.set(currentIndex - 1, forKey: "currentHitchIndex")
            }
            
            self.delegate?.event(type: "delete", data: self.hitchIndex)
            self.dismiss(animated: true){
                self.hitchIndex = -1
            }
            
        }
        alertView.addButton("CANCEL", backgroundColor: "#eeeeee".hexColor) {
            alertView.hideView()
        }
        alertView.showWarning("Are you sure?", subTitle: "")
    }
    
    func selectHitchModel(row:Int){
        
        modelField.text = (modelOptions[row]["name"] as! String)
//            brandField.text = (modelOptions[row]["name"] as! String)
//            typeField.text = (modelOptions[row]["type"] as! String)
//            gtwrField.text = modelOptions[row]["mgtwr"]
//            tongueWeightField.text = modelOptions[row]["mtw"]
        
        switch row {
            case 1:
                ballSizeView.isHidden = false
                shankSizeView.isHidden = false
                shankSizeOptions = [
                    "2\"",
                    "2.5\""
                ]
                if activeModel != 5 {
                    shankSizeSegmentedControl.removeSegment(at: 2, animated: false)
                    shankSizeSegmentedControl.selectedSegmentIndex = 0
                }
            case 3,4,6,7,8:
                ballSizeView.isHidden = true
                shankSizeView.isHidden = true
            
                if activeModel == 5 || activeModel == 1 {
                    shankSizeSegmentedControl.insertSegment(withTitle: "3\"", at: 2, animated: false)
                    shankSizeSegmentedControl.selectedSegmentIndex = 0
                }
            case 5:
                ballSizeView.isHidden = true
                shankSizeView.isHidden = false
                shankSizeOptions = [
                    "2\"",
                    "2.5\""
                ]
                if activeModel != 5 {
                    shankSizeSegmentedControl.removeSegment(at: 2, animated: false)
                    shankSizeSegmentedControl.selectedSegmentIndex = 0
                }
            default:
                ballSizeView.isHidden = false
                shankSizeView.isHidden = false
                shankSizeOptions = [
                    "2\"",
                    "2.5\"",
                    "3\""
                ]
                
                if activeModel == 5 || activeModel == 1 {
                    shankSizeSegmentedControl.insertSegment(withTitle: "3\"", at: 2, animated: false)
                    shankSizeSegmentedControl.selectedSegmentIndex = 0
                }
        }
        
        activeModel = row
        
    }
}

extension HitchViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 0){
            return typeOptions.count
        }else{
            return modelOptions.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        if pickerView.tag == 0 {
            label.text = self.typeOptions[row]
        }else{
            label.text = (self.modelOptions[row]["name"] as! String)
        }
        label.textAlignment = .center
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 0 {
            
            typeField.text = typeOptions[row]
            ballSizeSegmentedControl.removeAllSegments()

            ballSizeOptions = [
                "2 5/16\"",
                "2\"",
                "1 7/8\""
            ]

            switch row {
                case 2:
                    ballSizeView.isHidden = false
                    shankSizeView.isHidden = true
                    ballSizeOptions = [
                        "2 5/16\"",
                        "2\""
                    ]
                case 3:
                    ballSizeView.isHidden = true
                    shankSizeView.isHidden = true
                default:
                    ballSizeView.isHidden = false
                    shankSizeView.isHidden = false
            }

            for (index, value) in ballSizeOptions.enumerated() {
                self.ballSizeSegmentedControl.insertSegment(withTitle: value, at: index, animated: false)
            }

            ballSizeSegmentedControl.selectedSegmentIndex = 0
            
        }else{
            selectHitchModel(row: row)
        }
    }
}
