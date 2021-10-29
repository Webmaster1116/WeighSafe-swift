//
//  CargoViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/13/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import Foundation
import UIKit
import EmptyDataSet_Swift
import SCLAlertView

class CargoTabViewController: UIViewController{
    
    let persistenceManager = PersistenceManager.shared
    let tableView = UITableView()
    var cargos = [Cargo]()
    var rowIndexSelected = -1
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//    let defaultCargos = [
//        ["name" : "Passengers", "weight" : "500", "type" : "Vehicle"],
//        ["name" : "ATV(s)", "weight" : "1100", "type" : "Trailer"],
//        ["name" : "UTV", "weight" : "2000", "type" : "Trailer"],
//        ["name" : "Fresh Water Tank", "weight" : "400", "type" : "Trailer"],
//        ["name" : "Luggage", "weight" : "150", "type" : "Vehicle"],
//        ["name" : "Miscellaneous", "weight" : "250", "type" : "Trailer"]
//    ]
    var defaultsSelected : [Int] = []
    
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
        tableView.register(UINib(nibName: "CargoTableViewCell", bundle: nil) , forCellReuseIdentifier: "cargoCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 44
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 85, right: 0)
        tableView.contentInset = insets
        
        self.cargos = self.persistenceManager.fetch(Cargo.self)
        
    }
    
    @objc func tabPress(notification:Notification){
        
        if notification.userInfo!["tab"] as! Int == 3 {
            
            if let congrats = notification.userInfo!["congrats"], congrats as! Bool {
            
                if(self.cargos.count == 0){
                    
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
                    
                    alert.addButton("Go to Home", backgroundColor: "#ac2520".hexColor, textColor: .white) {
                        
                        alert.hideView()
                        
                        UIApplication.topViewController()?.tabBarController?.selectedIndex = 0
//                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//                        let tBarController = storyboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
//                        tBarController.selectedIndex = 2
//                        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = tabBarController
                        
                    }
                    
//                    alert.addButton("View Checklist", backgroundColor: "#ac2520".hexColor, textColor: .white) {
//
//                        alert.hideView()
//                        
//                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//                        let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
//                        tabBarController.selectedIndex = 2
//                        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = tabBarController
//
//                    }
                    
                    alert.addButton("Close", backgroundColor: .gray, textColor: .white) {
                        alert.hideView()
                    }
                    
                    let configurations = persistenceManager.fetch(Configuration.self)
                    let configuration = configurations[defaults.integer(forKey: "currentConfigIndex")]
                    
                    alert.showSuccess("Congratulations", subTitle: "You have completed your first tow configuration - \(String(describing: configuration.name!)). If you would like to add cargo tap \"Close\", otherwise tap \"Go to Home\" to complete your tow configuration.")
                    
                }
                
            }
            
        }
        
    }
        
    @objc func onPlusButtonPress(notification:Notification)
    {
        
        if notification.userInfo!["tab"] as! Int == 3 {
            
            rowIndexSelected = -1
            let vc = CargoViewController.loadFromNib()
            vc.cargoIndex = -1
            vc.delegate = self
            self.view.window?.rootViewController?.present(vc, animated: true, completion: nil)
               
        }
    }
    
    @objc func reloadTable(notification:Notification) {
        tableView.reloadData()
    }
    
}

extension CargoTabViewController: UITableViewDelegate {}

