//
//  KNFriend.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 08/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation
import CoreData

class KNFriend: NSManagedObject
{
    @NSManaged var avatar: String
    @NSManaged var friendId: String
    @NSManaged var isFavorite: NSNumber
    @NSManaged var publicName: String
    @NSManaged var userId: String
    @NSManaged var mobile: String?
    @NSManaged var email: String?
}
