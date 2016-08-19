//
//  KNDictionaryExtension.swift
//  Tipper
//
//  Created by Jay N on 12/10/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import Foundation

extension Dictionary {
    
    mutating func append(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }

}