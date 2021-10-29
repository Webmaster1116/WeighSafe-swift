//
//  TrailerTableViewCell.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/17/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import UIKit

class TrailerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var empty: UILabel!
    @IBOutlet weak var capacity: UILabel!
    @IBOutlet weak var coupler: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        name.font = UIFont(name: "Roboto-Bold", size: 20)
        empty.font = UIFont(name: "Roboto-Medium", size: 18)
        capacity.font = UIFont(name: "Roboto-Medium", size: 18)
        coupler.font = UIFont(name: "Roboto-Medium", size: 18)
        
        button.setAttributedTitle(NSAttributedString(string: "SET", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 12)!]), for: .normal)
        button.backgroundColor = .lightGray
        button.tintColor = .white
        button.layer.cornerRadius = 0.5 * button.bounds.size.height
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

//        let separatorLineHeight: CGFloat = 3
//        let separator = UIView()
//        separator.backgroundColor = "#f3f3f3".hexColor
//        separator.frame = CGRect(x: self.frame.origin.x, y: self.frame.size.height - separatorLineHeight, width: self.frame.size.width, height: separatorLineHeight)
//
//        self.addSubview(separator)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
