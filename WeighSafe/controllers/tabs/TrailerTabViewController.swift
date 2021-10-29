//
//  TrailerViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/13/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import Foundation
import UIKit
import EmptyDataSet_Swift
import SCLAlertView

class TrailerTabViewController: UIViewController{
    
    let persistenceManager = PersistenceManager.shared
    let tableView = UITableView()
    var hitches = [Hitch]()
    var trailers = [Trailer]()
    var rowIndexSelected = -1
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
//    let defaultTrailers = [
//        ["name" : "Ragent Toy Hauler (sample)", "gvwr" : "9800", "mcc" : "2357", "coupler" : "2\""],
//        ["name" : "Travel Trailer (sample)", "gvwr" : "13570", "mcc" : "3720", "coupler" : "2\""],
//        ["name" : "Cargo Trailer (sample)", "gvwr" : "7000", "mcc" : "4230", "coupler" : "1 7/8\""]
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
        tableView.register(UINib(nibName: "TrailerTableViewCell", bundle: nil) , forCellReuseIdentifier: "trailerCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 85, right: 0)
        tableView.contentInset = insets
        
        self.trailers = self.persistenceManager.fetch(Trailer.self)
    }
    
    @objc func onPlusButtonPress(notification:Notification)
    {
        if notification.userInfo!["tab"] as! Int == 2 {
            rowIndexSelected = -1
            let vc = TrailerViewController.loadFromNib()
            vc.trailerIndex = -1
            vc.delegate = self
            
            if defaults.bool(forKey: "wizardOn") && trailers.count > 0 {
                
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
                
                alert.addButton("Add Trailer", backgroundColor: "#AB1E23".hexColor, textColor: .white) { [self] in
                    alert.hideView()
                    self.defaults.set(false, forKey: "wizardOn")
                    self.view.window?.rootViewController?.present(vc, animated: true, completion: nil)
                }
                
                alert.addButton("Keep Trailer & Skip", backgroundColor: .gray, textColor: .white) { [self] in
                    alert.hideView()
                    self.defaults.set(false, forKey: "wizardOn")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        NotificationCenter.default.post(name: Notification.Name("setSliderPosition"), object: nil, userInfo:["tab": 3])
                        NotificationCenter.default.post(name: Notification.Name("tabPress"), object: nil, userInfo:["tab": 3, "congrats": false])
                        self.defaults.set(false, forKey: "wizardOn")
                    }
                }
                
                alert.showCustom("Would you like to add a new trailer?", subTitle: "Keeping the trailer will jump to Cargo.", color: "#AB1E23".hexColor, icon: UIImage())
                
            } else {
                self.view.window?.rootViewController?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @objc func reloadTable(notification:Notification) {
        tableView.reloadData()
    }
    
    @objc func tabPress(notification:Notification){
        
        if notification.userInfo!["tab"] as! Int == 2 {
            
            if let showNewScreen = notification.userInfo!["showNewScreen"], showNewScreen as! Bool {
            
                NotificationCenter.default.post(name: Notification.Name("plusButtonPress"), object: nil, userInfo:["tab": notification.userInfo!["tab"] as! Int])
                
            }
            
        }
        
    }
    
}

extension TrailerTabViewController: UITableViewDelegate {}

extension TrailerTabViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return trailers.count
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if trailers.count > 0 {
            
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
//            label.text = "Manually add trailers with the PLUS button."
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
        if trailers.count > 0 {
            return 0
        }

        return tableView.sectionHeaderHeight
    }
    
    func updateCell(cell: TrailerTableViewCell, row: Int) {
            
        cell.name.text = trailers[row].name
        cell.empty.text = String(describing: Double(truncating: trailers[row].emptyWeight!).formattedWithSeparator)
        cell.capacity.text = String(describing: Double(truncating: trailers[row].loadCapacity!).formattedWithSeparator)
        
        cell.coupler.text = trailers[row].coupler
        
        if !self.hitches.indices.contains(defaults.integer(forKey: "currentHitchIndex")){
            self.hitches = self.persistenceManager.fetch(Hitch.self)
        }
        
        if self.hitches.indices.contains(defaults.integer(forKey: "currentHitchIndex")) {
            let hitch = self.hitches[defaults.integer(forKey: "currentHitchIndex")]
            if hitch.type == "Gooseneck" || hitch.type == "Fifth Wheel" {
                cell.coupler.text = "n/a"
            }
        }
        
        if row == defaults.integer(forKey: "currentTrailerIndex") {
            cell.button.setAttributedTitle(NSAttributedString(string: "ACTIVE", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 12)!]), for: .normal)
            cell.button.backgroundColor = "#AB1E23".hexColor
        } else {
            cell.button.setAttributedTitle(NSAttributedString(string: "SET", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 12)!]), for: .normal)
            cell.button.backgroundColor = .lightGray
        }
            
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TrailerTableViewCell = tableView.dequeueReusableCell(withIdentifier: "trailerCell", for: indexPath) as! TrailerTableViewCell
        cell.selectionStyle = .none
        cell.button.tag = indexPath.row
        cell.button.addTarget(self, action: #selector(activateButtonPress), for: .touchUpInside)
        self.updateCell(cell: cell, row: indexPath.row)
        return cell
    }
    
    @objc func activateButtonPress(sender:UIButton) {
        
        if !self.hitches.indices.contains(defaults.integer(forKey: "currentHitchIndex")){
            self.hitches = self.persistenceManager.fetch(Hitch.self)
        }
        
        let sizeOptions: [String] = [
            "2 5/16\"",
            "2\"",
            "1 7/8\""
        ]
            
        if self.hitches.indices.contains(defaults.integer(forKey: "currentHitchIndex")) {
            
            let hitch = self.hitches[defaults.integer(forKey: "currentHitchIndex")]
            let hitchBallSize = sizeOptions.firstIndex(of: hitch.ballSize!)
            let trailerCouplerSize = sizeOptions.firstIndex(of: trailers[sender.tag].coupler!)
            
            if trailerCouplerSize! >= hitchBallSize! {
                
//                let appearance = SCLAlertView.SCLAppearance(
//                    kCircleHeight: 0,
//                    kWindowWidth: view.frame.size.width - 40,
//                    kTextHeight: 65,
//                    kTextFieldHeight: 65,
//                    kTextViewdHeight: 65,
//                    kTitleFont: UIFont(name: "Roboto-Bold", size: 20)!,
//                    kTextFont: UIFont(name: "Roboto-Medium", size: 14)!,
//                    kButtonFont: UIFont(name: "Roboto-Bold", size: 14)!,
//                    showCloseButton: false,
//                    showCircularIcon: false,
//                    shouldAutoDismiss: false
//                )
//
//                let alert = SCLAlertView(appearance: appearance)
//                alert.iconTintColor = .black
//                let txt = alert.addTextField("Name this config...(i.e. Work, Camping Trip, Boating, etc..)")
//
//                alert.addButton("Save", backgroundColor: "#AB1E23".hexColor, textColor: .white) {
//                    [self] in
//
//                    let configurations = persistenceManager.fetch(Configuration.self)
//                    let currentConfigIndex = defaults.integer(forKey: "currentConfigIndex")
//                    let currentConfiguration = configurations[currentConfigIndex]
//
//                    let newConfig = Configuration(context: self.persistenceManager.context)
//
//                    if let value = txt.text, !value.isEmpty {
//                        newConfig.name = value
//                    } else {
//                        newConfig.name = "Tow Configuration #\(configurations.count + 1)"
//                    }
//
//                    newConfig.tongueWeight = 0
//                    newConfig.rearAxleToEndOfReceiver = 0
//                    newConfig.towBallToEndOfSpringBars = 0
//                    newConfig.towBallToTrailerAxle = 0
//                    newConfig.vehicle = currentConfiguration.vehicle
//                    newConfig.hitch = currentConfiguration.hitch
//                    newConfig.trailer = NSNumber(value: sender.tag)
//                    newConfig.cargo = currentConfiguration.cargo
//
//                    self.persistenceManager.save()
//                    self.defaults.set(configurations.count, forKey: "currentConfigIndex")
//
//                    let currentIndex = defaults.integer(forKey: "currentTrailerIndex")
//                    defaults.set(sender.tag, forKey: "currentTrailerIndex")
//
//                    let cell = tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0))
//                    updateCell(cell: cell as! TrailerTableViewCell, row: currentIndex)
//
//                    let buttonCell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0))
//                    updateCell(cell: buttonCell as! TrailerTableViewCell, row: sender.tag)
//
//                    NotificationCenter.default.post(name: Notification.Name("newConfig"), object: nil, userInfo:["config": newConfig])
//
//                    alert.hideView()
//                }
//
//                alert.addButton("Skip & Set as Active", backgroundColor: .gray, textColor: .white) {
//                    [self] in
                    
                    let currentIndex = defaults.integer(forKey: "currentTrailerIndex")
                    defaults.set(sender.tag, forKey: "currentTrailerIndex")
                    
                    let cell = tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0))
                    updateCell(cell: cell as! TrailerTableViewCell, row: currentIndex)
                    
                    let buttonCell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0))
                    updateCell(cell: buttonCell as! TrailerTableViewCell, row: sender.tag)
                    
                    let configurations = persistenceManager.fetch(Configuration.self)
                    let configuration = configurations[defaults.integer(forKey: "currentConfigIndex")]
                    configuration.trailer = NSNumber(value: sender.tag)
                    persistenceManager.save()
                    
