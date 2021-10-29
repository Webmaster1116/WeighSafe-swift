//
//  MeasurementsViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/27/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import UIKit
import SCLAlertView

class MeasurementsViewController: UIViewController {
    
    let persistenceManager = PersistenceManager.shared
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    var configurations: [Configuration] = [Configuration]()
    var configuration: Configuration?
    var onCloseBlock: ((Bool) -> Void)?
    let infoButtons: [[String:String]] = [
        ["title" : "Rear Vehicle Axle Center-line to Tow Ball", "image" : "VariableBTopView"],
        ["title" : "Tow Ball to Spring Bar Connection", "image" : "VariableCTopView"],
        ["title" : "Tow Ball to Center-line of Trailer Axle(s)", "image" : "VariableDTopView"]
    ]

    @IBOutlet weak var rearAxleToTowBallField: UITextField!
    @IBOutlet weak var towBallToSpringBarField: UITextField!
    @IBOutlet weak var towBallToTrailerAxleField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configurations = self.persistenceManager.fetch(Configuration.self)
        configuration = configurations[defaults.integer(forKey: "currentConfigIndex")]
        
        if let field = configuration?.rearAxleToEndOfReceiver {
            rearAxleToTowBallField.text = field == 0 ? "" : String(describing: field)
        }
        if let field = configuration?.towBallToEndOfSpringBars {
            towBallToSpringBarField.text = field == 0 ? "" : String(describing: field)
        }
        if let field = configuration?.towBallToTrailerAxle {
            towBallToTrailerAxleField.text = field == 0 ? "" : String(describing: field)
        }
    }
    
    @IBAction func saveButtonPress(_ sender: UIBarButtonItem) {
        
        do {
                
            if let config = configuration {
                
                let rearAxleToTowBall = try rearAxleToTowBallField.validatedText(validationType: .requiredField(field: "Rear Vehicle Axle Center-line to Tow Ball"))
                config.rearAxleToEndOfReceiver = NSDecimalNumber(string: rearAxleToTowBall)
                
                let towBallToSpringBar = try towBallToSpringBarField.validatedText(validationType: .rangeField(min: 24, max: 36, field: "Tow Ball to Spring Bar Connection"))
                config.towBallToEndOfSpringBars = NSDecimalNumber(string: towBallToSpringBar)
            
                let towBallToTrailerAxle = try towBallToTrailerAxleField.validatedText(validationType: .requiredField(field: "Tow Ball to Center-line of Trailer Axle(s)"))
                config.towBallToTrailerAxle = NSDecimalNumber(string: towBallToTrailerAxle)
                
                persistenceManager.save()
                dismiss(animated: true, completion: nil)
                
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

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 60, height: 300))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: infoButtons[sender.tag]["image"]!)

        alert.customSubview = imageView

        alert.showCustom(infoButtons[sender.tag]["title"]!, subTitle: "", color: "#AB1E23".hexColor, icon: UIImage())
        
    }
    
    @IBAction func closeButtonPress(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        onCloseBlock?(true)
    }
    
}
