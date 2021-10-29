//
//  Step10ViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 9/11/19.
//  Copyright © 2019 Lemonadestand Inc. All rights reserved.
//

import UIKit

class Step10ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.flashScrollBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.scrollView.flashScrollIndicators()
    }
    
    private func flashScrollBar() {
        self.scrollView.flashScrollIndicators()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
            self?.flashScrollBar()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }

}
