//
//  CustomModal.swift
//  WeighSafe
//
//  Created by Brian Barton on 2/21/18.
//  Copyright © 2018 Lemonadestand Inc. All rights reserved.
//

import UIKit
import ZoomableUIView

class CustomModal: UIViewController {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var containerTop: UIView!
    @IBOutlet weak var containerBottom: UIView!
    @IBOutlet weak var containerBody: UIView!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet weak var containerWidth: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buttonsView: UIStackView!
    var delegate: CustomModalDelegate?
    
    var containerColor = UIColor.white
    var titleText = "Title"
    var height: Int = 400
    var width: Int = 343
    
    var data: [String:String] = [String:String]()
    var buttons: [UIButton] = [UIButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerHeight.constant = CGFloat(height)
        containerWidth.constant = CGFloat(width)
        self.view.layoutIfNeeded()
        
        titleLabel.text = titleText
        titleLabel.font = UIFont(name: "Roboto-Bold", size: 18.0)
        
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        
        let defaultButton = UIButton()
        defaultButton.setTitle("CLOSE", for: .normal)
        defaultButton.setTitleColor(.black, for: .normal)
        defaultButton.titleLabel?.font = UIFont(name: "Roboto-Bold", size: 18.0)
        buttons.append(defaultButton)
        
        delegate?.modalWillShow(vc: self)
        
        var i = 0
        for button in buttons {
            
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            
            button.tag = i
            buttonsView.addArrangedSubview(button)
            
            i = i + 1
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        containerTop.backgroundColor = containerColor
        containerBottom.backgroundColor = containerColor
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func buttonPressed(sender: UIButton){
        
        delegate?.buttonPressed(vc: self, sender: sender)
        
    }
    
}

extension CustomModal: ZoomableUIView {
    func reset() {
        
    }
    
    func viewForZooming() -> UIView {
        return self.containerBody
    }
    
    func optionsForZooming() -> ZoomableViewOptions {
        return ZoomableViewOptions.init(minZoom: 1.0, maxZoom: 2.0)
    }
}
