//
//  KNArrayExtension.swift
//  Tipper
//
//  Created by Jay N on 12/12/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import Foundation

extension Array {
    
    // Check an element contain in array
    func contains<T where T : Equatable>(obj: T) -> Bool {
        return self.filter({$0 as? T == obj}).count > 0
    }
}