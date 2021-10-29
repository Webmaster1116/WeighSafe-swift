//
//  Protocols.swift
//  WeighSafe
//
//  Created by Brian Barton on 8/18/20.
//  Copyright © 2020 Lemonadestand Inc. All rights reserved.
//

import Foundation

protocol DataTransit: class {
    func event(type: String, data: Any)
}
