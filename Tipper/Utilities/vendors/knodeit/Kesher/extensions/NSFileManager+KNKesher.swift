//
//  NSFileManager+KNKesher.swift
//  KesherDemo
//
//  Created by PETRUS VAN DE PUT on 19/12/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

extension NSFileManager {
    
    func enumerateContentsOfDirectoryAtPath(path : String, orderedByProperty property : String, ascending : Bool, usingBlock block : (NSURL, Int, inout Bool) -> Void ) {
        
        let directoryURL = NSURL(fileURLWithPath: path)
        if directoryURL == nil { return }
        var error : NSError?
        if let directoryContents = self.contentsOfDirectoryAtURL(directoryURL!, includingPropertiesForKeys: [property], options: NSDirectoryEnumerationOptions.allZeros, error: &error) as? [NSURL] {
            let sortedContents = directoryContents.sorted({(firstURL : NSURL, secondURL : NSURL) -> Bool in
                var firstValue : AnyObject?
                if !firstURL.getResourceValue(&firstValue, forKey: property, error: nil) { return true }
                var secondValue : AnyObject?
                if !secondURL.getResourceValue(&secondValue, forKey: property, error: nil) { return false }
                
                if let firstString = firstValue as? String {
                    if let secondString = secondValue as? String {
                        return ascending ? firstString < secondString : secondString < firstString
                    }
                }
                if let firstDate = firstValue as? NSDate {
                    if let secondDate = secondValue as? NSDate {
                        return ascending ? firstDate < secondDate : secondDate < firstDate
                    }
                }
                
                if let firstNumber = firstValue as? NSNumber {
                    if let secondNumber = secondValue as? NSNumber {
                        return ascending ? firstNumber < secondNumber : secondNumber < firstNumber
                    }
                }
                
                return false
            })
            
            for (i, v) in enumerate(sortedContents) {
                var stop : Bool = false
                block(v, i, &stop)
                if stop { break }
            }
        } else {
            KNLogger.error("Failed enumerate", error)
        }
    }
    
}
// MARK Helpers

func < (leftHand: NSDate, rightHand: NSDate) -> Bool {
    return leftHand.compare(rightHand) == NSComparisonResult.OrderedAscending
}

func < (leftHand: NSNumber, rightHand: NSNumber) -> Bool {
    return leftHand.compare(rightHand) == NSComparisonResult.OrderedAscending
}

