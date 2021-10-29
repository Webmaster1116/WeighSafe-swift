//
//  Step8ViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/21/19.
//  Copyright © 2019 Lemonadestand Inc. All rights reserved.
//

import UIKit

class Step8ViewController: UIViewController, UIScrollViewDelegate {
    
    let persistenceManager: PersistenceManager
    let defaults = UserDefaults.standard
    var configurations = [Configuration]()

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var dtwLabel: UILabel!
    @IBOutlet weak var safezone: UIStackView!
    @IBOutlet weak var dtwTarget: UILabel!
    @IBOutlet weak var dtwMin: UILabel!
    @IBOutlet weak var dtwMax: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        self.persistenceManager = PersistenceManager.shared
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.safezone.isHidden = true
        self.configurations = persistenceManager.fetch(Configuration.self) // GET CONFIGURATIONS STORED IN COREDATA
        flashScrollBar()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.stackView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.safezone.isHidden = true
        self.scrollView.flashScrollIndicators()
        
        let config = self.configurations[defaults.integer(forKey: "currentConfigIndex")]
        
        if config.towBallToEndOfSpringBars != 0 && config.towBallToTrailerAxle != 0 && config.rearAxleToEndOfReceiver != 0 && config.tongueWeight != 0 {
            
            let nominator = 1 - (Double(truncating: config.towBallToEndOfSpringBars!) / Double(truncating: config.towBallToTrailerAxle!))
            
            let denominator = (Double(truncating: config.towBallToEndOfSpringBars!) / Double(truncating: config.rearAxleToEndOfReceiver!)) + (Double(truncating: config.towBallToEndOfSpringBars!) / Double(truncating: config.towBallToTrailerAxle!))
            
            let result = 1 + (nominator / denominator)
            
            let numFormatter = NumberFormatter()
            
            let tw = Double(truncating: config.tongueWeight!)
            
            var minPercent = 0.95
            var targetPercent = 1.0
            var maxPercent = 1.05
            
            if tw >= 500 && tw <= 999 {
                minPercent = 0.85
                targetPercent = 0.90
                maxPercent = 0.95
            } else if tw >= 1000 && tw <= 1499 {
                minPercent = 0.75
                targetPercent = 0.80
                maxPercent = 0.85
            } else if tw >= 1499 {
                minPercent = 0.70
                targetPercent = 0.75
                maxPercent = 0.80
            }
            
            let FALR = Double(truncating: config.tongueWeight!) * result
            
            numFormatter.groupingSeparator = ","
            numFormatter.groupingSize = 3
            numFormatter.usesGroupingSeparator = true
            
            self.dtwLabel.isHidden = true
            self.safezone.isHidden = false
            self.dtwTarget.text = numFormatter.string(from: roundUp((FALR * targetPercent), toNearest: 50) as NSNumber)!
            self.dtwMin.text = numFormatter.string(from: roundUp((FALR * minPercent), toNearest: 50) as NSNumber)!
            self.dtwMax.text = numFormatter.string(from: roundUp((FALR * maxPercent), toNearest: 50) as NSNumber)!
            
            self.defaults.set(false, forKey: "trueTowGuideOn")
            
            
        }else{
            
            self.dtwLabel.isHidden = false
            self.safezone.isHidden = true
            //self.dtwLabel.text = "---"
            Toast.show(message: "Unable to calculate Distributed Tongue Weight. All fields in previous pages must be filled in.", controller: self)
            
        }
    }
    
    private func flashScrollBar() {
        self.scrollView.flashScrollIndicators()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
            self?.flashScrollBar()
        }
    }
    
    func roundUp(_ value: Double, toNearest: Double) -> Double {
        return ceil(value / toNearest) * toNearest
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    @IBAction func exitGuide(_ sender: UIButton) {
        
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
//        tabBarController.selectedIndex = 2
//        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = tabBarController
        //dismiss(animated: true, completion: nil)
        
        let pageViewController = self.parent as! InstructionsPageViewController
        pageViewController.goToPreviousPage()
        
    }

    @IBAction func nextPage(_ sender: UIButton) {
        let pageViewController = self.parent as! InstructionsPageViewController
        pageViewController.goToNextPage()
    }
}
