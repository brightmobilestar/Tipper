//
//  TipperUserBalance.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 11/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation
import CoreData

class TipperUserBalance: NSManagedObject {

    @NSManaged var userId: String
    @NSManaged var balance: NSNumber

}
