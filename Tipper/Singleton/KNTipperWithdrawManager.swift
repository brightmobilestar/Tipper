//
//  KNTipperWithdrawManager.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 10/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//


import UIKit
import Foundation
class KNTipperWithdrawManager {
    
    class var sharedInstance : KNTipperWithdrawManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNTipperWithdrawManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNTipperWithdrawManager()
        }
        return Static.instance!
    }
    
    init() {
        
    }
    
    func fetchBalance(completed: (success: Bool,balance: Float?, responseObj: KNAPIResponse) -> ()){
        KNAPIManager.sharedInstance.fetchBalance { (success, balance, responseObj) -> () in
            KNCoreDataManager.sharedInstance.saveTipperUserBalance(KNMobileUserManager.sharedInstance.currentUser()!.userId, balance: balance)
            completed(success:success, balance: balance, responseObj: responseObj)
        }
    }
    
    func withdrawBalance(toCard debitCard: TipperCard, amount amountInCents:String, pincode:String, completed: (success: Bool,responseObj: KNAPIResponse) -> ()){
       
        
        KNAPIManager.sharedInstance.withdrawBalance(toCard: debitCard, amount: amountInCents, pincode: pincode) { (success, responseObj) -> () in
            
                       
            
            
             completed(success:success,  responseObj: responseObj)
        }
    }
    
    
    // Added by luokey
    func withdrawBalanceToPaypal(amount amountInCents:String, pincode:String, completed: (success: Bool,responseObj: KNAPIResponse) -> ()){
        
        KNAPIManager.sharedInstance.withdrawBalanceToPaypal(amount: amountInCents, pincode: pincode) { (success, responseObj) -> () in
            
            completed(success:success,  responseObj: responseObj)
        }
    }
    
}
