//
//  Step0ViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 9/11/19.
//  Copyright © 2019 Lemonadestand Inc. All rights reserved.
//

import UIKit

class Step0ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    @IBAction func watchVideoButton(_ sender: UIButton) {
        if let url = NSURL(string: "https://www.youtube.com/watch?v=ABNtxJTER1A"){
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func skipGuideButtonPress(_ sender: Any) {
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
//        tabBarController.selectedIndex = 0
//        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = tabBarController
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextPage(_ sender: UIButton) {
        let pageViewController = self.parent as! InstructionsPageViewController
//        pageViewController.setViewControllers([pageViewController.orderedViewControllers[1]], direction: .forward, animated: true, completion: nil)
//        pageViewController.pageControl.currentPage = 1
        pageViewController.goToNextPage()
    }
}