extension CargoTabViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return cargos.count
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let bgView = UIView()
        bgView.backgroundColor = "#f0f0f0".hexColor
        
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = UIFont(name: "Roboto-Bold", size: 14)
        label.textColor = "#555".hexColor
        label.text = "Cargo is common items that you load on your vehicle or trailer. The \"Home\" screen allows you to adjust cargo weight manually for the vehicle and/or trailer at any time."
        label.translatesAutoresizingMaskIntoConstraints = false
        bgView.addSubview(label)
        
        label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10).isActive = true
        label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10).isActive = true
        label.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 10).isActive = true
        label.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -10).isActive = true
        
        return bgView
    }
    
    func updateCell(cell: CargoTableViewCell, row: Int) {
        
        cell.name.text = cargos[row].name
        cell.weight.text = String(describing: Double(truncating: cargos[row].cargoWeight!).formattedWithSeparator)
        cell.type.text = cargos[row].type?.capitalized
        
        let cargoActive = defaults.array(forKey: "currentCargoIndexes")! as Array
        
        if cargoActive.firstIndex(where: { $0 as! Int == row }) != nil {
            cell.button.setAttributedTitle(NSAttributedString(string: "ACTIVE", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 12)!]), for: .normal)
            cell.button.backgroundColor = "#AB1E23".hexColor
        } else {
            cell.button.setAttributedTitle(NSAttributedString(string: "SET", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 12)!]), for: .normal)
            cell.button.backgroundColor = .lightGray
        }
            
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CargoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cargoCell", for: indexPath) as! CargoTableViewCell
        cell.selectionStyle = .none
        cell.button.tag = indexPath.row
        cell.button.addTarget(self, action: #selector(activateButtonPress), for: .touchUpInside)
        self.updateCell(cell: cell, row: indexPath.row)
        return cell
    }
    
    @objc func activateButtonPress(sender:UIButton) {
           
        var cargoActive = defaults.array(forKey: "currentCargoIndexes")! as Array
        
        if let index = cargoActive.firstIndex(where: { $0 as! Int == sender.tag }) {
            cargoActive.remove(at: index)
            sender.setAttributedTitle(NSAttributedString(string: "SET", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 12)!]), for: .normal)
            sender.backgroundColor = .lightGray
        } else {
            cargoActive.append(sender.tag)
            sender.setAttributedTitle(NSAttributedString(string: "ACTIVE", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 12)!]), for: .normal)
            sender.backgroundColor = "#AB1E23".hexColor
        }

        defaults.set(cargoActive, forKey: "currentCargoIndexes")
        
        var nsarray = [NSNumber]()
        var arrayOfDicts = [[String:String]]()
        arrayOfDicts.append(["title" : "", "body" : "", "date" : ""])
        
        for i in cargoActive {
            nsarray.append(i as! NSNumber)
        }
        let configurations = persistenceManager.fetch(Configuration.self)
        let configuration = configurations[defaults.integer(forKey: "currentConfigIndex")]
        configuration.cargo = nsarray
        persistenceManager.save()
            
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cargos.count > 0 {
            
            rowIndexSelected = indexPath.row
            let vc = CargoViewController.loadFromNib()
            vc.cargoIndex = indexPath.row
            vc.delegate = self
            self.view.window?.rootViewController?.present(vc, animated: true, completion: nil)
            
        }
    }
}

extension CargoTabViewController: DataTransit {
    func event(type: String, data: Any) {
        
        if type == "update"{
            
            if rowIndexSelected == -1 {
                
                let count = cargos.count
                cargos.append(data as! Cargo)
                
                if count == 0 {
                    tableView.reloadData()
                } else {
                    tableView.beginUpdates()
                    tableView.insertRows(at: [IndexPath(row: cargos.count - 1, section: 0)], with: .automatic)
                    tableView.endUpdates()
                }
                
            } else {
                
                let cell = tableView.cellForRow(at: IndexPath(row: rowIndexSelected, section: 0))
                self.updateCell(cell: cell as! CargoTableViewCell, row: rowIndexSelected)
                
            }
            
        }
        
        if type == "delete" {
            
            cargos.remove(at: rowIndexSelected)
            tableView.deleteRows(at: [IndexPath(row: rowIndexSelected, section: 0)], with: .automatic)
            
        }
    }
}

extension CargoTabViewController: EmptyDataSetDelegate, EmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Cargo", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Bold", size: 20)!, NSAttributedString.Key.foregroundColor : UIColor.black])
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No cargo has been setup. Cargo is additional items or vehicles that count toward load capacity.", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 16)!])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "cargo.png")
    }
}
