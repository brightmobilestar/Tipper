//
//  KNCMSPage.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 14/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation
import CoreData

class KNCMSPage: NSManagedObject {

    @NSManaged var pageId: String
    @NSManaged var slug: String
    @NSManaged var content: String
    @NSManaged var title: String
}
