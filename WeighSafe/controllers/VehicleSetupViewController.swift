//
//  SetupViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/13/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView

class VehicleSetupViewController: UIViewController {
    
    let persistenceManager = PersistenceManager.shared
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    var configsTableView: ConfigsTableView?
    let titleButton = UIButton()
    let arrowButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    
    private let slidingTabController = UISlidingTabController()
    private var activeTab: Int = 0
    @IBOutlet weak var headerBar: UINavigationBar!
    @IBOutlet weak var headerTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(newConfig(notification:)), name: Notification.Name("newConfig"), object: nil)
        
        setupUI()
        
        headerBar.barTintColor = "#AB1E23".hexColor
        headerBar.barStyle = .black
        headerBar.isTranslucent = false
        
        let nib = Bundle.main.loadNibNamed("ConfigsTableView", owner:self, options: nil)
        
        if let tableView: ConfigsTableView = nib?.first as? ConfigsTableView {
            
            self.configsTableView = tableView
            self.view.addSubview(tableView)
            tableView.isHidden = true
            tableView.configsDelegate = self
            tableView.parentVC = "setup"
            tableView.layer.backgroundColor = UIColor(red:0.67, green:0.12, blue:0.14, alpha:1).cgColor
            tableView.separatorColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.2)
            
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35).isActive = true
            
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let configurations = persistenceManager.fetch(Configuration.self)
        let configuration = configurations[defaults.integer(forKey: "currentConfigIndex")]
        
        //headerTitle.title = configuration.name
        //headerBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: "#ffffff".hexColor, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 17)!]
        
        titleButton.setAttributedTitle(NSAttributedString(string: (configuration.name?.truncate(length: 30))!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 18.0)!]), for: .normal)
        titleButton.sizeToFit()
        titleButton.addTarget(self, action: #selector(dropdownArrowHandler), for: .touchUpInside)
        let titleBarItem = UIBarButtonItem(customView: titleButton)
        headerTitle.leftBarButtonItem = titleBarItem
        
        
        arrowButton.setImage(UIImage(named: "arrow"), for: .normal)
        arrowButton.setImage(UIImage(named: "arrow"), for: .highlighted)
        arrowButton.tintColor = .white
        arrowButton.addTarget(self, action: #selector(dropdownArrowHandler), for: .touchUpInside)
        let arrowItem = UIBarButtonItem(customView: arrowButton)
        headerTitle.rightBarButtonItem = arrowItem
        
        configsTableView?.configurations = configurations
        configsTableView?.reloadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        configsTableView?.isHidden = true
    }
    
    private func setupUI(){
        
        view.backgroundColor = "#AB1E23".hexColor
        view.addSubview(slidingTabController.view)
        
        // MARK: slidingTabController
        slidingTabController.view.translatesAutoresizingMaskIntoConstraints = false
        slidingTabController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35).isActive = true
        slidingTabController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        slidingTabController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        slidingTabController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        slidingTabController.delegate = self
        slidingTabController.addItem(item: VehicleTabViewController(), title: "Vehicle")
        slidingTabController.addItem(item: HitchTabViewController(), title: "Hitch")
        slidingTabController.addItem(item: TrailerTabViewController(), title: "Trailer")
        slidingTabController.addItem(item: CargoTabViewController(), title: "Cargo")

        slidingTabController.setHeaderActiveColor(color: .white)
        slidingTabController.setHeaderInActiveColor(color: .lightText)
        slidingTabController.setHeaderBackgroundColor(color: "#AB1E23".hexColor)
        slidingTabController.setCurrentPosition(position: 0)
        slidingTabController.setStyle(style: .fixed)
        slidingTabController.setHeaderHeight(height: 44)
        slidingTabController.build()
        
        let button = UIButton(frame: CGRect(x: view.safeAreaLayoutGuide.layoutFrame.size.width - 70, y: view.safeAreaLayoutGuide.layoutFrame.size.height - (tabBarController?.tabBar.frame.size.height)! - 70, width: 50, height: 50))
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.backgroundColor = "#AB1E23".hexColor
        button.tintColor = .white
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        button.layer.shadowOpacity = 0.9
        button.layer.shadowRadius = 2.0
        button.clipsToBounds = false
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "plus"), for: .normal)
        } else {
            button.setAttributedTitle(NSAttributedString(string: "+", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Bold", size: 18)!]), for: .normal)
        }
        button.addTarget(self, action: #selector(plusButtonPressed), for: .touchUpInside)
        view.addSubview(button)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sliderPosition(notification:)), name: Notification.Name("setSliderPosition"), object: nil)
        
    }
    
    @objc func dropdownArrowHandler(){
        configsTableView?.toggleTable()
        
        if(!configsTableView!.isHidden){
            UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.headerTitle.rightBarButtonItems![0].customView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            }, completion: nil)
        }else{
            UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.headerTitle.rightBarButtonItems![0].customView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
            }, completion: nil)
        }
    }
    
    @objc func plusButtonPressed(){
        NotificationCenter.default.post(name: Notification.Name("plusButtonPress"), object: nil, userInfo:["tab": activeTab])
    }
    
    @objc func sliderPosition(notification:Notification){
        slidingTabController.setCurrentPosition(position: notification.userInfo!["tab"] as! Int)
        activeTab = notification.userInfo!["tab"] as! Int
    }
    
    @objc func newConfig(notification:Notification){
         
        if let config = notification.userInfo!["config"] {
        
            //headerTitle.title = (config as AnyObject).name
            titleButton.setTitle((config as AnyObject).name.truncate(length: 30), for: .normal)
            titleButton.sizeToFit()
            let titleBarItem = UIBarButtonItem(customView: titleButton)
            navigationItem.setLeftBarButton(titleBarItem, animated: false)
            
        }
        
    }
    
}

