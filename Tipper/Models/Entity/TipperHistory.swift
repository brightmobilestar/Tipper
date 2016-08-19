//
//  TipperHistory.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 08/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation
import CoreData

class TipperHistory: NSManagedObject {

    @NSManaged var friendFullName: String
    @NSManaged var historyId: String
    @NSManaged var isSent: NSNumber
    @NSManaged var tipAmount: NSNumber
    @NSManaged var tipDate: NSDate
    @NSManaged var userId: String

}
