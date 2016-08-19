//
//  KNStringExtension.swift
//  CloudBeacon
//
//  Created by PETRUS VAN DE PUT on 10/11/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

extension String {
    
    /**
    String length
    */
    var length: Int {
        return countElements(self)
    }
    
    /**
    String uppercase
    */
    var uppercase: String {
        return self.uppercaseString
    }
    
    /**
    String lowercase
    */
    var lowercase: String {
        return self.lowercaseString
    }
    
    /**
    Gets the character at the specified index as String.
    If index is negative it is assumed to be relative to the end of the String.
    
    :param: index Position of the character to get
    :returns: Character as String or empty if the index is out of bounds
    */
    subscript (i: Int) -> String {
        if i >= 0 && i < self.length {
            return String(Array(self)[i])
        }
        return ""
    }
    
    /**
    Returns the substring in the given range
    
    :param: range
    :returns: Substring in range
    */
    subscript (r: Range<Int>) -> String {
        if r.startIndex < 0 || r.endIndex > self.length {
            return ""
        }
        var start = advance(startIndex, r.startIndex)
        var end = advance(startIndex, r.endIndex)
        return substringWithRange(Range(start: start, end: end))
    }
    
    var toFloat:Float {
        //return Float(self .bridgeToObjectiveC().floatValue)
        var rawValue = self as NSString
        return Float(rawValue.floatValue)
    }
    
    var toDouble:Double{
        var rawValue = self as NSString
        return Double(rawValue.doubleValue)
    }
    
    var groupThousandNumber:String {
        var numberFormat:NSNumberFormatter = NSNumberFormatter()
        numberFormat.usesGroupingSeparator = true
        numberFormat.groupingSeparator = ","
        numberFormat.decimalSeparator = "."
        numberFormat.groupingSize = 3
        numberFormat.minimumFractionDigits = 0
        numberFormat.maximumFractionDigits = 2
        numberFormat.usesSignificantDigits = true
        return numberFormat.stringFromNumber(self.toFloat)!
    }
    
    var groupThousandNumberWithForceDecimal:String {
        var numberFormat:NSNumberFormatter = NSNumberFormatter()
        numberFormat.numberStyle = .CurrencyStyle
        numberFormat.currencySymbol = ""
        numberFormat.groupingSeparator = ","
        numberFormat.groupingSize = 3
        numberFormat.minimumFractionDigits = 2
        numberFormat.maximumFractionDigits = 2
        return numberFormat.stringFromNumber(self.toDouble)!
    }
    
        
    var groupThousandInteger:String {
        var numberFormat:NSNumberFormatter = NSNumberFormatter()
        numberFormat.usesGroupingSeparator = true
        numberFormat.groupingSeparator = ","
        numberFormat.groupingSize = 3
        return numberFormat.stringFromNumber(self.toDouble)!
    }
    
    
    //Peter added trimPhoneNumber to clean Addressbook phone number which contain formatters
    /**
    String trimPhoneNumber
    */
 
    func firstCharacterUpperCase() -> String {
        let lowercaseString = self.lowercaseString
        
        return lowercaseString.stringByReplacingCharactersInRange(lowercaseString.startIndex...lowercaseString.startIndex, withString: String(lowercaseString[lowercaseString.startIndex]).uppercaseString)
    }
    
    func formatPublicName()->String{
        return self.lowercaseString
    }
    
    var trimmedPhoneNumber: String {

        
        var parts:NSArray = self.componentsSeparatedByCharactersInSet(.whitespaceCharacterSet())
        var cleanedString:String = parts.componentsJoinedByString("");
        
        var trimmedString:String = cleanedString.stringByReplacingOccurrencesOfString("+", withString: "", options: nil, range: nil)
        trimmedString = trimmedString.stringByReplacingOccurrencesOfString(" ", withString: "", options: .CaseInsensitiveSearch, range: nil)
        trimmedString = trimmedString.stringByReplacingOccurrencesOfString("-", withString: "", options: .CaseInsensitiveSearch, range: nil)
        trimmedString = trimmedString.stringByReplacingOccurrencesOfString("(", withString: "", options: .CaseInsensitiveSearch, range: nil)
        trimmedString = trimmedString.stringByReplacingOccurrencesOfString(")", withString: "", options: .CaseInsensitiveSearch, range: nil)
        
        return trimmedString
        
    }
}