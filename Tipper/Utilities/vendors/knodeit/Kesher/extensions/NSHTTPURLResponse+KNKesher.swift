//
//  NSHTTPURLResponse+KNKesher.swift
//  KesherDemo
//
//  Created by PETRUS VAN DE PUT on 19/12/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

extension NSHTTPURLResponse {
    
    func validateLengthOfData(data : NSData) -> Bool {
        let expectedContentLength = self.expectedContentLength
        if (expectedContentLength > -1) {
            let dataLength = data.length
            return Int64(dataLength) >= expectedContentLength
        }
        return true
    }
    
}
