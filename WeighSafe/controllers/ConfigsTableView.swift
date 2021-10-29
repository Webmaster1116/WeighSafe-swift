//
//  ConfigsTableView.swift
//  WeighSafe
//
//  Created by Brian Barton on 3/19/21.
//  Copyright © 2021 Lemonadestand Inc. All rights reserved.
//

import UIKit
import SCLAlertView

class ConfigsTableView: UITableView {
    
    let persistenceManager = PersistenceManager.shared
    
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    var configurations = [Configuration]()
    
    var configsDelegate: ConfigsTableViewDelegate?
    
    var parentVC = ""
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configurations = persistenceManager.fetch(Configuration.self) // GET CONFIGURATIONS STORED IN COREDATA
        
        dataSource = self
        delegate = self
        
    }
    
    func toggleTable(){
        self.isHidden = !self.isHidden
    }
}

extension ConfigsTableView: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.configurations.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (cell.responds(to: #selector(setter: UITableViewCell.separatorInset))) {
            cell.separatorInset = UIEdgeInsets.zero
        }

        if (cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins))) {
            cell.preservesSuperviewLayoutMargins = false
        }

        if (cell.responds(to: #selector(setter: UIView.layoutMargins))) {
            cell.layoutMargins = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = self.configurations[indexPath.row].name
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont(name: "Roboto-Bold", size: 16.0)
        cell.backgroundColor = UIColor(red:0.67, green:0.12, blue:0.14, alpha:1)
        cell.tintColor = .white
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red:0.67, green:0.12, blue:0.14, alpha:0)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if parentVC == "setup" {
            let frame: CGRect = tableView.frame
            let addButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 42))
            addButton.setTitle("+ Add Tow Configuration", for: .normal)
            addButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 16.0)
            addButton.contentHorizontalAlignment = .left
            addButton.contentEdgeInsets.left = 25
            addButton.backgroundColor = UIColor(red:0.67, green:0.12, blue:0.14, alpha:1)
            addButton.addTarget(self, action: #selector(addButtonHandler), for: .touchUpInside)
            let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 42))
            let borderView = UIView(frame: CGRect(x: 0, y: 42, width: frame.size.width, height: 1))
            borderView.backgroundColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.1)
            headerView.backgroundColor = .white
            headerView.addSubview(addButton)
            headerView.addSubview(borderView)
            return headerView
        }else{
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if parentVC == "setup" {
            return 40
        }else{
            return 0
        }
    }
    
    @objc func addButtonHandler(sender:UIButton){
        
        self.isHidden = true
        
        configsDelegate?.addButtonPress(tableView: self, sender: sender)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.isHidden = true
        
        configsDelegate?.didSelectConfig(tableView: self, indexPath: indexPath, config: configurations[indexPath.row])
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var actionButtons = [UIContextualAction]()
        
        let deleteBtn = UIContextualAction(style: .normal, title: "DELETE") {  (contextualAction, view, boolValue) in
            let config = self.configurations[indexPath.row]
            self.configurations.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            if(indexPath.row < self.defaults.integer(forKey: "currentConfigIndex")){
                self.defaults.set(self.defaults.integer(forKey: "currentConfigIndex") - 1, forKey: "currentConfigIndex")
            }
            self.persistenceManager.delete(config)
            
            self.configsDelegate?.deleteButtonPress(tableView: self, config: self.configurations[indexPath.row])
            
        }
        
        deleteBtn.backgroundColor = UIColor(red:0.67, green:0.12, blue:0.14, alpha:1)
        
        let editBtn = UIContextualAction(style: .normal, title: "EDIT") {  (contextualAction, view, boolValue) in
            
            self.isHidden = true
            
            self.configsDelegate?.editButtonPress(tableView: self, indexPath: indexPath, config: self.configurations[indexPath.row])
            
        }
        
        editBtn.backgroundColor = UIColor(red:0.67, green:0.12, blue:0.14, alpha:1)
        
        actionButtons.append(editBtn)
        
        if(self.configurations.count > 1 && indexPath.row != self.defaults.integer(forKey: "currentConfigIndex")){
            actionButtons.append(deleteBtn)
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: actionButtons)

        return swipeActions
        
    }
}
