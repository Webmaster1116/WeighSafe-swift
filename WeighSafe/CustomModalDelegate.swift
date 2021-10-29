//
//  CustomModalDelegate.swift
//  WeighSafe
//
//  Created by Brian Barton on 2/21/18.
//  Copyright © 2018 Lemonadestand Inc. All rights reserved.
//

import UIKit

protocol CustomModalDelegate: class {
    func modalWillShow(vc: CustomModal)
    func buttonPressed(vc: CustomModal, sender: UIButton)
}

extension CustomModalDelegate {
    func modalWillShow(vc: CustomModal) {
        
    }
}
