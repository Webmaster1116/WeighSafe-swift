//
//  TextField.swift
//  WeighSafe
//
//  Created by Brian Barton on 5/1/18.
//  Copyright © 2018 Lemonadestand Inc. All rights reserved.
//

import UIKit

extension UITextField {
    @IBInspectable
    var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    @IBInspectable
    var borderBottom: Bool{
        get{
            return self.borderBottom
        }
        set (hasDone) {
            if hasDone{
                self.borderStyle = .none
                
                let border = UIView(frame: CGRect(x: 0, y: self.frame.size.height - 2, width: self.frame.size.width, height: 2))
                border.backgroundColor = UIColor.black
                
                self.addSubview(border)
                
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        done.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: "#AC1F24".hexColor], for: .normal)
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
    
}
