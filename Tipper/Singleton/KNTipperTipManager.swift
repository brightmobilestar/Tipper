//
//  KNTipperTipManager.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 10/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit
import Foundation
class KNTipperTipManager {
    
    class var sharedInstance : KNTipperTipManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNTipperTipManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNTipperTipManager()
        }
        return Static.instance!
    }
    
    init() {
        
    }
    

    func tipAFriend(friendId:String, amountInCents:String, cardId:String, pinCode:String,completed:(success: Bool, errors: [(KNAPIResponse.APIError)]?) -> ()){
        KNAPIManager.sharedInstance.tipAFriend(friendId, amountInCents: amountInCents, cardId:cardId, pinCode: pinCode) { (success, apiResponse) -> () in
            if(apiResponse.status! == kAPIStatusOk){
      
                completed(success:true,  errors: nil)
            }
            else {
                completed(success:false,  errors: apiResponse.errors)
            }
        }
    }
    
    
    func tipAnUnknown(sendTo:String, amountInCents:String, cardId:String, pinCode:String,completed:(success: Bool, errors: [(KNAPIResponse.APIError)]?) -> ()){
        
        KNAPIManager.sharedInstance.tipAnUnknown(sendTo, amountInCents: amountInCents, cardId: cardId, pinCode: pinCode) { (success, responseObj) -> () in
            if(responseObj.status! == kAPIStatusOk){
                
                completed(success:true,  errors: nil)
            }
            else {
                completed(success:false,  errors: responseObj.errors)
            }
        }
        
        
    }
    
    
    
    
}

