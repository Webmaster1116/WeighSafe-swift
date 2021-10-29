//
//  WeightDistributionMenuViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/31/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import UIKit

class WeightDistributionMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func videoButtonPress(_ sender: UIButton) {
        if let url = NSURL(string: "https://www.youtube.com/watch?v=ABNtxJTER1A"){
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func instructionGuideButtonPress(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "instructionPageViewController")
        //UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = vc
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func warrantyButtonPress(_ sender: UIButton) {
        let vc = WDWarrantyViewController.loadFromNib()
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func maintenanceButtonPress(_ sender: UIButton) {
        let vc = WDMaintenanceViewController.loadFromNib()
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func faqButtonPress(_ sender: UIButton) {
        let vc = WDFaqViewController.loadFromNib()
        vc.navigationItem.title = "Frequently Asked Questions"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func contactButtonPress(_ sender: UIButton) {
        let vc = ContactViewController.loadFromNib()
        present(vc, animated: true, completion: nil)
    }
}
