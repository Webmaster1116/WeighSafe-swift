//
//  VehicleTabViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/13/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import Foundation
import UIKit
import EmptyDataSet_Swift
import SCLAlertView

class VehicleTabViewController: UIViewController {
    
    let persistenceManager = PersistenceManager.shared
    let tableView = UITableView()
    var vehicles = [Vehicle]()
    var rowIndexSelected = -1
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
//    let defaultVehicles = [
//        ["name" : "GMC Sierra 1500 (sample)", "gvwr" : "7200", "mcc" : "1357", "gcwr" : "15000", "mgtw" : "12000", "mtw" : "1200"],
//        ["name" : "Ram 2500 (sample)", "gvwr" : "8565", "mcc" : "2950", "gcwr" : "22500", "mgtw" : "15000", "mtw" : "1500"],
//        ["name" : "Ford F-350 (sample)", "gvwr" : "10100", "mcc" : "3893", "gcwr" : "20000", "mgtw" : "15000", "mtw" : "1500"]
//    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        NotificationCenter.default.addObserver(self, selector: #selector(onPlusButtonPress(notification:)), name: Notification.Name("plusButtonPress"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable(notification:)), name: Notification.Name("changeConfiguration"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(tabPress(notification:)), name: Notification.Name("tabPress"), object: nil)
        
        // view
        view.addSubview(tableView)
        
        // tableView
        tableView.backgroundColor = .white
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "VehicleTableViewCell", bundle: nil) , forCellReuseIdentifier: "vehicleCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 85, right: 0)
        tableView.contentInset = insets
        
        self.vehicles = self.persistenceManager.fetch(Vehicle.self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if vehicles.count == 0 || defaults.bool(forKey: "wizardOn") {
            NotificationCenter.default.post(name: Notification.Name("plusButtonPress"), object: nil, userInfo:["tab": 0])
        }
    }
    
    @objc func onPlusButtonPress(notification:Notification)
    {
        if notification.userInfo!["tab"] as! Int == 0 {
            rowIndexSelected = -1
            let vc = VehicleViewController.loadFromNib()
            vc.vehicleIndex = -1
            vc.delegate = self
            
            if defaults.bool(forKey: "wizardOn") && vehicles.count > 0 {
                
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
                    shouldAutoDismiss: false
                )
                
                let alert = SCLAlertView(appearance: appearance)
                alert.iconTintColor = .black
                
                alert.addButton("Add Vehicle", backgroundColor: "#AB1E23".hexColor, textColor: .white) {
                    alert.hideView()
                    self.view.window?.rootViewController?.present(vc, animated: true, completion: nil)
                }
                
                alert.addButton("Keep Vehicle & Skip", backgroundColor: .gray, textColor: .white) {
                    alert.hideView()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        NotificationCenter.default.post(name: Notification.Name("setSliderPosition"), object: nil, userInfo:["tab": 1])
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        NotificationCenter.default.post(name: Notification.Name("tabPress"), object: nil, userInfo:["tab": 1, "showNewScreen": true])
                    }
                }
                
                alert.showCustom("Would you like to add a new vehicle?", subTitle: "Keeping the vehicle will jump to Hitches.", color: "#AB1E23".hexColor, icon: UIImage())
                
            } else {
                self.view.window?.rootViewController?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @objc func reloadTable(notification:Notification) {
        tableView.reloadData()
    }
    
    @objc func tabPress(notification:Notification){
        
        if notification.userInfo!["tab"] as! Int == 0 {
            
            if let showNewScreen = notification.userInfo!["showNewScreen"], showNewScreen as! Bool {
            
                NotificationCenter.default.post(name: Notification.Name("plusButtonPress"), object: nil, userInfo:["tab": notification.userInfo!["tab"] as! Int])
                
            }
            
        }
        
    }

}

extension VehicleTabViewController: UITableViewDelegate {}

