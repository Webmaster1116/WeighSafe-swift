//
//  TowChecklistViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 1/29/19.
//  Copyright © 2019 Lemonadestand Inc. All rights reserved.
//

import UIKit
import SCLAlertView

class TowChecklistViewController: UIViewController, CustomModalDelegate {
    
    let persistenceManager: PersistenceManager
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    @IBOutlet var checkButtons: [UIButton]!
    
    var selected: [Bool] = [Bool]()
    var infoButtonActive = 0
    
    required init?(coder aDecoder: NSCoder) {
        self.persistenceManager = PersistenceManager.shared
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        navigationController?.navigationBar.barTintColor = "#AB1E23".hexColor
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        
    }
    
    @objc func didEnterBackground(_ notification: Notification) {
        UserDefaults.standard.set(selected, forKey: "currentChecklist")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(selected, forKey: "currentChecklist")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let configurations = persistenceManager.fetch(Configuration.self)
        let configuration = configurations[defaults.integer(forKey: "currentConfigIndex")]
        
        let title = UILabel()
        title.textColor = UIColor.white
        title.text = "Tow Checklist: \(String(describing: configuration.name!))";
        title.font = UIFont(name: "Roboto-Bold", size: 18.0)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: title)
        
        let resetButton = UIBarButtonItem(title: "RESET", style: .done, target: self, action: #selector(resetHandler))
        resetButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 17.0)!], for: .normal)
        resetButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 17.0)!], for: .highlighted)
        resetButton.tintColor = .white
        self.navigationItem.rightBarButtonItem  = resetButton
        
        //UserDefaults.standard.set([false, false, false, false, false, false], forKey: "currentChecklist")
        
        if(UserDefaults.standard.object(forKey: "currentChecklist") == nil){
            selected = [false, false, false, false, false, false]
        }else{
            selected = UserDefaults.standard.object(forKey: "currentChecklist") as! [Bool]
        }
        
        for (index, button) in checkButtons.enumerated() {
            if(selected[index]){
                button.setImage(UIImage(named: "selected"), for: .normal)
            }else{
                button.setImage(UIImage(named: "unselected"), for: .normal)
            }
        }
        
    }
    
    @objc func resetHandler(){
        self.selected = [false, false, false, false, false, false]
        UserDefaults.standard.set(selected, forKey: "currentChecklist")
        
        self.checkButtons.forEach { (button) in
            button.setImage(UIImage(named: "unselected"), for: .normal)
        }
    }

    @IBAction func selectHandler(_ sender: UIButton) {
        
        if(self.selected[sender.tag]){
            self.checkButtons[sender.tag].setImage(UIImage(named: "unselected"), for: .normal)
        }else{
            self.checkButtons[sender.tag].setImage(UIImage(named: "selected"), for: .normal)
        }
        
        self.selected[sender.tag] = !self.selected[sender.tag]
        
        var trueCount = 0
        
        self.selected.forEach{ (value) in
            if(value){
                trueCount += 1
            }
        }
        if trueCount == 6 {
            
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
            alert.iconTintColor = "#AB1E23".hexColor
            alert.addButton("OK", backgroundColor: "#AB1E23".hexColor, textColor: .white) {
                alert.hideView()
                self.tabBarController?.selectedIndex = 0
            }
            alert.showSuccess("Congratulations", subTitle: "You completed the pre-tow safety checklist for a safer towing experience. Enjoy your ride and stay safe!")
            
            
        }
        
    }
    
    func buttonPressed(vc: CustomModal, sender: UIButton) {
        if sender.tag == 0 {
            vc.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        
        let customModal = CustomModal(nibName: "CustomModal", bundle: nil)
        customModal.providesPresentationContextTransitionStyle = true
        customModal.definesPresentationContext = true
        customModal.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        customModal.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        infoButtonActive = sender.tag
        
        let title = "Distributed Tongue Weight (DTW)"
        
        customModal.titleText = title
        customModal.width = Int(super.view.frame.size.width - 20)
        
        customModal.delegate = self
        self.present(customModal, animated: true, completion: nil)
        
    }
    
    func modalWillShow(vc: CustomModal) {
        
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: vc.containerBody.frame.size.width, height: vc.containerBody.frame.size.height)
        
        var imageName : String
        switch self.infoButtonActive {
        default:
            imageName = "HandCrankWeight"
        }
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFit
        vc.height = Int(imageView.frame.size.height)
        vc.containerBody.addSubview(imageView)
        
    }
    
}

extension UILabel{
    var defaultFont: UIFont? {
        get { return self.font }
        set { self.font = newValue }
    }
}
