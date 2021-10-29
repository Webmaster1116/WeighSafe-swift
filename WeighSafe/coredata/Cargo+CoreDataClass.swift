//
//  Cargo+CoreDataClass.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/14/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import Foundation
import CoreData

public class Cargo: NSManagedObject {}

extension Cargo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cargo> {
        return NSFetchRequest<Cargo>(entityName: "Cargo")
    }

    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var cargoWeight: NSDecimalNumber?

}
