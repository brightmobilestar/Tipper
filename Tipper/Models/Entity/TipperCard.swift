//
//  TipperCard.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 08/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation
import CoreData


class TipperCard: NSManagedObject {

    @NSManaged var brand: String
    @NSManaged var cardId: String
    @NSManaged var cardNumber: String
    @NSManaged var cvc: String
    @NSManaged var expiredMonth: String
    @NSManaged var expiredYear: String
    @NSManaged var id: String
    @NSManaged var isDefault: NSNumber
    @NSManaged var last4: String
    @NSManaged var type: String
    @NSManaged var userId: String
    @NSManaged var firstName: String
    @NSManaged var lastName: String

}
