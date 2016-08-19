//
//  KNBKStringExtentions.swift
//  KNBKExSwift
//
//  Created by pNre on 03/06/14.
//  Copyright (c) 2014 pNre. All rights reserved.
//

import Foundation

public extension String {

    /**
        String length
    */
    var lengthOfString: Int { return countElements(self) }
    
    /**
        self.capitalizedString shorthand
    */
    var capitalized: String { return capitalizedString }
    
    /**
        Returns the substring in the given range
        
        :param: range
        :returns: Substring in range
    */
    subscript (range: Range<Int>) -> String? {
        if range.startIndex < 0 || range.endIndex > self.lengthOfString {
            return nil
        }

        let range = Range(start: advance(startIndex, range.startIndex), end: advance(startIndex, range.endIndex))

        return self[range]
    }

    /**
        Equivalent to at. Takes a list of indexes and returns an Array
        containing the elements at the given indexes in self.
        
        :param: firstIndex
        :param: secondIndex
        :param: restOfIndexes
        :returns: Charaters at the specified indexes (converted to String)
    */
    subscript (firstIndex: Int, secondIndex: Int, restOfIndexes: Int...) -> [String] {
        return at([firstIndex, secondIndex] + restOfIndexes)
    }

    /**
        Gets the character at the specified index as String. 
        If index is negative it is assumed to be relative to the end of the String.
        
        :param: index Position of the character to get
        :returns: Character as String or nil if the index is out of bounds
    */
    subscript (index: Int) -> String? {
        if let char = Array(self).get(index) {
            return String(char)
        }

        return nil
    }

    /**
        Takes a list of indexes and returns an Array containing the elements at the given indexes in self.
    
        :param: indexes Positions of the elements to get
        :returns: Array of characters (as String)
    */
    func at (indexes: Int...) -> [String] {
        return indexes.map { self[$0]! }
    }

    /**
        Takes a list of indexes and returns an Array containing the elements at the given indexes in self.
    
        :param: indexes Positions of the elements to get
        :returns: Array of characters (as String)
    */
    func at (indexes: [Int]) -> [String] {
        return indexes.map { self[$0]! }
    }

    /**
        Returns an array of strings, each of which is a substring of self formed by splitting it on separator.
        
        :param: separator Character used to split the string
        :returns: Array of substrings
    */
    func explode (separator: Character) -> [String] {
        return split(self, { (element: Character) -> Bool in
            return element == separator
        })
    }

    /**
        Finds any match in self for pattern.
        
        :param: pattern Pattern to match
        :param: ignoreCase true for case insensitive matching
        :returns: Matches found (as [NSTextCheckingResult])
    */
    func matches (pattern: String, ignoreCase: Bool = false) -> [NSTextCheckingResult]? {

        if let regex = KNBKExSwift.regex(pattern, ignoreCase: ignoreCase) {
            //  Using map to prevent a possible bug in the compiler
            return regex.matchesInString(self, options: nil, range: NSMakeRange(0, lengthOfString)).map { $0 as NSTextCheckingResult }
        }

        return nil
    }

    /**
        Inserts a substring at the given index in self.
    
        :param: index Where the new string is inserted
        :param: string String to insert
        :returns: String formed from self inserting string at index
    */
    func insert (var index: Int, _ string: String) -> String {
        //  Edge cases, prepend and append
        if index > lengthOfString {
            return self + string
        } else if index < 0 {
            return string + self
        }
        
        return self[0..<index]! + string + self[index..<lengthOfString]!
    }

    /**
        Strips whitespaces from the beginning of self.
    
        :returns: Stripped string
    */
    func ltrimmed () -> String {
        if let range = rangeOfCharacterFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet().invertedSet) {
            return self[range.startIndex..<endIndex]
        }
        
        return self
    }

    /**
        Strips whitespaces from the end of self.
    
        :returns: Stripped string
    */
    func rtrimmed () -> String {
        if let range = rangeOfCharacterFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet().invertedSet, options: NSStringCompareOptions.BackwardsSearch) {
            return self[startIndex..<range.endIndex]
        }
        
        return self
    }

    /**
        Strips whitespaces from both the beginning and the end of self.
    
        :returns: Stripped string
    */
    func trimmed () -> String {
        return ltrimmed().rtrimmed()
    }

    /**
        Costructs a string using random chars from a given set.
    
        :param: length String length. If < 1, it's randomly selected in the range 0..16
        :param: charset Chars to use in the random string
        :returns: Random string
    */
    static func random (var length len: Int = 0, charset: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") -> String {

        if len < 1 {
            len = Int.random(max: 16)
        }

        var result = String()
        let max = charset.lengthOfString - 1

        len.times {
            result += charset[Int.random(min: 0, max: max)]!
        }

        return result

    }
    
    public var floatValue : Float {
        return (self as NSString).floatValue
    }
    
    public func dataFromHexString() -> NSData {
        var bytes = [UInt8]()
        for i in 0..<(countElements(self)/2) {
            if let stringBytes = self[2*i..<2*i+2] {
                let byte = strtol((stringBytes as NSString).UTF8String, nil, 16)
                bytes.append(UInt8(byte))
            }
        }
        return NSData(bytes:bytes, length:bytes.count)
    }
    
    static func randomStringWithLength (len : Int = 30) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }

}

/**
    Repeats the string first n times
*/
public func * (first: String, n: Int) -> String {
    var result = String()

    n.times {
        result += first
    }

    return result
}

//  Pattern matching using a regular expression
public func =~ (string: String, pattern: String) -> Bool {
    let regex = KNBKExSwift.regex(pattern, ignoreCase: false)!
    let matches = regex.numberOfMatchesInString(string, options: nil, range: NSMakeRange(0, string.lengthOfString))
    return matches > 0
}

//  Pattern matching using a regular expression
public func =~ (string: String, regex: NSRegularExpression) -> Bool {
    let matches = regex.numberOfMatchesInString(string, options: nil, range: NSMakeRange(0, string.lengthOfString))
    return matches > 0
}

//  This version also allowes to specify case sentitivity
public func =~ (string: String, options: (pattern: String, ignoreCase: Bool)) -> Bool {
    if let matches = KNBKExSwift.regex(options.pattern, ignoreCase: options.ignoreCase)?.numberOfMatchesInString(string, options: nil, range: NSMakeRange(0, string.lengthOfString)) {
        return matches > 0
    }

    return false
}

//  Match against all the alements in an array of String
public func =~ (strings: [String], pattern: String) -> Bool {
    let regex = KNBKExSwift.regex(pattern, ignoreCase: false)!
    return strings.all { $0 =~ regex }
}

public func =~ (strings: [String], options: (pattern: String, ignoreCase: Bool)) -> Bool {
    return strings.all { $0 =~ options }
}

//  Match against any element in an array of String
public func |~ (strings: [String], pattern: String) -> Bool {
    let regex = KNBKExSwift.regex(pattern, ignoreCase: false)!
    return strings.any { $0 =~ regex }
}

public func |~ (strings: [String], options: (pattern: String, ignoreCase: Bool)) -> Bool {
    return strings.any { $0 =~ options }
}
