//
//  WDFaqViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 9/1/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import UIKit

class WDFaqViewController: UIViewController {
    
    var question: NSAttributedString = NSAttributedString.init()
    var answerIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func questionPressed(_ sender: UIButton) {
        
        let vc = WDFaqAnswerViewController.loadFromNib()
        vc.answerIndex = sender.tag
        vc.question = sender.currentAttributedTitle!
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

}
