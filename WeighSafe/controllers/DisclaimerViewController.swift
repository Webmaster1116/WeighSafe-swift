//
//  DisclaimerViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 11/25/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import UIKit
import PDFKit
import SCLAlertView

class DisclaimerViewController: UIViewController {

    @IBOutlet weak var termsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func viewTermsButtonPress(_ sender: UIButton) {
//        if let url = URL(string: "https://www.weigh-safe.com/mobile-app-terms-conditions") {
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(url)
//            } else {
//                UIApplication.shared.openURL(url)
//            }
//        }
        
        let pdfView = PDFView(frame: CGRect(x: 0, y: 0, width: 0, height: view.frame.size.height - 350))
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let appearance = SCLAlertView.SCLAppearance(
            kCircleHeight: 0,
            kWindowWidth: view.frame.size.width - 10,
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
        alert.iconTintColor = .black
        
        alert.customSubview = pdfView

        pdfView.autoScales = true
        pdfView.pageShadowsEnabled = false
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let fileURL = Bundle.main.url(forResource: "TOU-V1", withExtension: "pdf")
        pdfView.document = PDFDocument(url: fileURL!)
        
        alert.addButton("Close", backgroundColor: .gray, textColor: .white) {
            alert.hideView()
        }
        
        alert.showSuccess("Terms & Conditions", subTitle: "")
    }
    
    @IBAction func closeButtonPress(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController")
        
        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = vc
    }

}