extension VehicleTabViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return vehicles.count
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if vehicles.count > 0 {
            
            return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            
//        } else {
//            
//            let bgView = UIView()
//            bgView.backgroundColor = "#f0f0f0".hexColor
//            
//            let label = UILabel()
//            label.lineBreakMode = .byWordWrapping
//            label.numberOfLines = 0
//            label.font = UIFont(name: "Roboto-Bold", size: 14)
//            label.textColor = "#555".hexColor
//            label.text = "Manually add vehicles with the PLUS button."
//            label.translatesAutoresizingMaskIntoConstraints = false
//            bgView.addSubview(label)
//            
//            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10).isActive = true
//            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10).isActive = true
//            label.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 10).isActive = true
//            label.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -10).isActive = true
//            
//            return bgView
//            
//        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if vehicles.count > 0 {
            return 0
        }

        return tableView.sectionHeaderHeight
    }
    
    func updateCell(cell: VehicleTableViewCell, row: Int) {
        if vehicles[row].name != nil {
            let name = String(describing: vehicles[row].name!)
            if vehicles[row].vin != nil {
                //name = "\(name) (\(String(describing: vehicles[row].year!)) \(String(describing: vehicles[row].make!)))"
            }
            cell.name.text = name
            cell.vin.text = vehicles[row].vin != nil ? "VIN: \(String(describing: vehicles[row].vin!))" : "VIN: ---"
            cell.gvwr.text = String(describing: Double(truncating: vehicles[row].gvwr!).formattedWithSeparator)
            cell.gcwr.text = String(describing: Double(truncating: vehicles[row].gcwr!).formattedWithSeparator)
            cell.mcc.text = String(describing: Double(truncating: vehicles[row].mcc!).formattedWithSeparator)
        }
        
        if row == defaults.integer(forKey: "currentVehicleIndex") {
            cell.button.setAttributedTitle(NSAttributedString(string: "ACTIVE", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 12)!]), for: .normal)
            cell.button.backgroundColor = "#AB1E23".hexColor
        } else {
            cell.button.setAttributedTitle(NSAttributedString(string: "SET", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 12)!]), for: .normal)
            cell.button.backgroundColor = .lightGray
        }
          
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VehicleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "vehicleCell", for: indexPath) as! VehicleTableViewCell
        cell.selectionStyle = .none
        cell.button.tag = indexPath.row
        cell.button.addTarget(self, action: #selector(activateButtonPress), for: .touchUpInside)
        self.updateCell(cell: cell, row: indexPath.row)
        return cell
    }
    
    @objc func activateButtonPress(sender:UIButton) {
        
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
//            shouldAutoDismiss: false
//        )
//
//        let alert = SCLAlertView(appearance: appearance)
//        alert.iconTintColor = .black
//        let txt = alert.addTextField("Name this config...(i.e. Work, Camping Trip, Boating, etc..)")
//
//        alert.addButton("Save", backgroundColor: "#AB1E23".hexColor, textColor: .white) {
//            [self] in
//
//            let configurations = persistenceManager.fetch(Configuration.self)
//            let currentConfigIndex = defaults.integer(forKey: "currentConfigIndex")
//            let currentConfiguration = configurations[currentConfigIndex]
//
//            let newConfig = Configuration(context: self.persistenceManager.context)
//
//            if let value = txt.text, !value.isEmpty {
//                newConfig.name = value
//            } else {
//                newConfig.name = "Tow Configuration #\(configurations.count + 1)"
//            }
//
//            newConfig.tongueWeight = 0
//            newConfig.rearAxleToEndOfReceiver = 0
//            newConfig.towBallToEndOfSpringBars = 0
//            newConfig.towBallToTrailerAxle = 0
//            newConfig.vehicle = NSNumber(value: sender.tag)
//            newConfig.hitch = currentConfiguration.hitch
//            newConfig.trailer = currentConfiguration.trailer
//            newConfig.cargo = currentConfiguration.cargo
//
//            self.persistenceManager.save()
//            self.defaults.set(configurations.count, forKey: "currentConfigIndex")
//
//            let currentIndex = defaults.integer(forKey: "currentVehicleIndex")
//            defaults.set(sender.tag, forKey: "currentVehicleIndex")
//
//            let cell = tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0))
//            updateCell(cell: cell as! VehicleTableViewCell, row: currentIndex)
//
//            let buttonCell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0))
//            updateCell(cell: buttonCell as! VehicleTableViewCell, row: sender.tag)
//
//            NotificationCenter.default.post(name: Notification.Name("newConfig"), object: nil, userInfo:["config": newConfig])
//
//            alert.hideView()
//        }
//
//        alert.addButton("Skip & Set as Active", backgroundColor: .gray, textColor: .white) {
//            [self] in
            let currentIndex = defaults.integer(forKey: "currentVehicleIndex")
            defaults.set(sender.tag, forKey: "currentVehicleIndex")
            
            let cell = tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0))
            updateCell(cell: cell as! VehicleTableViewCell, row: currentIndex)
            
            let buttonCell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0))
            updateCell(cell: buttonCell as! VehicleTableViewCell, row: sender.tag)
            
            let configurations = persistenceManager.fetch(Configuration.self)
            let configuration = configurations[defaults.integer(forKey: "currentConfigIndex")]
            configuration.vehicle = NSNumber(value: sender.tag)
            persistenceManager.save()
            
