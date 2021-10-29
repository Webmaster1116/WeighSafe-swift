//
//  VinLookupTableViewController.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/21/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift
import SwiftyJSON
import Alamofire
import Vision
import VisionKit

class VinLookupTableViewController: UITableViewController {
    
    weak var delegate: DataTransit? = nil
    var vehicles = [[String:String]]()
    var tableViewHeader = ""
    
    private var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if vehicles.count == 0 {
            tableView.separatorStyle = .none
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 40.0
        //self.clearsSelectionOnViewWillAppear = false
        
        configureOCR()

    }
    
    private func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }

//        ocrTextView.text = ""
//        scanButton.isEnabled = false
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([self.ocrRequest])
        } catch {
            print(error)
        }
    }
    
    private func configureOCR() {
        ocrRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var ocrText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                
                ocrText += topCandidate.string + "\n"
            }
            
            
            DispatchQueue.main.async {
                print("SCAN OUTPUT")
                print(ocrText)
//                self.scanButton.isEnabled = true
            }
        }
        
        ocrRequest.recognitionLevel = .accurate
        ocrRequest.recognitionLanguages = ["en-US", "en-GB"]
        ocrRequest.usesLanguageCorrection = true
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vehicles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = vehicles[indexPath.row]["name"]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewHeader
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Roboto-Medium", size: 14.0)
        header.textLabel?.textAlignment = NSTextAlignment.center
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if vehicles.count > 0 {
            return 40
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate?.event(type: "update", data: vehicles[indexPath.row])
        dismiss(animated: true, completion: nil)
        
    }
    
}

extension VinLookupTableViewController: VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
        //scanImageView.image = scan.imageOfPage(at: 0)
        processImage(scan.imageOfPage(at: 0))
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        //Handle properly error
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
}

