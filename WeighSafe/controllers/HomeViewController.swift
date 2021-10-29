//
//  HomeViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/20/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import UIKit
import SCLAlertView
import AMPopTip

class HomeViewController: UIViewController, UINavigationBarDelegate {
    
    let persistenceManager = PersistenceManager.shared
    
    var vehicles = [Vehicle]()
    var trailers = [Trailer]()
    var hitches = [Hitch]()
    var cargos = [Cargo]()
    
    var configurations = [Configuration]()
    var configuration: Configuration?
    
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    var keyboardHeight: CGFloat = 0.0
    var bottomSafeArea: CGFloat = 0.0
    var textFieldActive = UITextField()
    var didLoadOnce = false
    
    var vehicleCargo: Double = 0
    var cacheVehicleCargo: Double = 0
    var additionalVehicleCargo: Double = 0
    var trailerCargo: Double = 0
    var cacheTrailerCargo: Double = 0
    var additionalTrailerCargo: Double = 0
    let popTip = PopTip()
    
    var configsTableView: ConfigsTableView?
    let titleButton = UIButton()
    let arrowButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    
    @IBOutlet weak var dropMenuView: UITableView!
    @IBOutlet weak var dropMenuHeight: NSLayoutConstraint!
    @IBOutlet weak var homeTitle: UILabel!
    @IBOutlet weak var setupImageView: UIImageView!
    @IBOutlet weak var tongueWeightField: UITextField!
    @IBOutlet weak var borderedBox: UIView!
    @IBOutlet weak var dtwView: UIView!
    @IBOutlet weak var tongueWeightMin: UILabel!
    @IBOutlet weak var tongueWeightMax: UILabel!
    @IBOutlet weak var vehicleCargoWeightField: UITextField!
    @IBOutlet weak var vehicleCargoStepper: UIStepper!
    @IBOutlet weak var vehicleGVWR: UILabel!
    @IBOutlet weak var vehicleEstWeight: UILabel!
    @IBOutlet weak var trailerCargoWeightField: UITextField!
    @IBOutlet weak var trailerCargoStepper: UIStepper!
    @IBOutlet weak var trailerGVWR: UILabel!
    @IBOutlet weak var trailerEstWeight: UILabel!
    @IBOutlet weak var gcwr: UILabel!
    @IBOutlet weak var actualWeight: UILabel!
    
    @IBOutlet weak var calculateDTWButton: UIButton!
    @IBOutlet weak var calculateResults: UIView!
    @IBOutlet weak var calculateBox: UIView!
    
    @IBOutlet weak var safezoneMin: UILabel!
    @IBOutlet weak var safezoneTarget: UILabel!
    @IBOutlet weak var safezoneMax: UILabel!
    
    @IBOutlet weak var hitchMenu: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var safePromo: UIView!
    @IBOutlet weak var promoBox: UIView!
    @IBOutlet weak var gvwrView: UIView!
    @IBOutlet weak var gvwView: UIView!
    @IBOutlet weak var gcwrView: UIView!
    @IBOutlet weak var gtwrView: UIView!
    @IBOutlet weak var gtwView: UIView!
    @IBOutlet weak var actualWeightView: UIView!
    
    @IBOutlet weak var vehicleCargoAdj: UILabel!
    @IBOutlet weak var trailerCargoAdj: UILabel!
    @IBOutlet weak var tongueWeightLabel: UILabel!
    
    @IBOutlet weak var drawbarView: UIView!
    @IBOutlet weak var drawbarPositionControl: UISegmentedControl!
    @IBOutlet weak var stepperControl: UIStepper!
    @IBOutlet weak var holesVisibleLabel: UILabel!
    
    @IBOutlet weak var saftyStatusContainer: UIStackView!
    @IBOutlet var saftyStatusImageView: [UIImageView]!
    
    @IBAction func holesStepperPress(_ sender: UIStepper) {
        if(sender.value == -0.5){
            holesVisibleLabel.text = "0.5 Holes"
        }else{
            let hitch = hitches[defaults.integer(forKey: "currentHitchIndex")]
            holesVisibleLabel.text = "\(Int(sender.value)) Hole\(sender.value == 1 ? "" : "s")"
            if hitch.isWeighSafeHitch == 1 && hitch.type == "Weight Distribution" {
                holesVisibleLabel.text = "\(sender.value) Hole\(sender.value == 1 ? "" : "s")"
            }
            
        }
        configuration!.holesVisible = NSDecimalNumber(string: String(sender.value))
        persistenceManager.save()
    }
    
    @IBAction func positionPress(_ sender: UISegmentedControl) {
        configuration!.drawbarPosition = sender.selectedSegmentIndex as NSNumber
        persistenceManager.save()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(newConfig(notification:)), name: Notification.Name("newConfig"), object: nil)
        
        calculateDTWButton.addTarget(self, action: #selector(calculateDTW), for: .touchUpInside)
        
        saftyStatusImageView[0].isHidden = true
        saftyStatusImageView[1].isHidden = true
        
        configurations = persistenceManager.fetch(Configuration.self) // GET CONFIGURATIONS STORED IN COREDATA
        
        tongueWeightField.delegate = self
        vehicleCargoWeightField.delegate = self
        trailerCargoWeightField.delegate = self
//        dropMenuView.delegate = self
//        dropMenuView.dataSource = self
//        dropMenuView.tableFooterView = UIView()
//        dropMenuView.isHidden = true
//        dropMenuView.allowsSelection = true
//        dropMenuView.separatorColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.2)
//        dropMenuView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        dropMenuView.superview?.bringSubviewToFront(dropMenuView)
//
//        resizeDropdownMenu()
        
        let nib = Bundle.main.loadNibNamed("ConfigsTableView", owner:self, options: nil)
        
        if let tableView: ConfigsTableView = nib?.first as? ConfigsTableView {
            
            self.configsTableView = tableView
            self.view.addSubview(tableView)
            tableView.isHidden = true
            tableView.configsDelegate = self
            tableView.parentVC = "home"
            tableView.layer.backgroundColor = UIColor(red:0.67, green:0.12, blue:0.14, alpha:1).cgColor
            tableView.separatorColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.2)
            
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            
            let tableHeight = (tableView.rowHeight * CGFloat(tableView.configurations.count)) + 43
            if tableHeight < view.frame.size.height {
                tableView.heightAnchor.constraint(equalToConstant: tableHeight).isActive = true
            }else{
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
            }
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
            
            //self.view.bringSubviewToFront(tableView)
        }
        
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
        
        navigationController?.navigationBar.barTintColor = "#AB1E23".hexColor
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        
        tongueWeightField.addBorder(color: "#dddddd".hexColor, dashed: true)
        vehicleCargoWeightField.addBorder(color: "#eeeeee".hexColor, dashed: true)
        trailerCargoWeightField.addBorder(color: "#eeeeee".hexColor, dashed: true)
//        borderedBox.layer.borderWidth = 3
//        borderedBox.layer.borderColor = "#f3f3f3".hexColor.cgColor
//        borderedBox.layer.cornerRadius = 5
        
        hitchMenu.isHidden = true
        dtwView.isHidden = true
        calculateResults.isHidden = true
        calculateDTWButton.layer.cornerRadius = 5
//        calculateBox.addBorder(color: "#AB1E23".hexColor, dashed: true)
        calculateBox.layer.cornerRadius = 5
        
