//
//  WelcomeViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 2/3/21.
//  Copyright © 2021 Lemonadestand Inc. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func nextButtonPress(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
        tabBarController.selectedIndex = 0
        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = tabBarController
    }
}
