//
//  KNDiallingCodes.swift
//  Tipper
//
//  Created by Jay N on 12/2/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import Foundation

struct KNCountry {
    let name: String?
    let code: String?
    let diallingCode: String?
}

class KNDiallingCodes {
    
    class var sharedInstance : KNDiallingCodes {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNDiallingCodes? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNDiallingCodes()
        }
        return Static.instance!
    }
    
    func getData() -> [KNCountry] {
        let countriesFile = NSBundle.mainBundle().pathForResource("Countries", ofType: "plist")
        let countries = NSArray(contentsOfFile: countriesFile!)
        
        let diallingCodesFile = NSBundle.mainBundle().pathForResource("DiallingCodes", ofType: "plist")
        let diallingCodes = NSDictionary(contentsOfFile: diallingCodesFile!)

        var countryList:[KNCountry] = []
        for item in countries! {
            let name = item["name"] as String
            let code = item["code"] as String
            let diallingCode = diallingCodes![code.lowercaseString] as String!
            countryList.append(KNCountry(name: name, code: code, diallingCode: diallingCode))
        }
        return countryList
    }
    
}