        safePromo.isHidden = true
        safePromo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(promoTapped)))
        
        let lineView = UIView(frame: CGRect(x: 0, y: -1, width:(tabBarController?.tabBar.frame.size.width)!, height: 1))
        lineView.backgroundColor = "#f3f3f3".hexColor
        tabBarController?.tabBar.addSubview(lineView)
        
        actualWeightView.layer.cornerRadius = 0
        actualWeightView.clipsToBounds = true
        
        gcwrView.layer.cornerRadius = 0
        gcwrView.clipsToBounds = true
        
        promoBox.layer.cornerRadius = 8
        promoBox.clipsToBounds = true
        
        drawbarPositionControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: "#ac2520".hexColor], for: .selected)
        drawbarPositionControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        configurations = persistenceManager.fetch(Configuration.self)
        
        var currentConfigIndex = defaults.integer(forKey: "currentConfigIndex")
        if(currentConfigIndex < 0){
            self.defaults.set(0, forKey: "currentConfigIndex")
            currentConfigIndex = 0
        }
        
        if configurations.count == 0 {
            titleButton.setAttributedTitle(NSAttributedString(string: "Tow Configuration #1", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 18.0)!]), for: .normal)
        } else {
            configuration = configurations[currentConfigIndex]
            titleButton.setAttributedTitle(NSAttributedString(string: (configuration!.name?.truncate(length: 30))!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 18.0)!]), for: .normal)
        }
        titleButton.sizeToFit()
        titleButton.addTarget(self, action: #selector(dropdownArrowHandler), for: .touchUpInside)
        let titleBarItem = UIBarButtonItem(customView: titleButton)
        self.navigationItem.leftBarButtonItem = titleBarItem
        
        arrowButton.setImage(UIImage(named: "arrow"), for: .normal)
        arrowButton.setImage(UIImage(named: "arrow"), for: .highlighted)
        arrowButton.tintColor = .white
        arrowButton.addTarget(self, action: #selector(dropdownArrowHandler), for: .touchUpInside)
        let dropdownArrow = UIBarButtonItem(customView: arrowButton)
        self.navigationItem.rightBarButtonItem = dropdownArrow
        
        vehicles = persistenceManager.fetch(Vehicle.self)
        trailers = persistenceManager.fetch(Trailer.self)
        hitches = persistenceManager.fetch(Hitch.self)
        cargos = persistenceManager.fetch(Cargo.self)
        
        defaults.set(false, forKey: "wizardOn")
        
        if self.configurations.count > 0 && (trailers.count == 0 || trailers.count == 0 || hitches.count == 0) {
            
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
            alert.addButton("Go to Setup", backgroundColor: "#AB1E23".hexColor, textColor: .white) {
                alert.hideView()
                self.tabBarController?.selectedIndex = 1
            }
            alert.showWarning("Incorrect Tow Configuration", subTitle: "Please add at least one Vehicle, Trailer, and Hitch in the Setup tab")
            
        } else if self.configurations.count == 0 {
            // IF NO CONFIGS FOUND, SET DEFAULT CONFIG
            let config = Configuration(context: persistenceManager.context)
            config.name = ""
            config.vehicle = 0
            config.hitch = 0
            config.trailer = 0
            config.cargo = []
            config.drawbarPosition = 0
            config.holesVisible = 0
            
            // IF CAPTURED DEEP LINKS, ADD CONFIG VALUES
            if defaults.string(forKey: "tongueWeight") != nil {
                config.tongueWeight = NSDecimalNumber(string: defaults.string(forKey: "tongueWeight"))
                defaults.removeObject(forKey: "tongueWeight")
            }
            
            if defaults.string(forKey: "towBallToEndOfSpringBars") != nil {
                config.towBallToEndOfSpringBars = NSDecimalNumber(string: defaults.string(forKey: "towBallToEndOfSpringBars"))
                defaults.removeObject(forKey: "towBallToEndOfSpringBars")
            }
            
            if defaults.string(forKey: "towBallToTrailerAxle") != nil {
                config.towBallToTrailerAxle = NSDecimalNumber(string: defaults.string(forKey: "towBallToTrailerAxle"))
                defaults.removeObject(forKey: "towBallToTrailerAxle")
            }
            
            if defaults.string(forKey: "rearAxleToEndOfReceiver") != nil {
                config.rearAxleToEndOfReceiver = NSDecimalNumber(string: defaults.string(forKey: "rearAxleToEndOfReceiver"))
                defaults.removeObject(forKey: "rearAxleToEndOfReceiver")
            }
            
            if defaults.string(forKey: "holesVisible") != nil {
                config.holesVisible = NSDecimalNumber(string: defaults.string(forKey: "holesVisible"))
                defaults.removeObject(forKey: "holesVisible")
            }
            
            if defaults.string(forKey: "drawbarPosition") != nil {
                config.drawbarPosition = NSDecimalNumber(string: defaults.string(forKey: "drawbarPosition"))
                defaults.removeObject(forKey: "drawbarPosition")
            }

            persistenceManager.save()
            self.configurations.append(config)
            
            defaults.set(true, forKey: "wizardOn")
            defaults.set(0, forKey: "currentConfigIndex")
            defaults.set(0, forKey: "currentVehicleIndex")
            defaults.set(0, forKey: "currentHitchIndex")
            defaults.set(0, forKey: "currentTrailerIndex")
            defaults.set([], forKey: "currentCargoIndexes")
            defaults.set("", forKey: "Configuration0Notes")

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
            alert.iconTintColor = .black
            let txt = alert.addTextField("Name this config...(i.e. Work, Camping Trip, Boating, etc..)")
            alert.addButton("NEXT") {
                if let value = txt.text, !value.isEmpty {
                    config.name = value
                } else {
                    config.name = "Tow Configuration #1"
                }
                self.persistenceManager.save()
                self.configurations[0].name = config.name
                //self.dropMenuView.reloadData()
                
                self.titleButton.setAttributedTitle(NSAttributedString(string: (self.configurations[0].name?.truncate(length: 30))!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 18.0)!]), for: .normal)
                self.titleButton.sizeToFit()
                
                alert.hideView()
                self.tabBarController?.selectedIndex = 1
                
            }

            alert.showCustom("Let’s get started!", subTitle: "Start by Setting up your first tow configuration:  Tow Configuration = Vehicle + Hitch + Trailer + Cargo", color: "#AB1E23".hexColor, icon: UIImage(named: "setup.png")!)
            
        } else {
            
            configuration = configurations[defaults.integer(forKey: "currentConfigIndex")]
            var saveConfig = false
            if defaults.string(forKey: "tongueWeight") != nil {
                configuration!.tongueWeight = NSDecimalNumber(string: defaults.string(forKey: "tongueWeight"))
                defaults.removeObject(forKey: "tongueWeight")
                saveConfig = true
            }
            
            if defaults.string(forKey: "towBallToEndOfSpringBars") != nil {
                configuration!.towBallToEndOfSpringBars = NSDecimalNumber(string: defaults.string(forKey: "towBallToEndOfSpringBars"))
                defaults.removeObject(forKey: "towBallToEndOfSpringBars")
                saveConfig = true
            }
            
            if defaults.string(forKey: "towBallToTrailerAxle") != nil {
                configuration!.towBallToTrailerAxle = NSDecimalNumber(string: defaults.string(forKey: "towBallToTrailerAxle"))
                defaults.removeObject(forKey: "towBallToTrailerAxle")
                saveConfig = true
            }
            
            if defaults.string(forKey: "rearAxleToEndOfReceiver") != nil {
                configuration!.rearAxleToEndOfReceiver = NSDecimalNumber(string: defaults.string(forKey: "rearAxleToEndOfReceiver"))
                defaults.removeObject(forKey: "rearAxleToEndOfReceiver")
                saveConfig = true
            }
            
            if defaults.string(forKey: "holesVisible") != nil {
                configuration!.holesVisible = NSDecimalNumber(string: defaults.string(forKey: "holesVisible"))
                defaults.removeObject(forKey: "holesVisible")
                saveConfig = true
            }
            
            if defaults.string(forKey: "drawbarPosition") != nil {
                configuration!.drawbarPosition = NSDecimalNumber(string: defaults.string(forKey: "drawbarPosition"))
                defaults.removeObject(forKey: "drawbarPosition")
                saveConfig = true
            }
            
            if saveConfig {
                persistenceManager.save()
            }
            
            if defaults.bool(forKey: "trueTowGuideOn") {
                
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
                alert.iconTintColor = .black
                
                alert.addButton("SKIP", backgroundColor: .gray, textColor: .white) {
                    
                    alert.hideView()
                    self.defaults.set(false, forKey: "trueTowGuideOn")
                    
                }
                
                alert.addButton("HELP/SETUP", backgroundColor: "#AB1E23".hexColor, textColor: .white) {
                    
                    alert.hideView()
                    var vc = UIViewController()
                    switch self.hitches[self.defaults.integer(forKey: "currentHitchIndex")].type {
                    case "Weight Distribution":
                        vc = WeightDistributionMenuViewController.loadFromNib()
                    default:
                        vc = WeightDistributionMenuViewController.loadFromNib()
                    }
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }

                alert.showCustom("Important Hitch Notice", subTitle: "We recommend you view our installation guide and/or video prior to completing your True Tow Weight Distribution Hitch setup. The installation guide will walk you through the remaining setup items to complete.", color: "#AB1E23".hexColor, icon: UIImage(named: "setup.png")!)
                
            }
            
            refresh()
            
        }
        
        configsTableView?.configurations = configurations
        if configurations.count == 1 {
            arrowButton.isHidden = true
        } else {
            arrowButton.isHidden = false
        }
        configsTableView?.reloadData()
        if let tableView = configsTableView {
            tableView.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height
                {
                    constraint.constant = (tableView.contentSize.height < self.view.frame.size.height ? tableView.contentSize.height : 0)
                }
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if popTip.isVisible {
            popTip.hide()
        }
        
        configsTableView?.isHidden = true
//        let avc = NSDecimalNumber(value: additionalVehicleCargo)
//        let atc = NSDecimalNumber(value: additionalTrailerCargo)
//
//        configuration?.additionalVehicleWeight = avc
//        configuration?.additionalTrailerWeight = atc
//
//        persistenceManager.save()
        
    }
    
