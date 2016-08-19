//
//  KNRegistrationManager.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 09/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit
import Foundation

protocol KNRegistrationManagerDelegate {
    func didFinishRegistrationWithSuccess()
    func didFinishRegistrationWithError()
    func didFinishCancelRegistrationWithSuccess()
    func didFinishCancelRegistrationWithError()
}


class KNRegistrationManager {
    
    class var sharedInstance : KNRegistrationManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNRegistrationManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNRegistrationManager()
        }
        return Static.instance!
    }
    
    init() {
        
    }
    
    var delegate:KNRegistrationManagerDelegate?
    
    //MARK API
    
    
    //called from landing page, if it returns a user, and that is saved in core data you can login
    //if 
    func checkIfUserExistByEmail(email:String,completed:(success: Bool, user: KNMobileUser?, errors: [(KNAPIResponse.APIError)]?) -> ()){
        KNAPIManager.sharedInstance.checkIfUserExistByEmail(emailAddress: email) { (success, responseObj) -> () in
            if responseObj.status == kAPIStatusOk{
                if let dataObject: NSDictionary = responseObj.dataObject as? NSDictionary{
                    var userId: String = dataObject["id"] as NSString
                   
                     var user:KNMobileUser = KNMobileUserManager.sharedInstance.fetchUser(userId)!
                }
               }
            else{
                 completed(success:false, user: nil, errors: responseObj.errors)
            }
        }
    }
    
    /*
    
    Step 1; register a user
    */
    func registerUser(email:String, username:String, password:String, confirmPassword:String, avatar:String,completed:(success: Bool, user: KNMobileUser?, errors: [(KNAPIResponse.APIError)]?) -> ()){
        KNAPIManager.sharedInstance.registerUser(email, username: username, password: password, confirmPassword: confirmPassword, avatar: avatar) { (success, responseObj) -> () in
            if responseObj.status == kAPIStatusOk{
                var user:KNMobileUser = KNCoreDataManager.sharedInstance.saveMobileUser(responseObj.dataObject as NSDictionary)
                
                KNMobileUserManager.sharedInstance.currentEmailExistanceResponse.userId = user.userId
                KNMobileUserManager.sharedInstance.currentEmailExistanceResponse.password = password
                
                completed(success:true, user: user, errors: nil)
            }
            else{
                completed(success:false, user: nil, errors: responseObj.errors)
            }
        }
        
    }
    

    /*
    Step 2 in the process is adding the mobile number
    */
    func addMobileNumber(userId:String, mobile:String, completed:(success: Bool, errors: [(KNAPIResponse.APIError)]?) -> ()){

        KNAPIManager.sharedInstance.addMobileNumber(userId, mobile: mobile) { (success, responseObj) -> () in
            if responseObj.status == kAPIStatusOk{
                completed(success:true, errors: nil)
            }
            else{
                completed(success:false, errors: responseObj.errors)
            }
        }
    }
    
    
    
    func addMobileNumberAndCountryCode(userId: String, mobile: String, countryCode:String, completed:(success: Bool, errors: [(KNAPIResponse.APIError)]?) -> ()){
            KNAPIManager.sharedInstance.addMobileNumberAndCountryCode(userId, mobile: mobile, countryCode: countryCode) { (success, responseObj) -> () in
                if responseObj.status == kAPIStatusOk{
                    completed(success:true, errors: nil)
                }
                else{
                    completed(success:false, errors: responseObj.errors)
                }
        }
    
    }

    
    
    
    /*
    Step 3 in the process is sending the verification that the user received by SMS
    */
    func sendVerificationCode(userId:String, verificationCode:String, completed: (success: Bool,responseObj: KNAPIResponse) -> ()) {
        KNAPIManager.sharedInstance.sendVerificationCode(userId, verificationCode: verificationCode) { (success, responseObj) -> () in
            completed(success: success, responseObj: responseObj)
        }
    }
    
    
    /*
    Step 3B optional step in case the user missed the verification code they can tap resend to send another one
    */
    func requestNewVerificationCode(userId:String, completed: (success: Bool,responseObj: KNAPIResponse) -> ()) {

        KNAPIManager.sharedInstance.requestNewVerificationCode(userId) { (success, responseObj) -> () in
           completed(success: success, responseObj: responseObj)
        }
    }
    
    
    /*
    Step 4
    */

    
    /*
    Delete a registration that is terminated by the user so the username/email/mobile becomes available again
    */
    func cancelRegistration(userId:String, completed:(success: Bool, errors: [(KNAPIResponse.APIError)]?) -> ()){
        KNAPIManager.sharedInstance.cancelRegistration(userId) { (success, responseObj) -> () in
            if responseObj.status == kAPIStatusOk{
                self.delegate?.didFinishCancelRegistrationWithSuccess()
                completed(success:true,  errors: nil)
            }
            else{
                self.delegate?.didFinishCancelRegistrationWithError()
                completed(success:false,  errors: responseObj.errors)
            }
        }
    }
    
}