extension VinLookupTableViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.vehicles = [[String:String]]()
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.vehicles = [[String:String]]()
        
        if let searchText = searchBar.text, !searchText.isEmpty {
            
            let encodeMe = [
               "decoder_settings" : [
                  "display" : "full",
                  "version" : "7.2.0",
                  "styles" : "on",
                  "style_data_packs" : [
                     "basic_data" : "on",
                     "pricing" : "on",
                     "engines" : "on",
                     "transmissions" : "on",
                     "standard_specifications" : "on",
                     "standard_generic_equipment" : "on",
                     "oem_options" : "off",
                     "optional_generic_equipment" : "on",
                     "colors" : "on",
                     "warranties" : "on",
                     "fuel_efficiency" : "on",
                     "green_scores" : "on",
                     "crash_test" : "on",
                     "awards" : "on"
                  ],
                  "common_data" : "on",
                  "common_data_packs" : [
                     "basic_data" : "on",
                     "pricing" : "on",
                     "engines" : "on",
                     "transmissions" : "on",
                     "standard_specifications" : "on",
                     "standard_generic_equipment" : "on",
                     "oem_options" : "on",
                     "optional_generic_equipment" : "on",
                     "colors" : "on",
                     "warranties" : "on",
                     "fuel_efficiency" : "on",
                     "green_scores" : "on",
                     "crash_test" : "on",
                     "awards" : "on"
                     ]
               ],
               "query_requests" : [
                  "Request-Sample" : [
                    "vin" : searchText,
                     "year" : "",
                     "make" : "",
                     "model" : "",
                     "trim" : "",
                     "model_number" : "",
                     "package_code" : "",
                     "drive_type" : "",
                     "vehicle_type" : "",
                     "body_type" : "",
                     "body_subtype" : "",
                     "doors" : "",
                     "bedlength" : "",
                     "wheelbase" : "",
                     "msrp" : "",
                     "invoice_price" : "",
                     "engine" : [
                        "description" : "",
                        "block_type" : "",
                        "cylinders" : "",
                        "displacement" : "",
                        "fuel_type" : ""
                     ],
                     "transmission" : [
                        "description" : "",
                        "trans_type" : "",
                        "trans_speeds" : ""
                     ],
                     "optional_equipment_codes" : "",
                     "installed_equipment_descriptions" : "",
                     "interior_color" : [
                        "description" : "",
                        "color_code" : ""
                     ],
                     "exterior_color" : [
                        "description" : "",
                        "color_code" : ""
                     ]
                  ]
               ]
            ]
            
            let parameters: [String: String] = [
                "access_key_id" : "gAyYD003Cn",
                "secret_access_key" : "j2eVcOMUeShuE3nh7yp69hTLYxVoJ1bdlkH8exIs",
                "decoder_query" : json(from: encodeMe)!
            ]
        
            AF.request("https://api.dataonesoftware.com/webservices/vindecoder/decode", method: .post, parameters: parameters).responseJSON { response in
                
                    switch response.result {
                        case .success(let json):
                            
                            let results : JSON = JSON(json)
                        
                            //print(results["query_responses"]["Request-Sample"]["us_market_data"]["us_styles"])
                            let basic_data = results["query_responses"]["Request-Sample"]["us_market_data"]["common_us_data"]["basic_data"]
                            let vehicleName = basic_data["year"].stringValue + " " + basic_data["make"].stringValue + " " + basic_data["model"].stringValue
                            
                            self.tableViewHeader = vehicleName
                            
                            for style in results["query_responses"]["Request-Sample"]["us_market_data"]["us_styles"].arrayValue {
                                var item = [
                                    "name" : style["name"].stringValue,
                                    "year" : basic_data["year"].stringValue,
                                    "make" : basic_data["make"].stringValue,
                                    "model" : basic_data["model"].stringValue,
                                    "vin" : searchText
                                ]
                                
                                for spec in style["standard_specifications"].arrayValue {
                                    if spec["specification_category"].stringValue == "Weights and Capacities" {
                                        
                                        for value in spec["specification_values"].arrayValue {
                                            
                                            let name = value["specification_name"].stringValue.replacingOccurrences(of: " ", with: "_")
                                            item[name] = value["specification_value"].stringValue
                                            
                                        }
                                        
                                    }
                                }
                                
                                self.vehicles.append(item)
                                if self.vehicles.count > 0 {
                                    self.tableView.separatorStyle = .singleLine
                                } else {
                                    self.tableView.separatorStyle = .none
                                }
                                self.tableView.reloadData()
                            }
                        
                        case .failure(let error):
                            self.dismiss(animated: true, completion: nil)
                            print(error.localizedDescription)
                    }
            
    //            RESPONSE:
    //
    //            query_responses->Request-Sample->us_market_data->us_styles[]->name
    //
    //            query_responses->Request-Sample->us_market_data->us_styles[]->standard_specifications[]
                
    //            {
    //                  "specification_category": "Weights and Capacities",
    //                  "specification_values": [
    //                        {
    //                              "specification_id": "210987",
    //                              "specification_name": "Gross Vehicle Weight Range",
    //                              "specification_value": "10001-14000"
    //                        },
    //                        {
    //                              "specification_id": "219793",
    //                              "specification_name": "Base Towing Capacity",
    //                              "specification_value": "12300"
    //                        },
    //                        {
    //                              "specification_id": "214924",
    //                              "specification_name": "Curb Weight",
    //                              "specification_value": "6681"
    //                        },
    //                        {
    //                              "specification_id": "220054",
    //                              "specification_name": "Fuel Tank Capacity",
    //                              "specification_value": "34.0"
    //                        },
    //                        {
    //                              "specification_id": "219306",
    //                              "specification_name": "Gross Combined Weight Rating",
    //                              "specification_value": "19500"
    //                        },
    //                        {
    //                              "specification_id": "208937",
    //                              "specification_name": "Gross Vehicle Weight Rating",
    //                              "specification_value": "10500"
    //                        },
    //                        {
    //                              "specification_id": "202982",
    //                              "specification_name": "Max Payload",
    //                              "specification_value": "3750"
    //                        },
    //                        {
    //                              "specification_id": "228952",
    //                              "specification_name": "Max Towing Capacity",
    //                              "specification_value": "20800"
    //                        },
    //                        {
    //                              "specification_id": "229984",
    //                              "specification_name": "Tonnage",
    //                              "specification_value": "1"
    //                        }
    //                  ]
    //            }
                
            }
            
            searchBar.resignFirstResponder()
            
        }
    }
    
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
}

extension VinLookupTableViewController: EmptyDataSetDelegate, EmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Enter vehicle VIN number and select your vehicle", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 18)!])
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        return NSAttributedString(string: "Scan with Camera", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 18)!])
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
        let scanVC = VNDocumentCameraViewController()
        scanVC.delegate = self
        present(scanVC, animated: true)
    }
}
