//
//  Configuration+CoreDataClass.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/14/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import Foundation
import CoreData

public class Configuration: NSManagedObject {}

extension Configuration {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Configuration> {
        return NSFetchRequest<Configuration>(entityName: "Configuration")
    }

    @NSManaged public var name: String?
    @NSManaged public var tongueWeight: NSDecimalNumber?
    @NSManaged public var towBallToEndOfSpringBars: NSDecimalNumber?
    @NSManaged public var towBallToTrailerAxle: NSDecimalNumber?
    @NSManaged public var rearAxleToEndOfReceiver: NSDecimalNumber?
    @NSManaged public var vehicle: NSNumber?
    @NSManaged public var hitch: NSNumber?
    @NSManaged public var trailer: NSNumber?
    @NSManaged public var cargo: [NSNumber]?
    @NSManaged public var additionalVehicleWeight: NSDecimalNumber?
    @NSManaged public var additionalTrailerWeight: NSDecimalNumber?
    @NSManaged public var drawbarPosition: NSNumber?
    @NSManaged public var holesVisible: NSDecimalNumber?

}