//    func resizeDropdownMenu(){
//        if(dropMenuView.contentSize.height > 300){
//            dropMenuHeight.constant = 300
//        }else{
//            dropMenuHeight.constant = dropMenuView.contentSize.height
//        }
//    }
//
//    @objc func dropdownHandler(){
//
//        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
//
//        self.dropMenuView.isHidden = !self.dropMenuView.isHidden
//
//        if(!dropMenuView.isHidden){
//            UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
//                self.navigationItem.rightBarButtonItems![0].customView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
//            }, completion: nil)
//        }else{
//            UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
//                self.navigationItem.rightBarButtonItems![0].customView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
//            }, completion: nil)
//        }
//
//        NotificationCenter.default.post(name: Notification.Name("changeConfiguration"), object: nil, userInfo: [:])
//
//    }
    
    @objc func dropdownArrowHandler(){
        if configurations.count != 1 {
        configsTableView?.toggleTable()
        
        if(!configsTableView!.isHidden){
            UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.navigationItem.rightBarButtonItems![0].customView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            }, completion: nil)
        }else{
            UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.navigationItem.rightBarButtonItems![0].customView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
            }, completion: nil)
        }
        }
    }
    
    @objc func newConfig(notification:Notification){
         
        if let config = notification.userInfo!["config"] {
            
            self.configurations.append(config as! Configuration)
//            self.dropMenuView.reloadData()
//            self.resizeDropdownMenu()
            
        }
        
    }
    
    func refresh(resetCargo: Bool = true){
        
        let vehicle = vehicles[defaults.integer(forKey: "currentVehicleIndex")]
        let trailer = trailers[defaults.integer(forKey: "currentTrailerIndex")]
        let hitch = hitches[defaults.integer(forKey: "currentHitchIndex")]
        let cargoActive = defaults.array(forKey: "currentCargoIndexes")! as Array
        
        let currentConfigIndex = defaults.integer(forKey: "currentConfigIndex")
        configuration = self.configurations[currentConfigIndex]
        
        if resetCargo {
            vehicleCargo = 0
            trailerCargo = 0
            for i in cargoActive {
                if cargos[i as! Int].type == "Vehicle" {
                    vehicleCargo += Double(truncating: cargos[i as! Int].cargoWeight!)
                } else {
                    trailerCargo += Double(truncating: cargos[i as! Int].cargoWeight!)
                }
            }
            cacheVehicleCargo = vehicleCargo
            cacheTrailerCargo = trailerCargo
            
            vehicleCargo += Double(truncating: configuration!.additionalVehicleWeight!)
            trailerCargo += Double(truncating: configuration!.additionalTrailerWeight!)
            
            if vehicleCargo < 0 {
                vehicleCargo = 0
            }
            
            if trailerCargo < 0 {
                trailerCargo = 0
            }
            
        }
        
        //if let avw = configuration!.additionalVehicleWeight, cacheVehicleCargo > Double(truncating: avw) {
        if let avw = configuration!.additionalVehicleWeight {
            let avwValue = Double(truncating: avw)
            if avwValue != 0.0 {
                vehicleCargoAdj.text = "Cargo Adj. \(avwValue > 0 ? "+" : "")\(avwValue.formattedWithSeparator)"
            }else{
                vehicleCargoAdj.text = ""
            }
        }
        
        //if let atw = configuration!.additionalTrailerWeight, cacheTrailerCargo > Double(truncating: atw) {
        if let atw = configuration!.additionalTrailerWeight {
            let atwValue = Double(truncating: atw)
            if atwValue != 0.0 {
                trailerCargoAdj.text = "Cargo Adj. \(atwValue > 0 ? "+" : "")\(atwValue.formattedWithSeparator)"
            }else{
                trailerCargoAdj.text = ""
            }
        }
        
        homeTitle.text = hitch.type
        homeTitle.textColor = .darkGray
        saftyStatusImageView[0].isHidden = true
        saftyStatusImageView[1].isHidden = true
        
        if hitch.type == "Weight Distribution" && hitch.isWeighSafeHitch != nil && hitch.isWeighSafeHitch == 1 {
            dtwView.isHidden = false
        } else {
            dtwView.isHidden = true
        }
        
        if hitch.isWeighSafeHitch != nil && ((hitch.isWeighSafeHitch == 1 && hitch.brand == "Weigh Safe 180 Hitch") || hitch.isWeighSafeHitch == 0) {
            tongueWeightLabel.text = "ESTIMATED\r\nTONGUE WEIGHT (lb)"
        } else {
            tongueWeightLabel.text = "ACTUAL\r\nTONGUE WEIGHT (lb)"
        }
        
        switch hitch.type {
        case "Weight Distribution":
            if let image = UIImage(named: "trailer-setup-bumper-\(String(describing: trailer.type!)).png"){
                self.setupImageView.image = image
            } else {
                self.setupImageView.image = UIImage(named: "trailer-setup-bumper-rv.png")
            }
        case "Gooseneck":
            if let image = UIImage(named: "trailer-setup-gooseneck-\(String(describing: trailer.type!)).png"){
                self.setupImageView.image = image
            } else {
                self.setupImageView.image = UIImage(named: "trailer-setup-gooseneck-flat.png")
            }
        case "Fifth Wheel":
            if let image = UIImage(named: "trailer-setup-fifthwheel-\(String(describing: trailer.type!)).png"){
                self.setupImageView.image = image
            } else {
                self.setupImageView.image = UIImage(named: "trailer-setup-fifthwheel-rv.png")
            }
        default:
            if let image = UIImage(named: "trailer-setup-bumper-\(String(describing: trailer.type!)).png"){
                self.setupImageView.image = image
            } else {
                self.setupImageView.image = UIImage(named: "trailer-setup-bumper-flat.png")
            }
        }
        
        calculateResults.isHidden = true
        
        if (hitch.isWeighSafeHitch != nil && hitch.isWeighSafeHitch == 1) {
            hitchMenu.isHidden = true
            if(hitch.type == "Weight Distribution"){
                hitchMenu.isHidden = false
            }
            safePromo.isHidden = true
        } else {
            hitchMenu.isHidden = true
            safePromo.isHidden = false
        }
        
        let vehicleGVWRValue = Double(truncating: vehicle.gvwr!)
        vehicleGVWR.text = String(describing: vehicleGVWRValue.formattedWithSeparator)
        
        let trailerEmptyWeightValue = Double(truncating: trailer.emptyWeight!)
        trailerGVWR.text = String(describing: trailerEmptyWeightValue.formattedWithSeparator)
        
        vehicleCargoStepper.value = vehicleCargo
        vehicleCargoWeightField.text = String(describing: vehicleCargo.formattedWithSeparator)
        
        trailerCargoStepper.value = trailerCargo
        trailerCargoWeightField.text = String(describing: trailerCargo.formattedWithSeparator)
        
        let estTrailerWeight = (trailerEmptyWeightValue - Double(truncating: trailer.loadCapacity!)) + (trailer.cargoWeight != nil ? Double(truncating: trailer.cargoWeight!) : 0) + trailerCargo
        
        var twMultiplierMin = 0.1
        var twMultiplierMax = 0.15
        if hitch.type == "Gooseneck" || hitch.type == "Fifth Wheel" {
            twMultiplierMin = 0.15
            twMultiplierMax = 0.25
        }
        tongueWeightMin.text = String(describing: floor((estTrailerWeight * twMultiplierMin)).formattedWithSeparator)
        tongueWeightMax.text = String(describing: ceil((estTrailerWeight * twMultiplierMax)).formattedWithSeparator)
        
        trailerEstWeight.text = String(describing: estTrailerWeight.formattedWithSeparator)
        
        var estVehicleWeight: Double = 0.0
        
        let tw = configuration?.tongueWeight
        if tw != nil {
            
            if tw == 0 {
                tongueWeightField.text = ""
    
                popTip.shouldDismissOnTap = false
                popTip.actionAnimation = .bounce(5)
                popTip.bubbleColor = "#AB1E23".hexColor
                popTip.padding = 10.0
                
                var popTipText = "Please enter your tongue weight"
                if (hitch.isWeighSafeHitch != nil && hitch.isWeighSafeHitch == 1) {
                    if(hitch.type == "Weight Distribution"){
                        popTipText = "Please enter your tongue weight. After that, press the \"Calculate\" button to get your required adjusted tongue weight."
                    }
                }
                popTip.show(text: popTipText, direction: .up, maxWidth: 300, in: view, from: CGRect(x: view.frame.size.width / 2, y: 460, width: 1, height: 1))
            } else {
                tongueWeightField.text = String(describing: Double(truncating: tw!).formattedWithSeparator)
            }
            
            estVehicleWeight = (vehicleGVWRValue - Double(truncating: vehicle.mcc!)) + Double(truncating: tw!) + vehicleCargo
            
            vehicleEstWeight.text = String(describing: estVehicleWeight.formattedWithSeparator)
            
            actualWeight.text = String(describing: (estTrailerWeight + estVehicleWeight).formattedWithSeparator)
            
            tongueWeightField.backgroundColor = .white
            
            saftyStatusImageView[0].isHidden = false
            saftyStatusImageView[1].isHidden = false
            
            homeTitle.text = "Proper " + hitch.type! + " Setup"
            homeTitle.textColor = "#1AA14E".hexColor
            saftyStatusImageView[0].image = UIImage(systemName: "hand.thumbsup.fill")
            saftyStatusImageView[0].tintColor = "#1AA14E".hexColor
            saftyStatusImageView[1].image = UIImage(systemName: "hand.thumbsup.fill")
            saftyStatusImageView[1].tintColor = "#1AA14E".hexColor
            
            if Double(truncating: tw!) < floor(estTrailerWeight * twMultiplierMin) || Double(truncating: tw!) > ceil(estTrailerWeight * twMultiplierMax) {
                tongueWeightField.backgroundColor = .yellow
                
                homeTitle.text = "Improper " + hitch.type! + " Setup"
                homeTitle.textColor = "#AB1E23".hexColor
                saftyStatusImageView[0].image = UIImage(systemName: "hand.thumbsdown.fill")
                saftyStatusImageView[0].tintColor = "#AB1E23".hexColor
                saftyStatusImageView[1].image = UIImage(systemName: "hand.thumbsdown.fill")
                saftyStatusImageView[1].tintColor = "#AB1E23".hexColor
            }
            
        }else{
            
            actualWeight.text = String(describing: estTrailerWeight.formattedWithSeparator)
            
        }
        
        gcwr.text = String(describing: Double(truncating: vehicle.gcwr!).formattedWithSeparator)
        
//        let gtw = Double(truncating: vehicle.gcwr!) - (vehicleGVWRValue - vehicleCargo)
        
        let weightRatingCapacity = Double(truncating: hitch.type == "Weight Distribution" ? vehicle.maxDistributedWeightRating! : vehicle.maxBumperWeightRating!)
        var mgtwr: [Double] = [
            Double(truncating: hitch.maxGTWR!),
            Double(truncating: trailer.emptyWeight!)
        ]
        
        if weightRatingCapacity != 0 {
            mgtwr.append(weightRatingCapacity)
        }
        
        let minMgtwr = mgtwr.min()!
        
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
        alert.iconTintColor = .black
        
        alert.addButton("OK", backgroundColor: .yellow, textColor: .black) {
            alert.hideView()
        }
        
        gtwrView.backgroundColor = .white
        gtwView.backgroundColor = .white
        
        if tw != nil && estTrailerWeight > minMgtwr {
            
            let minIndex = mgtwr.firstIndex(of: minMgtwr)
            var mgtwrMsg = ""
            if minIndex == 0 {
                mgtwrMsg = "vehicle's receiver"
            } else if minIndex == 1 {
                mgtwrMsg = "tow hitch"
            } else {
                mgtwrMsg = "trailer"
            }
            if tw as! Int > 0 {
                alert.showWarning("Unsafe Tow Configuration", subTitle: "Your Gross Trailer Weight exceeds the Max Gross Trailer Weight Rating of your \(mgtwrMsg). We recommend adjusting cargo for a safe tow.")
            }
            
            gtwrView.backgroundColor = .yellow
            gtwView.backgroundColor = .yellow
            
            if let _ = configuration?.tongueWeight {
                homeTitle.text = "Improper " + hitch.type! + " Setup"
                homeTitle.textColor = "#AB1E23".hexColor
                saftyStatusImageView[0].image = UIImage(systemName: "hand.thumbsdown.fill")
                saftyStatusImageView[0].tintColor = "#AB1E23".hexColor
                saftyStatusImageView[1].image = UIImage(systemName: "hand.thumbsdown.fill")
                saftyStatusImageView[1].tintColor = "#AB1E23".hexColor
            }
            
        }
        
//        if estTrailerWeight > trailerEmptyWeightValue {
//
//            alert.showWarning("Unsafe Trailer Configuration", subTitle: "Your Gross Trailer Weight exceeds the Max Gross Vehicle Weight Rating of your trailer. We recommend adjusting cargo for a safe tow.")
//
//            gtwrView.backgroundColor = .yellow
//            gtwView.backgroundColor = .yellow
//
//        }
        
        gcwrView.backgroundColor = .white
        actualWeightView.backgroundColor = .white
        
        if tw != nil && (estTrailerWeight + estVehicleWeight) > Double(truncating: vehicle.gcwr!) {
            
            if tw as! Int > 0 {
            alert.showWarning("Unsafe Tow Configuration", subTitle: "Your Gross Combined Weight exceeds the Gross Combined Weight Rating of your vehicle. We recommend adjusting your set up for a safe tow.")
            }
            
            gcwrView.backgroundColor = .yellow
            actualWeightView.backgroundColor = .yellow
            
            if let _ = configuration?.tongueWeight {
                homeTitle.text = "Improper " + hitch.type! + " Setup"
                homeTitle.textColor = "#AB1E23".hexColor
                saftyStatusImageView[0].image = UIImage(systemName: "hand.thumbsdown.fill")
                saftyStatusImageView[0].tintColor = "#AB1E23".hexColor
                saftyStatusImageView[1].image = UIImage(systemName: "hand.thumbsdown.fill")
                saftyStatusImageView[1].tintColor = "#AB1E23".hexColor
            }
            
        }
        
        gvwrView.backgroundColor = .white
        gvwView.backgroundColor = .white
        
        if tw != nil && estVehicleWeight > vehicleGVWRValue {
            
            if tw as! Int > 0 {
            alert.showWarning("Unsafe Vehicle Configuration", subTitle: "Your Gross Vehicle Weight exceeds the Gross Vehicle Weight Rating of your vehicle. We recommend adjusting your vehicle cargo for a safe tow.")
            }
            
            gvwrView.backgroundColor = .yellow
            gvwView.backgroundColor = .yellow
            
            if let _ = configuration?.tongueWeight {
                homeTitle.text = "Improper " + hitch.type! + " Setup"
                homeTitle.textColor = "#AB1E23".hexColor
                saftyStatusImageView[0].image = UIImage(systemName: "hand.thumbsdown.fill")
                saftyStatusImageView[0].tintColor = "#AB1E23".hexColor
                saftyStatusImageView[1].image = UIImage(systemName: "hand.thumbsdown.fill")
                saftyStatusImageView[1].tintColor = "#AB1E23".hexColor
            }
            
        }
        
        if tw != nil {
            
            if let currentChecklist = UserDefaults.standard.object(forKey: "currentChecklist") as? [Bool] {
                var trueCount = 0
                
                currentChecklist.forEach{ (value) in
                    if(value){
                        trueCount += 1
                    }
                }
                if trueCount != 6 {
                    popTip.actionAnimation = .none
                    popTip.shouldDismissOnTap = false
                    popTip.bubbleColor = "#AB1E23".hexColor
                    popTip.padding = 10.0
                    
                    let tabBar = tabBarController!.tabBar
                    let width = tabBar.frame.size.width / CGFloat((tabBar.items?.count)!)
                    let height = tabBar.frame.size.height
                    let rect = CGRect(x: width * 2, y: 0, width: width, height: height)
                    
                    popTip.show(text: "For your safety, complete the tow checklist", direction: .up, maxWidth: 300, in: tabBar, from: rect)
                }
            }
            
        }
        
        if hitch.type == "Weight Distribution" || hitch.type == "Bumper Pull" {
            
            if let tw = configuration?.tongueWeight {
                
                var maxDistributedCapacity = Double(truncating: hitch.maxTongueWeight!)
                
                let vehicleMDTWR = Double(truncating: vehicle.maxDistributedTongueWeightRating!)
                if vehicleMDTWR != 0 && vehicleMDTWR < maxDistributedCapacity {
                    maxDistributedCapacity = vehicleMDTWR
                }
                
                if hitch.type == "Weight Distribution" && Double(truncating: tw) > maxDistributedCapacity {
                    
                    alert.showWarning("Unsafe Hitch Configuration", subTitle: "Your Tongue Weight exceeds the Max Tongue Weight Rating of your vehicle receiver. We recommend adjusting your trailer or cargo for a safe tow.")
                    
                    if let _ = configuration?.tongueWeight {
                        homeTitle.text = "Improper " + hitch.type! + " Setup"
                        homeTitle.textColor = "#AB1E23".hexColor
                        saftyStatusImageView[0].image = UIImage(systemName: "hand.thumbsdown.fill")
                        saftyStatusImageView[0].tintColor = "#AB1E23".hexColor
                        saftyStatusImageView[1].image = UIImage(systemName: "hand.thumbsdown.fill")
                        saftyStatusImageView[1].tintColor = "#AB1E23".hexColor
                    }
                    
                }
                
                var maxBumperCapacity = Double(truncating: hitch.maxTongueWeight!)
                let vehicleMBTWR = Double(truncating: vehicle.maxBumperTongueWeightRating!)
                if vehicleMBTWR != 0 && vehicleMBTWR < maxBumperCapacity {
                    maxBumperCapacity = vehicleMBTWR
                }
                if hitch.type == "Bumper Pull" && Double(truncating: tw) > maxBumperCapacity {
            
                    alert.showWarning("Unsafe Hitch Configuration", subTitle: "Your Tongue Weight exceeds the Max Tongue Weight Rating of your vehicle receiver. We recommend adjusting your trailer or cargo for a safe tow.")
                    
                    if let _ = configuration?.tongueWeight {
                        homeTitle.text = "Improper " + hitch.type! + " Setup"
                        homeTitle.textColor = "#AB1E23".hexColor
                        saftyStatusImageView[0].image = UIImage(systemName: "hand.thumbsdown.fill")
                        saftyStatusImageView[0].tintColor = "#AB1E23".hexColor
                        saftyStatusImageView[1].image = UIImage(systemName: "hand.thumbsdown.fill")
                        saftyStatusImageView[1].tintColor = "#AB1E23".hexColor
                    }
                    
                }
                
            }
        
        }
        
        drawbarView.isHidden = true
        
        if hitch.isWeighSafeHitch == 1 && hitch.type == "Weight Distribution" {
            drawbarView.isHidden = false
        }
        
        let holesVisible = configuration!.holesVisible as! Double
        stepperControl.minimumValue = 0
        stepperControl.maximumValue = 8
        if hitch.isWeighSafeHitch == 1 && hitch.type == "Weight Distribution" {
            stepperControl.minimumValue = 0.5
            stepperControl.maximumValue = 7.5
        }
        
        if(holesVisible == -0.5){
            holesVisibleLabel.text = "0.5 Holes"
            stepperControl.value = 0.5
        }else{
            holesVisibleLabel.text = "\(String(describing: configuration!.holesVisible!)) Hole\(configuration!.holesVisible == 1 ? "" : "s")"
            stepperControl.value = holesVisible
        }
        
        drawbarPositionControl.selectedSegmentIndex = configuration!.drawbarPosition as! Int
        
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
            
            scrollViewBottom.constant = -(keyboardHeight - (self.navigationController?.navigationBar.frame.size.height)! - self.bottomSafeArea - 5)
        }
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        scrollViewBottom.constant = 0
        
    }
    
    @objc func promoTapped() {
        
        var urlText = "https://www.weigh-safe.com"
        
        switch hitches[defaults.integer(forKey: "currentHitchIndex")].type {
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
    
    @objc func calculateDTW() {
        
        tongueWeightField.resignFirstResponder()
        
        let currentConfigIndex = defaults.integer(forKey: "currentConfigIndex")
        let config = self.configurations[currentConfigIndex]
        
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
        alert.iconTintColor = .black
        
        tongueWeightField.backgroundColor = .white
        if let tw = config.tongueWeight, tw == 0 {
            alert.addButton("Close", backgroundColor: .yellow, textColor: .black) {
                alert.hideView()
            }
            alert.showWarning("Incorrect Configuration", subTitle: "Tongue is required to calculate distributed tongue weight.")
            
            tongueWeightField.backgroundColor = .yellow
            
        } else if config.towBallToEndOfSpringBars == 0 || config.towBallToTrailerAxle == 0 || config.rearAxleToEndOfReceiver == 0 {
            
            let vc = MeasurementsViewController.loadFromNib()
            vc.onCloseBlock = { result in
                self.calculateDTW()
            }
            self.view.window?.rootViewController?.present(vc, animated: true, completion: nil)
            
        } else if config.towBallToEndOfSpringBars != 0 && config.towBallToTrailerAxle != 0 && config.rearAxleToEndOfReceiver != 0 {
            
            let nominator = 1 - (Double(truncating: config.towBallToEndOfSpringBars!) / Double(truncating: config.towBallToTrailerAxle!))
            
            let denominator = (Double(truncating: config.towBallToEndOfSpringBars!) / Double(truncating: config.rearAxleToEndOfReceiver!)) + (Double(truncating: config.towBallToEndOfSpringBars!) / Double(truncating: config.towBallToTrailerAxle!))
            
            let result = 1 + (nominator / denominator)
            
            let numFormatter = NumberFormatter()
            
            let tw = Double(truncating: config.tongueWeight!)
            
            var minPercent = 0.95
            var targetPercent = 1.0
            var maxPercent = 1.05
            
            if tw >= 500 && tw <= 999 {
                minPercent = 0.85
                targetPercent = 0.90
                maxPercent = 0.95
            } else if tw >= 1000 && tw <= 1499 {
                minPercent = 0.75
                targetPercent = 0.80
                maxPercent = 0.85
            } else if tw >= 1499 {
                minPercent = 0.70
                targetPercent = 0.75
                maxPercent = 0.80
            }
            
            let FALR = Double(truncating: config.tongueWeight!) * result
            //print(FALR)
            safezoneMin.text = numFormatter.string(from: roundUp((FALR * minPercent), toNearest: 50) as NSNumber)!
            //print(FALR * minPercent)
            safezoneTarget.text = numFormatter.string(from: roundUp((FALR * targetPercent), toNearest: 50) as NSNumber)!
            //print(FALR * targetPercent)
            safezoneMax.text = numFormatter.string(from: roundUp((FALR * maxPercent), toNearest: 50) as NSNumber)!
            //print(FALR * maxPercent)
            
            dtwView.isHidden = false
            calculateResults.isHidden = false
            
            scrollView.scrollToView(view: dtwView, animated: true)
            
        }else{

//            alert.addButton("Close", backgroundColor: "#AB1E23".hexColor, textColor: .white) {
//                alert.hideView()
//            }
//            alert.showWarning("Incorrect Configuration", subTitle: "Unable to calculate Distributed Tongue Weight. Vehicle setup is not complete")
            
        }
        
    }
    
    func roundUp(_ value: Double, toNearest: Double) -> Double {
        return ceil(value / toNearest) * toNearest
    }
    
    @IBAction func measurementsButtonPress(_ sender: UIButton) {
        let vc = MeasurementsViewController.loadFromNib()
        vc.onCloseBlock = { result in
            self.calculateDTW()
        }
        self.view.window?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func vehicleStepperChanged(_ sender: UIStepper) {
        vehicleCargo = sender.value
        additionalVehicleCargo = sender.value - cacheVehicleCargo
        
        configuration?.additionalVehicleWeight = NSDecimalNumber(value: additionalVehicleCargo)
        persistenceManager.save()
        
        dtwView.isHidden = true
        calculateResults.isHidden = true
        
        refresh(resetCargo: false)
    }
    
    @IBAction func trailerStepperChanged(_ sender: UIStepper) {
        trailerCargo = sender.value
        additionalTrailerCargo = sender.value - cacheTrailerCargo
        
        configuration?.additionalTrailerWeight = NSDecimalNumber(value: additionalTrailerCargo)
        persistenceManager.save()
        
        dtwView.isHidden = true
        calculateResults.isHidden = true
        
        refresh(resetCargo: false)
    }
    
    @IBAction func hitchMoreMenuPress(_ sender: UIButton) {
        var vc = UIViewController()
        switch hitches[defaults.integer(forKey: "currentHitchIndex")].type {
        case "Weight Distribution":
            vc = WeightDistributionMenuViewController.loadFromNib()
        default:
            vc = WeightDistributionMenuViewController.loadFromNib()
        }
        
        //self.view.window?.rootViewController?.present(vc, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
        //present(vc, animated: true, completion: nil)
    }
    
}

//extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return self.configurations.count
//
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
//
//        cell.textLabel?.text = self.configurations[indexPath.row].name
//        cell.textLabel?.textColor = .white
//        cell.textLabel?.font = UIFont(name: "Roboto-Bold", size: 16.0)
//        cell.backgroundColor = UIColor(red:0.67, green:0.12, blue:0.14, alpha:1)
//        cell.tintColor = .white
//
//        let backgroundView = UIView()
//        backgroundView.backgroundColor = UIColor(red:0.67, green:0.12, blue:0.14, alpha:0)
//        cell.selectedBackgroundView = backgroundView
//
//        return cell
//
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let frame: CGRect = tableView.frame
//        let addButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 42))
//        addButton.setTitle("+ Add Tow Configuration", for: .normal)
//        addButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 16.0)
//        addButton.contentHorizontalAlignment = .left
//        addButton.contentEdgeInsets.left = 15
//        addButton.backgroundColor = UIColor(red:0.67, green:0.12, blue:0.14, alpha:1)
//        addButton.addTarget(self, action: #selector(addButtonHandler), for: .touchUpInside)
//        let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 42))
//        let borderView = UIView(frame: CGRect(x: 0, y: 42, width: frame.size.width, height: 1))
//        borderView.backgroundColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.1)
//        headerView.backgroundColor = .white
//        headerView.addSubview(addButton)
//        headerView.addSubview(borderView)
//        return headerView
//
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }
//
//    @objc func addButtonHandler(){
//
//        dropMenuView.isHidden = true
//
//        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
//            self.navigationItem.rightBarButtonItems![0].customView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
//        }, completion: nil)
//
//        let appearance = SCLAlertView.SCLAppearance(
//            kCircleHeight: 0,
//            kWindowWidth: view.frame.size.width - 40,
//            kTextHeight: 65,
//            kTextFieldHeight: 65,
//            kTextViewdHeight: 65,
//            kTitleFont: UIFont(name: "Roboto-Bold", size: 20)!,
//            kTextFont: UIFont(name: "Roboto-Medium", size: 14)!,
//            kButtonFont: UIFont(name: "Roboto-Bold", size: 14)!,
//            showCloseButton: false,
//            showCircularIcon: false,
//            shouldAutoDismiss: true,
//            buttonsLayout: .horizontal
//        )
//
//        self.defaults.set(true, forKey: "wizardOn")
//
//        let alert = SCLAlertView(appearance: appearance)
//        alert.iconTintColor = .black
//        let txt = alert.addTextField("Name this config...(i.e. Work, Camping Trip, Boating, etc..)")
//        alert.addButton("SAVE") {
//
//            let config = Configuration(context: self.persistenceManager.context)
//
//            if let value = txt.text, !value.isEmpty {
//                config.name = value
//            } else {
//                config.name = "Tow Configuration #\(self.configurations.count + 1)"
//            }
//
//            config.tongueWeight = 0
//            config.rearAxleToEndOfReceiver = 0
//            config.towBallToEndOfSpringBars = 0
//            config.towBallToTrailerAxle = 0
//            config.vehicle = 0
//            config.hitch = 0
//            config.trailer = 0
//            config.cargo = []
//
//            self.persistenceManager.save()
//            self.configurations.append(config)
//            self.defaults.set(self.configurations.count - 1, forKey: "currentConfigIndex")
//
//            self.dropMenuView.beginUpdates()
//            self.dropMenuView.insertRows(at: [IndexPath.init(row: self.configurations.count - 1, section: 0)], with: .automatic)
//            self.dropMenuView.endUpdates()
//
//            UserDefaults.standard.set([false, false, false, false, false, false], forKey: "currentChecklist")
//
//            self.titleButton.setAttributedTitle(NSAttributedString(string: (self.configurations[self.configurations.count - 1].name?.truncate(length: 30))!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 18.0)!]), for: .normal)
//
//            self.titleButton.sizeToFit()
//
//            let titleBarItem = UIBarButtonItem(customView: self.titleButton)
//            self.navigationItem.setLeftBarButton(titleBarItem, animated: false)
//
//            self.resizeDropdownMenu()
//            self.refresh()
//
//            self.tabBarController?.selectedIndex = 1
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                NotificationCenter.default.post(name: Notification.Name("setSliderPosition"), object: nil, userInfo:["tab": 0])
//            }
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                NotificationCenter.default.post(name: Notification.Name("plusButtonPress"), object: nil, userInfo:["tab": 0])
//            }
//
//        }
//
//        alert.addButton("CANCEL", backgroundColor: "#eeeeee".hexColor, textColor: .darkText) {
//            self.defaults.set(false, forKey: "wizardOn")
//            alert.hideView()
//        }
//
//        alert.showCustom("New Tow Configuration", subTitle: "After saving, setup vehicle, hitch, trailer, and optional cargo for the new configuration.", color: "#AB1E23".hexColor, icon: UIImage(named: "setup.png")!)
//
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        titleButton.setAttributedTitle(NSAttributedString(string: (configurations[indexPath.row].name?.truncate(length: 30))!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 18.0)!]), for: .normal)
//        titleButton.sizeToFit()
//
//        let titleBarItem = UIBarButtonItem(customView: titleButton)
//        titleBarItem.target = self
//        titleBarItem.action = #selector(dropdownHandler)
//        navigationItem.setLeftBarButton(titleBarItem, animated: false)
//
//        let config = configurations[indexPath.row]
//
//        defaults.set(indexPath.row, forKey: "currentConfigIndex")
//        defaults.set(config.vehicle as! Int, forKey: "currentVehicleIndex")
//        defaults.set(config.hitch as! Int, forKey: "currentHitchIndex")
//        defaults.set(config.trailer as! Int, forKey: "currentTrailerIndex")
//        defaults.set(config.cargo!, forKey: "currentCargoIndexes")
//        UserDefaults.standard.set([false, false, false, false, false, false], forKey: "currentChecklist")
//        dropMenuView.isHidden = true
//        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
//            self.navigationItem.rightBarButtonItems![0].customView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
//        }, completion: nil)
//        refresh()
//
//    }
//
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        var actionButtons = [UIContextualAction]()
//
//        let deleteBtn = UIContextualAction(style: .normal, title: "DELETE") {  (contextualAction, view, boolValue) in
//            let config = self.configurations[indexPath.row]
//            self.configurations.remove(at: indexPath.row)
//            tableView.beginUpdates()
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            tableView.endUpdates()
//
//            if(indexPath.row < self.defaults.integer(forKey: "currentConfigIndex")){
//                self.defaults.set(self.defaults.integer(forKey: "currentConfigIndex") - 1, forKey: "currentConfigIndex")
//            }
//            self.persistenceManager.delete(config)
//
//            self.resizeDropdownMenu()
//        }
//
//        deleteBtn.backgroundColor = UIColor(red:0.67, green:0.12, blue:0.14, alpha:1)
//
//        let editBtn = UIContextualAction(style: .normal, title: "EDIT") {  (contextualAction, view, boolValue) in
//
//            self.dropMenuView.isHidden = true
//            UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
//                self.navigationItem.rightBarButtonItems![0].customView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
//            }, completion: nil)
//
//            let config = self.configurations[indexPath.row]
//
//            let appearance = SCLAlertView.SCLAppearance(
//                kCircleHeight: 0,
//                kWindowWidth: self.view.frame.size.width - 40,
//                kTextHeight: 65,
//                kTextFieldHeight: 65,
//                kTextViewdHeight: 65,
//                kTitleFont: UIFont(name: "Roboto-Bold", size: 20)!,
//                kTextFont: UIFont(name: "Roboto-Medium", size: 14)!,
//                kButtonFont: UIFont(name: "Roboto-Bold", size: 14)!,
//                showCloseButton: false,
//                showCircularIcon: false,
//                shouldAutoDismiss: false,
//                buttonsLayout: .horizontal
//            )
//
//            let alert = SCLAlertView(appearance: appearance)
//            alert.iconTintColor = .black
//            let textField = alert.addTextField("Name of setup...")
//            textField.text = config.name
//            alert.addButton("SAVE") {
//
//                if let value = textField.text, !value.isEmpty {
//                    config.name = value
//                } else {
//                    config.name = "Tow Configuration #1"
//                }
//                self.persistenceManager.save()
//                self.configurations[indexPath.row].name = config.name
//                self.dropMenuView.reloadData()
//
//                if(indexPath.row == self.defaults.integer(forKey: "currentConfigIndex")){
//
//                    self.titleButton.setAttributedTitle(NSAttributedString(string: (config.name?.truncate(length: 30))!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 18.0)!]), for: .normal)
//                    self.titleButton.sizeToFit()
//
//                    let titleBarItem = UIBarButtonItem(customView: self.titleButton)
//                    titleBarItem.target = self
//                    titleBarItem.action = #selector(self.dropdownHandler)
//                    self.navigationItem.setLeftBarButton(titleBarItem, animated: false)
//
//                }
//
//                alert.hideView()
//            }
//
//            alert.addButton("CANCEL", backgroundColor: UIColor.lightGray) {
//                alert.hideView()
//            }
//            alert.showCustom("Edit Tow Configuration", subTitle: "Change the name of the this configuration", color: "#AB1E23".hexColor, icon: UIImage(named: "setup.png")!)
//
//        }
//
//        editBtn.backgroundColor = UIColor(red:0.67, green:0.12, blue:0.14, alpha:1)
//
//        actionButtons.append(editBtn)
//
//        if(self.configurations.count > 1 && indexPath.row != self.defaults.integer(forKey: "currentConfigIndex")){
//            actionButtons.append(deleteBtn)
//        }
//
//        let swipeActions = UISwipeActionsConfiguration(actions: actionButtons)
//
//        return swipeActions
//
//    }
//
//}

