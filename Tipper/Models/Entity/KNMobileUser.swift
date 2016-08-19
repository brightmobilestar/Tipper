//
//  TipperUser.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 09/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation
import CoreData

class KNMobileUser: NSManagedObject {

    @NSManaged var accessToken: String
    @NSManaged var avatar: String
    @NSManaged var email: String
    @NSManaged var isVerified: NSNumber
    @NSManaged var passcode: String
    @NSManaged var password: String
    @NSManaged var phoneNumber: String
    @NSManaged var publicName: String
    @NSManaged var userId: String
    @NSManaged var hasPinCode: NSNumber
    
    // Added by luokey
    @NSManaged var paypalEmail: String
}
