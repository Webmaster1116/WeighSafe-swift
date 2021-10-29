//
//  Step7ViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 9/11/19.
//  Copyright © 2019 Lemonadestand Inc. All rights reserved.
//

import UIKit

class Step7ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flashScrollBar()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.stackView
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