extension VehicleSetupViewController: SlidingTabDelegate {
    func didSelectTab(tab: Int) {
        activeTab = tab
    }
}

extension VehicleSetupViewController: ConfigsTableViewDelegate {
    func addButtonPress(tableView: ConfigsTableView, sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.headerTitle.rightBarButtonItems![0].customView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
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
            let numberOfConfigs = tableView.numberOfRows(inSection: 0)

            if let value = txt.text, !value.isEmpty {
                config.name = value
            } else {
                config.name = "Tow Configuration #\(numberOfConfigs + 1)"
            }

            config.tongueWeight = 0
            config.rearAxleToEndOfReceiver = 0
            config.towBallToEndOfSpringBars = 0
            config.towBallToTrailerAxle = 0
            config.vehicle = NSNumber(value: self.defaults.integer(forKey: "currentVehicleIndex"))
            config.hitch = NSNumber(value: self.defaults.integer(forKey: "currentHitchIndex"))
            config.trailer = NSNumber(value: self.defaults.integer(forKey: "currentTrailerIndex"))
            config.cargo = []

            self.persistenceManager.save()
            tableView.configurations.append(config)
            
            self.defaults.set(numberOfConfigs, forKey: "currentConfigIndex")
            self.defaults.set([], forKey: "currentCargoIndexes")
            self.defaults.set("", forKey: "Configuration\(numberOfConfigs)Notes")

            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath.init(row: numberOfConfigs, section: 0)], with: .automatic)
            tableView.endUpdates()

            UserDefaults.standard.set([false, false, false, false, false, false], forKey: "currentChecklist")

            self.titleButton.setAttributedTitle(NSAttributedString(string: (config.name?.truncate(length: 30))!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 18.0)!]), for: .normal)
            self.titleButton.sizeToFit()
            let titleBarItem = UIBarButtonItem(customView: self.titleButton)
            self.navigationItem.setLeftBarButton(titleBarItem, animated: false)

            tableView.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height
                {
                    constraint.constant = (tableView.contentSize.height < self.view.frame.size.height ? tableView.contentSize.height : 0)
                }
            }
            
            NotificationCenter.default.post(name: Notification.Name("changeConfiguration"), object: nil, userInfo: [:])

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
            self.headerTitle.rightBarButtonItems![0].customView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
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
                let titleBarItem = UIBarButtonItem(customView: self.titleButton)
                self.navigationItem.setLeftBarButton(titleBarItem, animated: false)

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
            self.headerTitle.rightBarButtonItems![0].customView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
        }, completion: nil)
        
        self.titleButton.setAttributedTitle(NSAttributedString(string: (config.name?.truncate(length: 30))!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 18.0)!]), for: .normal)
        self.titleButton.sizeToFit()
        let titleBarItem = UIBarButtonItem(customView: self.titleButton)
        self.navigationItem.setLeftBarButton(titleBarItem, animated: false)
        
        defaults.set(indexPath.row, forKey: "currentConfigIndex")
        defaults.set(config.vehicle as! Int, forKey: "currentVehicleIndex")
        defaults.set(config.hitch as! Int, forKey: "currentHitchIndex")
        defaults.set(config.trailer as! Int, forKey: "currentTrailerIndex")
        defaults.set(config.cargo!, forKey: "currentCargoIndexes")
        UserDefaults.standard.set([false, false, false, false, false, false], forKey: "currentChecklist")
        
        NotificationCenter.default.post(name: Notification.Name("changeConfiguration"), object: nil, userInfo: [:])
        
    }
}