extension HomeViewController: ConfigsTableViewDelegate {
    func addButtonPress(tableView: ConfigsTableView, sender: UIButton) {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.navigationItem.rightBarButtonItems![0].customView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
        }, completion: nil)
        
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
            shouldAutoDismiss: true,
            buttonsLayout: .horizontal
        )

        self.defaults.set(true, forKey: "wizardOn")

        let alert = SCLAlertView(appearance: appearance)
        alert.iconTintColor = .black
        let txt = alert.addTextField("Name this config...(i.e. Work, Camping Trip, Boating, etc..)")
        alert.addButton("SAVE") {

            let config = Configuration(context: self.persistenceManager.context)

            if let value = txt.text, !value.isEmpty {
                config.name = value
            } else {
                config.name = "Tow Configuration #\(self.configurations.count + 1)"
            }

            config.tongueWeight = 0
            config.rearAxleToEndOfReceiver = 0
            config.towBallToEndOfSpringBars = 0
            config.towBallToTrailerAxle = 0
            config.vehicle = 0
            config.hitch = 0
            config.trailer = 0
            config.cargo = []

            self.persistenceManager.save()
            self.configurations.append(config)
            self.defaults.set(self.configurations.count - 1, forKey: "currentConfigIndex")

            UserDefaults.standard.set([false, false, false, false, false, false], forKey: "currentChecklist")

            self.titleButton.setAttributedTitle(NSAttributedString(string: (self.configurations[self.configurations.count - 1].name?.truncate(length: 30))!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 18.0)!]), for: .normal)
            self.titleButton.sizeToFit()

            self.tabBarController?.selectedIndex = 1

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: Notification.Name("setSliderPosition"), object: nil, userInfo:["tab": 0])
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(name: Notification.Name("plusButtonPress"), object: nil, userInfo:["tab": 0])
            }

        }

        alert.addButton("CANCEL", backgroundColor: "#eeeeee".hexColor, textColor: .darkText) {
            self.defaults.set(false, forKey: "wizardOn")
            alert.hideView()
        }

        alert.showCustom("New Tow Configuration", subTitle: "After saving, setup vehicle, hitch, trailer, and optional cargo for the new configuration.", color: "#AB1E23".hexColor, icon: UIImage(named: "setup.png")!)
    }
    
    func editButtonPress(tableView: ConfigsTableView, indexPath: IndexPath, config: Configuration) {
        
        tableView.isHidden = true
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.navigationItem.rightBarButtonItems![0].customView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
        }, completion: nil)

        let appearance = SCLAlertView.SCLAppearance(
            kCircleHeight: 0,
            kWindowWidth: self.view.frame.size.width - 40,
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
        alert.iconTintColor = .black
        let textField = alert.addTextField("Name of setup...")
        textField.text = config.name
        alert.addButton("SAVE") {

            if let value = textField.text, !value.isEmpty {
                config.name = value
            } else {
                config.name = "Tow Configuration #\(tableView.numberOfRows(inSection: 0))"
            }
            self.persistenceManager.save()
            tableView.configurations[indexPath.row].name = config.name
            tableView.reloadData()

            if(indexPath.row == self.defaults.integer(forKey: "currentConfigIndex")){

                self.titleButton.setAttributedTitle(NSAttributedString(string: (config.name?.truncate(length: 30))!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 18.0)!]), for: .normal)
                self.titleButton.sizeToFit()

            }

            alert.hideView()
        }

        alert.addButton("CANCEL", backgroundColor: UIColor.lightGray) {
            alert.hideView()
        }
        alert.showCustom("Edit Tow Configuration", subTitle: "Change the name of the this configuration", color: "#AB1E23".hexColor, icon: UIImage(named: "setup.png")!)
    }
    
    func deleteButtonPress(tableView: ConfigsTableView, config: Configuration) {
        
        tableView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height
            {
                constraint.constant = (tableView.contentSize.height < self.view.frame.size.height ? tableView.contentSize.height : 0)
            }
        }
        
    }
    
    func didSelectConfig(tableView: ConfigsTableView, indexPath: IndexPath, config: Configuration) {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.navigationItem.rightBarButtonItems![0].customView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
        }, completion: nil)

        self.titleButton.setAttributedTitle(NSAttributedString(string: (config.name?.truncate(length: 30))!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 18.0)!]), for: .normal)
        self.titleButton.sizeToFit()

        defaults.set(indexPath.row, forKey: "currentConfigIndex")
        defaults.set(config.vehicle as! Int, forKey: "currentVehicleIndex")
        defaults.set(config.hitch as! Int, forKey: "currentHitchIndex")
        defaults.set(config.trailer as! Int, forKey: "currentTrailerIndex")
        defaults.set(config.cargo!, forKey: "currentCargoIndexes")
        UserDefaults.standard.set([false, false, false, false, false, false], forKey: "currentChecklist")

        NotificationCenter.default.post(name: Notification.Name("changeConfiguration"), object: nil, userInfo: [:])

        refresh()
        
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            let textFieldValue = NSDecimalNumber(string: textField.text!.replacingOccurrences(of: ",", with: ""))
            vehicleCargo = Double(truncating: textFieldValue)
            additionalVehicleCargo = Double(truncating: textFieldValue) - cacheVehicleCargo
            
            configuration?.additionalVehicleWeight = NSDecimalNumber(value: additionalVehicleCargo)
            persistenceManager.save()
            
            //if cacheVehicleCargo > additionalVehicleCargo {
                let avwValue = additionalVehicleCargo
                if avwValue != 0.0 {
                    vehicleCargoAdj.text = "Cargo Adj. \(avwValue > 0 ? "+" : "")\(avwValue.formattedWithSeparator)"
                }else{
                    vehicleCargoAdj.text = ""
                }
            //}
        case 1:
            let textFieldValue = NSDecimalNumber(string: textField.text!.replacingOccurrences(of: ",", with: ""))
            trailerCargo = Double(truncating: textFieldValue)
            additionalTrailerCargo = Double(truncating: textFieldValue) - cacheTrailerCargo
            
            configuration?.additionalTrailerWeight = NSDecimalNumber(value: additionalTrailerCargo)
            persistenceManager.save()
            
            //if cacheTrailerCargo > additionalTrailerCargo {
                let atwValue = additionalTrailerCargo
                if atwValue != 0.0 {
                    trailerCargoAdj.text = "Cargo Adj. \(atwValue > 0 ? "+" : "")\(atwValue.formattedWithSeparator)"
                }else{
                    trailerCargoAdj.text = ""
                }
            //}
        default:
            //let config = configurations[defaults.integer(forKey: "currentConfigIndex")]
            if let txt = textField.text, !txt.isEmpty {
                //config.tongueWeight = NSDecimalNumber(string: txt)
                configuration?.tongueWeight = NSDecimalNumber(string: txt.replacingOccurrences(of: ",", with: ""))
                persistenceManager.save()
                
                popTip.actionAnimation = .none
                
                let tabBar = tabBarController!.tabBar
                let width = tabBar.frame.size.width / CGFloat((tabBar.items?.count)!)
                let height = tabBar.frame.size.height
                let rect = CGRect(x: width * 2, y: 0, width: width, height: height)
                
                popTip.show(text: "For your safety, complete the tow checklist", direction: .up, maxWidth: 300, in: tabBar, from: rect)
            }
            
            let trailer = trailers[defaults.integer(forKey: "currentTrailerIndex")]
            let trailerEmptyWeightValue = Double(truncating: trailer.emptyWeight!)
            let estTrailerWeight = (trailerEmptyWeightValue - Double(truncating: trailer.loadCapacity!)) + (trailer.cargoWeight != nil ? Double(truncating: trailer.cargoWeight!) : 0) + trailerCargo
            
            let hitch = hitches[defaults.integer(forKey: "currentHitchIndex")]
            
            var twMultiplierMin = 0.1
            var twMultiplierMax = 0.15
            if hitch.type == "Gooseneck" || hitch.type == "Fifth Wheel" {
                twMultiplierMin = 0.15
                twMultiplierMax = 0.25
            }
            
            if let tw = configuration?.tongueWeight {
                
                saftyStatusImageView[0].isHidden = false
                saftyStatusImageView[1].isHidden = false
                
                if Double(truncating: tw) < floor(estTrailerWeight * twMultiplierMin) || Double(truncating: tw) > ceil(estTrailerWeight * twMultiplierMax) {
                    
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
                    alert.iconTintColor = .black
                    
                    alert.addButton("OK", backgroundColor: .yellow, textColor: .black) {
                        alert.hideView()
                    }
                    alert.showWarning("Unsafe Tow Configuration", subTitle: "Your tongue weight is outside of our recommended \"Safe Tongue Weight Range.\" We recommend repositioning the cargo in the trailer or remove cargo.")
                    
                    tongueWeightField.backgroundColor = .yellow
                    
                } else {
                    tongueWeightField.backgroundColor = .white
                }
            }
            safePromo.isHidden = false
            
        }
        dtwView.isHidden = true
        calculateResults.isHidden = true
        refresh(resetCargo: false)
    }
}