//                    alert.hideView()
//                }
//                
//                alert.showCustom("Would you like to add this as a new tow configuration?", subTitle: "Enter the name of the new config and tap \"Save\".", color: "#AB1E23".hexColor, icon: UIImage())
                
            } else {
                
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
                alert.showWarning("Hitch Configuration", subTitle: "The trailer coupler is not large enough to fit the active hitch")
                
            }

        }
            
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if trailers.count > 0 {
            
            rowIndexSelected = indexPath.row
            let vc = TrailerViewController.loadFromNib()
            vc.trailerIndex = indexPath.row
            vc.delegate = self
            self.view.window?.rootViewController?.present(vc, animated: true, completion: nil)
            
        }
    }
}

extension TrailerTabViewController: DataTransit {
    func event(type: String, data: Any) {
        if type == "update"{
            if rowIndexSelected == -1 {
                
                let count = trailers.count
                trailers.append(data as! Trailer)
                
                if count == 0 {
                    tableView.reloadData()
                } else {
//                    if defaults.bool(forKey: "wizardOn") {
                        let currentIndex = defaults.integer(forKey: "currentTrailerIndex")
                        defaults.set(count, forKey: "currentTrailerIndex")
                    
                        let configurations = persistenceManager.fetch(Configuration.self)
                        let configuration = configurations[defaults.integer(forKey: "currentConfigIndex")]
                        configuration.trailer = NSNumber(value: currentIndex + 1)
                        persistenceManager.save()
                    
                        let cell = tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0))
                        updateCell(cell: cell as! TrailerTableViewCell, row: currentIndex)
//                    T
                    tableView.beginUpdates()
                    tableView.insertRows(at: [IndexPath(row: count, section: 0)], with: .automatic)
                    tableView.endUpdates()
                }
                
                if defaults.bool(forKey: "wizardOn") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        NotificationCenter.default.post(name: Notification.Name("setSliderPosition"), object: nil, userInfo:["tab": 3])
                        NotificationCenter.default.post(name: Notification.Name("tabPress"), object: nil, userInfo:["tab": 3, "congrats": count == 0 ? true : false])
                        self.defaults.set(false, forKey: "wizardOn")
                    }
                }
                
            } else {
                
                let cell = tableView.cellForRow(at: IndexPath(row: rowIndexSelected, section: 0))
                self.updateCell(cell: cell as! TrailerTableViewCell, row: rowIndexSelected)
                
            }
        }
        
        if type == "delete"{
            
            trailers.remove(at: rowIndexSelected)
            tableView.deleteRows(at: [IndexPath(row: rowIndexSelected, section: 0)], with: .automatic)
            
            let currentIndex = defaults.integer(forKey: "currentTrailerIndex")
            let cell = tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0))
            self.updateCell(cell: cell as! TrailerTableViewCell, row: currentIndex)
            
        }
    }
}

extension TrailerTabViewController: EmptyDataSetDelegate, EmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Trailers", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Bold", size: 20)!, NSAttributedString.Key.foregroundColor : UIColor.black])
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No trailers have been setup. A minumum of one trailer is required. Manually add trailers with the PLUS button.", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 16)!])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "camper-trailer.png")
    }
}
