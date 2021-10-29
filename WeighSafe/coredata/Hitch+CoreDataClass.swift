//
//  Hitch+CoreDataClass.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/14/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import Foundation
import CoreData

public class Hitch: NSManagedObject {}

extension Hitch {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hitch> {
        return NSFetchRequest<Hitch>(entityName: "Hitch")
    }

    @NSManaged public var type: String?
    @NSManaged public var brand: String?
    @NSManaged public var position: String?
    @NSManaged public var shankSize: String?
    @NSManaged public var ballSize: String?
    @NSManaged public var maxGTWR: NSDecimalNumber?
    @NSManaged public var maxTongueWeight: NSDecimalNumber?
    @NSManaged public var isWeighSafeHitch: NSNumber?

}
