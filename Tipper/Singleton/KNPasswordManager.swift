//
//  KNPasswordManager.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 16/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//


import Foundation
class KNPasswordManager: NSObject {
    
    
    class var sharedInstance : KNPasswordManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNPasswordManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNPasswordManager()
        }
        return Static.instance!
    }
    
   
    //MARK password forgot
    //This send an email with a link that is processed in AppDelegate and redirects to VC to enter new password twice
    func forgotPasswordWithEmail(email:String,   completed:(success: Bool, errors: [(KNAPIResponse.APIError)]?) -> ()){
        KNAPIManager.sharedInstance.forgotPasswordWithEmail(email, completed: { (success, responseObj) -> () in
            if(responseObj.status! == kAPIStatusOk){
                completed(success:true ,errors: nil)
            }
            else {
                completed(success:false,  errors: responseObj.errors)
            }
        })
    }
    
    
    func forgotPasswordWithMobile(mobile:String, completed:(success: Bool, errors: [(KNAPIResponse.APIError)]?) -> ()){
        KNAPIManager.sharedInstance.forgotPasswordWithMobile(mobile, completed: { (success, responseObj) -> () in
            if(responseObj.status! == kAPIStatusOk){
                completed(success:true ,errors: nil)
            }
            else {
                completed(success:false,  errors: responseObj.errors)
            }
        })
    }
    
    
    //MARK reset the password
    func resetPasswordWithEmail(token:String, password:String, confirmPassword:String, completed:(success: Bool, errors: [(KNAPIResponse.APIError)]?) -> ()){
        KNAPIManager.sharedInstance.resetPasswordWithEmail(token, password: password, confirmPassword: confirmPassword) { (success, responseObj) -> () in
            if(responseObj.status! == kAPIStatusOk){
                completed(success:true ,errors: nil)
            }
            else {
                completed(success:false,  errors: responseObj.errors)
            }
        }
    }
    
    
    func resetPasswordWithMobile(mobile:String, code:String, password:String, confirmPassword:String,  completed:(success: Bool, errors: [(KNAPIResponse.APIError)]?) -> ()){
        KNAPIManager.sharedInstance.resetPasswordWithMobile(mobile, code: code, password: password, confirmPassword: confirmPassword) { (success, responseObj) -> () in
            if(responseObj.status! == kAPIStatusOk){
                completed(success:true ,errors: nil)
            }
            else {
                completed(success:false,  errors: responseObj.errors)
            }
        }
    }
    
}

