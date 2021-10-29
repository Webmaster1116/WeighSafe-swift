//
//  WDWarrantyViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 9/1/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import UIKit
import PDFKit

class WDWarrantyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        let url = URL(string: "https://www.weigh-safe.com/warranty")!
//        webView.load(URLRequest(url: url))
//        webView.allowsBackForwardNavigationGestures = true
        
        let pdfView = PDFView(frame: CGRect(x: 0, y: 55, width: self.view.frame.size.width, height: self.view.frame.size.height - 55))
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(pdfView)

        // Fit content in PDFView.
        pdfView.autoScales = true

        // Load Sample.pdf file from app bundle.
        let fileURL = Bundle.main.url(forResource: "Weigh-Safe-True-Tow-Weight-Distribution-Hitch-Limited-Lifetime-Warranty", withExtension: "pdf")
        pdfView.document = PDFDocument(url: fileURL!)
        
    }

}
