//
//  ConfigsTableViewDelegate.swift
//  WeighSafe
//
//  Created by Brian Barton on 3/19/21.
//  Copyright © 2021 Lemonadestand Inc. All rights reserved.
//

import UIKit

protocol ConfigsTableViewDelegate: class {
    func addButtonPress(tableView: ConfigsTableView, sender: UIButton)
    func editButtonPress(tableView: ConfigsTableView, indexPath: IndexPath, config: Configuration)
    func deleteButtonPress(tableView: ConfigsTableView, config: Configuration)
    func didSelectConfig(tableView: ConfigsTableView, indexPath: IndexPath, config: Configuration)
}
