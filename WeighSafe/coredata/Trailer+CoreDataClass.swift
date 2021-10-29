//
//  Trailer+CoreDataClass.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/14/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import Foundation
import CoreData

public class Trailer: NSManagedObject {}

extension Trailer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trailer> {
        return NSFetchRequest<Trailer>(entityName: "Trailer")
    }

    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var vin: String?
    @NSManaged public var coupler: String?
    @NSManaged public var emptyWeight: NSDecimalNumber?
    @NSManaged public var cargoWeight: NSDecimalNumber?
    @NSManaged public var loadCapacity: NSDecimalNumber?
    @NSManaged public var couplerHeight: NSDecimalNumber?

}
