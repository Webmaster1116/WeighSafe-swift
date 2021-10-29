//
//  HitchViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/13/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import Foundation
import UIKit
import EmptyDataSet_Swift
import SCLAlertView

class HitchTabViewController: UIViewController{
    
    let persistenceManager = PersistenceManager.shared
    let tableView = UITableView()
    var hitches = [Hitch]()
    var rowIndexSelected = -1
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
//    let defaultHitches = [
//        ["name" : "Weigh Safe Drop Hitch", "type" : "Bumper Pull", "gvwr" : "18500", "mtw" : "2200", "ball" : "2 5/16\"", "shank" : "2.5\""],
//        ["name" : "Weigh Safe 180 Hitch", "type" : "Bumper Pull", "gvwr" : "8000", "mtw" : "1500", "ball" : "2\"", "shank" : "2\""],
//        ["name" : "True Tow Weight Distribution Hitch", "type" : "Weight Distribution", "gvwr" : "20000", "mtw" : "2000", "ball" : "2\"", "shank" : "2.5\""]
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
        tableView.register(UINib(nibName: "HitchTableViewCell", bundle: nil) , forCellReuseIdentifier: "hitchCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 85, right: 0)
        tableView.contentInset = insets
        
        self.hitches = self.persistenceManager.fetch(Hitch.self)
    }
    
    @objc func onPlusButtonPress(notification:Notification)
    {
        if notification.userInfo!["tab"] as! Int == 1 {
            rowIndexSelected = -1
            let vc = HitchViewController.loadFromNib()
            vc.hitchIndex = -1
            vc.delegate = self
            
            if defaults.bool(forKey: "wizardOn") && hitches.count > 0 {
                
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
                
                alert.addButton("Add Hitch", backgroundColor: "#AB1E23".hexColor, textColor: .white) {
                    alert.hideView()
                    self.view.window?.rootViewController?.present(vc, animated: true, completion: nil)
                }
                
                alert.addButton("Keep Hitch & Skip", backgroundColor: .gray, textColor: .white) {
                    alert.hideView()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            NotificationCenter.default.post(name: Notification.Name("setSliderPosition"), object: nil, userInfo:["tab": 2])
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            NotificationCenter.default.post(name: Notification.Name("tabPress"), object: nil, userInfo:["tab": 2, "showNewScreen": true])
                        }
                    }
                }
                
                alert.showCustom("Would you like to add a new hitch?", subTitle: "Keeping the hitch will jump to Trailers.", color: "#AB1E23".hexColor, icon: UIImage())
                
            } else {
                self.view.window?.rootViewController?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @objc func reloadTable(notification:Notification) {
        tableView.reloadData()
    }
    
    @objc func tabPress(notification:Notification){
        
        if notification.userInfo!["tab"] as! Int == 1 {
            
            if let showNewScreen = notification.userInfo!["showNewScreen"], showNewScreen as! Bool {
            
                NotificationCenter.default.post(name: Notification.Name("plusButtonPress"), object: nil, userInfo:["tab": notification.userInfo!["tab"] as! Int])
                
            }
            
        }
        
    }
    
}

extension HitchTabViewController: UITableViewDelegate {}

extension HitchTabViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return hitches.count
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if hitches.count > 0 {
            
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
//            label.text = "Manually add hitches with the PLUS button."
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
        if hitches.count > 0 {
            return 0
        }

        return tableView.sectionHeaderHeight
    }
    
