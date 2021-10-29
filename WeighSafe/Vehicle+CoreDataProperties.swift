//
//  Vehicle+CoreDataProperties.swift
//  WeighSafe
//
//  Created by Brian Barton on 1/29/19.
//  Copyright © 2019 Lemonadestand Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Vehicle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vehicle> {
        return NSFetchRequest<Vehicle>(entityName: "Vehicle")
    }

    @NSManaged public var name: String?
    @NSManaged public var drawbarPosition: NSNumber?
    @NSManaged public var holesVisible: NSNumber
    @NSManaged public var grossTrailerWeight: NSDecimalNumber?
    @NSManaged public var tongueWeight: NSDecimalNumber?
    @NSManaged public var rearAxleToEndOfReceiver: NSDecimalNumber?
    @NSManaged public var towBallToEndOfSpringBars: NSDecimalNumber?
    @NSManaged public var towBallToTrailerAxle: NSDecimalNumber?
    
    @NSManaged public var vin: String?
    @NSManaged public var year: String?
    @NSManaged public var make: String?
    @NSManaged public var model: String?
    @NSManaged public var gvwr: NSDecimalNumber?
    @NSManaged public var gcwr: NSDecimalNumber?
    @NSManaged public var mcc: NSDecimalNumber?
    @NSManaged public var haveBumperPullReceiver: NSNumber?
    @NSManaged public var maxBumperWeightRating: NSDecimalNumber?
    @NSManaged public var maxBumperTongueWeightRating: NSDecimalNumber?
    @NSManaged public var haveDistributedRatings: NSNumber?
    @NSManaged public var maxDistributedWeightRating: NSDecimalNumber?
    @NSManaged public var maxDistributedTongueWeightRating: NSDecimalNumber?
    @NSManaged public var haveInBedReceiver: NSNumber?
    @NSManaged public var maxInBedWeightRating: NSDecimalNumber?
    

}