//            alert.hideView()
//        }
        
//        alert.showCustom("Would you like to add this as a new tow configuration?", subTitle: "Enter the name of the new config and tap \"Save\".", color: "#AB1E23".hexColor, icon: UIImage())
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if vehicles.count > 0 {
            
            rowIndexSelected = indexPath.row
            let vc = VehicleViewController.loadFromNib()
            vc.vehicleIndex = indexPath.row
            vc.delegate = self
            self.view.window?.rootViewController?.present(vc, animated: true, completion: nil)
            
        }
    }
    
}

extension VehicleTabViewController: DataTransit {
    func event(type: String, data: Any) {
        if type == "update"{
            if rowIndexSelected == -1 {
                
                let count = vehicles.count
                vehicles.append(data as! Vehicle)
                
                if count == 0 {
                    tableView.reloadData()
                } else {
//                    if defaults.bool(forKey: "wizardOn") {
                        let currentIndex = defaults.integer(forKey: "currentVehicleIndex")
                        defaults.set(count, forKey: "currentVehicleIndex")
                        
                        let configurations = persistenceManager.fetch(Configuration.self)
                        let configuration = configurations[defaults.integer(forKey: "currentConfigIndex")]
                        configuration.vehicle = NSNumber(value: currentIndex + 1)
                        persistenceManager.save()
                    
                        let cell = tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0))
                        updateCell(cell: cell as! VehicleTableViewCell, row: currentIndex)
//                    }
                    tableView.beginUpdates()
                    tableView.insertRows(at: [IndexPath(row: count, section: 0)], with: .automatic)
                    tableView.endUpdates()
                }
                
                if defaults.bool(forKey: "wizardOn"){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        NotificationCenter.default.post(name: Notification.Name("setSliderPosition"), object: nil, userInfo:["tab": 1])
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        NotificationCenter.default.post(name: Notification.Name("tabPress"), object: nil, userInfo:["tab": 1, "showNewScreen": true])
                    }
                }
                
            } else {
                
                let cell = tableView.cellForRow(at: IndexPath(row: rowIndexSelected, section: 0))
                self.updateCell(cell: cell as! VehicleTableViewCell, row: rowIndexSelected)
                
            }
        }
        
        if type == "delete"{
            
            vehicles.remove(at: rowIndexSelected)
            tableView.deleteRows(at: [IndexPath(row: rowIndexSelected, section: 0)], with: .automatic)
            
            let currentIndex = defaults.integer(forKey: "currentVehicleIndex")
            let cell = tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0))
            self.updateCell(cell: cell as! VehicleTableViewCell, row: currentIndex)
            
        }
    }
}

extension VehicleTabViewController: EmptyDataSetDelegate, EmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Towing Vehicles", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Bold", size: 20)!, NSAttributedString.Key.foregroundColor : UIColor.black])
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No vehicles have been setup. A minumum of one vehicle is required. Manually add vehicles with the PLUS button.", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 16)!])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "vehicle.png")
    }
}
