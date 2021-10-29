//
//  NotesViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 11/11/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {
    
    let persistenceManager: PersistenceManager
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    @IBOutlet weak var textView: UITextView!
    
    required init?(coder aDecoder: NSCoder) {
        self.persistenceManager = PersistenceManager.shared
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let configurations = persistenceManager.fetch(Configuration.self)
        let configuration = configurations[defaults.integer(forKey: "currentConfigIndex")]

        let title = UILabel()
        title.textColor = UIColor.white
        title.text = "Notes: \(String(describing: configuration.name!))";
        title.font = UIFont(name: "Roboto-Bold", size: 18.0)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: title)
        
        let saveButton = UIBarButtonItem(title: "SAVE", style: .done, target: self, action: #selector(saveHandler))
        saveButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 17.0)!], for: .normal)
        saveButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 17.0)!], for: .highlighted)
        saveButton.tintColor = .white
        self.navigationItem.rightBarButtonItem  = saveButton
        
        navigationController?.navigationBar.barTintColor = "#AB1E23".hexColor
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        
        let bar = UIToolbar(frame: CGRect(x:0, y:0, width:view.frame.size.width, height:40.0))
        var image = UIImage(named: "arrow")
        if #available(iOS 13.0, *) {
            image = UIImage(systemName: "keyboard.chevron.compact.down")
        }
        let doneButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(doneButtonPress))
        doneButton.tintColor = "#ac2520".hexColor
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        bar.items = [flexibleSpace, doneButton]
        bar.sizeToFit()
        
        textView.inputAccessoryView = bar
        
        let cachedNotes = defaults.string(forKey: "Configuration\(defaults.integer(forKey: "currentConfigIndex"))Notes")
        
        if let notes = cachedNotes {
            textView.text = notes
        }
    }
    
    @objc func doneButtonPress(){
        textView.resignFirstResponder()
        saveHandler()
    }
    
    @objc func saveHandler(){
        defaults.set(textView.text, forKey: "Configuration\(defaults.integer(forKey: "currentConfigIndex"))Notes")
    }

}
