//
//  WDfaqAnswerViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 9/1/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import UIKit

class WDFaqAnswerViewController: UIViewController {

    @IBOutlet weak var answerLabel: UILabel!
    
    var answerIndex = 0
    var question: NSAttributedString = NSAttributedString.init()
    let answers = [
        "<p>Yes, you can. The purpose of the weight distribution hitch is to return any weight that is lost off the front axle of the tow vehicle when the trailer is attached. It is not meant to take away all the squat in the truck. The tongue weight of the trailer still exists and is added to the back axle causing compression on the springs. If you would like to reduce that remaining squat in the back of your tow vehicle, feel free to use air bags or any other anti-squat system. Just make sure you check that your DTW (distributed tongue weight) is correct for every tow with or without air bags.</p>",
        "<p>If the lead screw is not turning, there are a few things you can check to solve the problem.</p><ul><li style=\"margin-bottom:10px;\">Make sure the lead screw is not bottomed out. The lower pivot system only has so much travel and will bottom out between the internal gauge shield and the top of the pivot system. If this is the case, raise the height of your trailer bracket platforms and again, try to adjust the screw until you reach your DTW.</li><li style=\"margin-bottom:10px;\">Has your lead screw been serviced with grease lately? Make sure to use the grease ports and bi-annually (if not more frequently) pump in grease to keep the frictional surfaces lubricated. Without lubrication, it can increase friction and ware, keeping the lead screw from turning.</li><li style=\"margin-bottom:10px;\">Large amounts of torque may be needed. With large trailers reaching the maximum ratings on the hitch, sometimes the loads will require large amounts of torque to adjust the lead screw. If this is the case, raise the tongue jack to lower the forces on the lead screw. Adjust the lead screw in or out, depending on what is needed, and put the tongue jack down periodically to check if you have reached the required DTW.</li></ul>",
        "<p>The purpose of the weight distribution hitch is to return any weight that is lost off the front axle of the tow vehicle when the trailer is attached. It is not meant to take away all the squat in the truck. The tongue weight of the trailer still exists and is added to the back axle causing compression on the springs. If you would like to reduce that remaining squat in the back of your tow vehicle, feel free to use air bags or any other anti-squat system. Just make sure you check that your DTW (distributed tongue weight) is correct for every tow with or without air bags.</p>",
        "<p>If you feel that your truck is still squatting more than normal even after you have adjusted True Tow hitch to reach the DTW that you determined from the DTW tool, double check the following. Check your tow vehicle ratings and make sure you are not towing over the weight capacity. Check that all measurements and the tongue weight without the spring arms attached were inputted correctly into the DTW tool to ensure you have the correct DTW. The DTW should be about 2-3 times more than the original tongue weight of the trailer. If this is not so, something must be wrong. Please contact our Customer Support team so we can look further into resolving this for you.</p>",
        "<p>If you see any clear, odorless oil leaking from the hitch, please check all hydraulic plugs, gauges, and the piston under the tow ball to see if one of these areas are leaking. If so, please contact our Customer Support team to get your True Tow hitch repaired under warranty.</p>",
        "<p>If you notice your gauge is not measuring tongue weight, there could be a couple of causes for this. Please check the following prior to calling our Customer Support team.</p><ul><li>Tongue weight is less then 200 lbs. If your trailer tongue is less the 200 lbs., the gauge has a hard time reading this low of a tongue weight. Please increase your tongue weight to be over 300 lbs. to ensure your gauge is not working.</li><li>Hydraulic oil leak. Without hydraulic fluid, the gauge will not read weight. If you see any clear, odorless oil leaking from the hitch, please check all hydraulic plugs, gauges, and the piston under the tow ball to see if one of these are leaking.  If so, please contact our Customer Support team to get your True Tow hitch repaired under warranty.</li></ul>",
        "<p>The True Tow Weight Distribution Hitch is painted with a high-strength powder coating for rust and corrosion resistance. Through normal ware, especially in high-friction points on the hitch, the paint could rub or chip off.  If you are seeing this, you can use a flat black primer and paint to touch up these areas to reduce rust and corrosion, which will extend the life of your hitch.</p>"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationItem.title = question.string
        
        do {
            let str = "<div style='padding: 25px; font-family: Arial; font-size:18px;'>\(self.answers[answerIndex])</div>"
            let attrStr = try NSAttributedString(
                data: str.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
                options: [
                    NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html
                ],
                documentAttributes: nil
            )
            
            answerLabel.attributedText = attrStr
        } catch let error {
            print(error)
        }
    }

}