    func updateCell(cell: HitchTableViewCell, row: Int) {
        
        cell.name.text = hitches[row].brand
        if hitches[row].isWeighSafeHitch == 0 && hitches[row].brand?.range(of: hitches[row].type!, options: .caseInsensitive) == nil {
            cell.name.text = hitches[row].brand! + " (\(hitches[row].type!))"
        }
        cell.tongueWeight.text = String(describing: Double(truncating: hitches[row].maxTongueWeight!).formattedWithSeparator)
        cell.ball.text = hitches[row].ballSize
        cell.shank.text = hitches[row].shankSize
        if hitches[row].type == "Gooseneck" {
            cell.ball.text = "n/a"
            cell.shank.text = "n/a"
        }
        
        if hitches[row].isWeighSafeHitch == 1 && (hitches[row].brand == "Fixed Height Ball Mount" || hitches[row].brand == "Universal Tow Ball") {
            cell.ball.text = "n/a"
            cell.shank.text = "n/a"
        }
        
        if hitches[row].isWeighSafeHitch == 1 && hitches[row].brand == "True Tow Weight Distribution Hitch" {
            cell.ball.text = "n/a"
            cell.shank.text = hitches[row].shankSize
        }
        
        if row == defaults.integer(forKey: "currentHitchIndex") {
            cell.button.setAttributedTitle(NSAttributedString(string: "ACTIVE", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 12)!]), for: .normal)
            cell.button.backgroundColor = "#AB1E23".hexColor
        } else {
            cell.button.setAttributedTitle(NSAttributedString(string: "SET", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 12)!]), for: .normal)
            cell.button.backgroundColor = .lightGray
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "hitchCell", for: indexPath) as! HitchTableViewCell
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
//            newConfig.vehicle = currentConfiguration.vehicle
//            newConfig.hitch = NSNumber(value: sender.tag)
//            newConfig.trailer = currentConfiguration.trailer
//            newConfig.cargo = currentConfiguration.cargo
//
//            if hitches[sender.tag].brand == "True Tow Weight Distribution Hitch" {
//                newConfig.holesVisible = 0.5
//            } else {
//                newConfig.holesVisible = 0.0
//            }
//
//            self.persistenceManager.save()
//            self.defaults.set(configurations.count, forKey: "currentConfigIndex")
//
//            let currentIndex = defaults.integer(forKey: "currentHitchIndex")
//            defaults.set(sender.tag, forKey: "currentHitchIndex")
//
//            let cell = tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0))
//            updateCell(cell: cell as! HitchTableViewCell, row: currentIndex)
//
//            let buttonCell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0))
//            updateCell(cell: buttonCell as! HitchTableViewCell, row: sender.tag)
//
//            NotificationCenter.default.post(name: Notification.Name("newConfig"), object: nil, userInfo:["config": newConfig])
//
//            alert.hideView()
//        }
//
//        alert.addButton("Skip & Set as Active", backgroundColor: .gray, textColor: .white) {
//            [self] in
            
            let configurations = persistenceManager.fetch(Configuration.self)
            let configuration = configurations[defaults.integer(forKey: "currentConfigIndex")]
            
            let currentIndex = defaults.integer(forKey: "currentHitchIndex")
            defaults.set(sender.tag, forKey: "currentHitchIndex")
            
            let cell = tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0))
            updateCell(cell: cell as! HitchTableViewCell, row: currentIndex)
            
            let buttonCell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0))
            updateCell(cell: buttonCell as! HitchTableViewCell, row: sender.tag)
            
            configuration.hitch = NSNumber(value: sender.tag)
            
            if hitches[sender.tag].brand == "True Tow Weight Distribution Hitch" {
                configuration.holesVisible = 0.5
            } else {
                configuration.holesVisible = 0.0
            }
            persistenceManager.save()
            
//            alert.hideView()
//        }
//        
//        alert.showCustom("Would you like to add this as a new tow configuration?", subTitle: "Enter the name of the new config and tap \"Save\".", color: "#AB1E23".hexColor, icon: UIImage())
            
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if hitches.count > 0 {
            
            rowIndexSelected = indexPath.row
            let vc = HitchViewController.loadFromNib()
            vc.hitchIndex = indexPath.row
            vc.delegate = self
            self.view.window?.rootViewController?.present(vc, animated: true, completion: nil)
            
        }
        
    }
}

extension HitchTabViewController: DataTransit {
    func event(type: String, data: Any) {
        if type == "update"{
            if rowIndexSelected == -1 {
                
                let count = hitches.count
                hitches.append(data as! Hitch)
                if (data as! Hitch).isWeighSafeHitch == 1 &&  (data as! Hitch).brand == "True Tow Weight Distribution Hitch" {
                    self.defaults.set(true, forKey: "trueTowGuideOn")
                }
                
                if count == 0 {
                    tableView.reloadData()
                } else {
//                    if defaults.bool(forKey: "wizardOn") {
                        let currentIndex = defaults.integer(forKey: "currentHitchIndex")
                        defaults.set(count, forKey: "currentHitchIndex")
                    
                        let configurations = persistenceManager.fetch(Configuration.self)
                        let configuration = configurations[defaults.integer(forKey: "currentConfigIndex")]
                        configuration.hitch = NSNumber(value: currentIndex + 1)
                        persistenceManager.save()
                    
                        let cell = tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0))
                        updateCell(cell: cell as! HitchTableViewCell, row: currentIndex)
//                    }
                    tableView.beginUpdates()
                    tableView.insertRows(at: [IndexPath(row: count, section: 0)], with: .automatic)
                    tableView.endUpdates()
                }
                
                if defaults.bool(forKey: "wizardOn") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        NotificationCenter.default.post(name: Notification.Name("setSliderPosition"), object: nil, userInfo:["tab": 2])
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        NotificationCenter.default.post(name: Notification.Name("tabPress"), object: nil, userInfo:["tab": 2, "showNewScreen": true])
                    }
                }
                
            } else {
                
                let cell = tableView.cellForRow(at: IndexPath(row: rowIndexSelected, section: 0))
                self.updateCell(cell: cell as! HitchTableViewCell, row: rowIndexSelected)
                
            }
        }
        
        if type == "delete"{
            
            hitches.remove(at: rowIndexSelected)
            tableView.deleteRows(at: [IndexPath(row: rowIndexSelected, section: 0)], with: .automatic)
            
            let currentIndex = defaults.integer(forKey: "currentHitchIndex")
            let cell = tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0))
            self.updateCell(cell: cell as! HitchTableViewCell, row: currentIndex)
            
        }
    }
}

extension HitchTabViewController: EmptyDataSetDelegate, EmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Hitches", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Bold", size: 20)!, NSAttributedString.Key.foregroundColor : UIColor.black])
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No hitches have been setup. A minumum of one hitch is required. Manually add hitches with the PLUS button.", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 16)!])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "hitch.png")
    }
}
