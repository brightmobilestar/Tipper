//
//  KNLoginManager.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 09/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit
import Foundation

protocol KNLoginManagerDelegate {
    func didFinishLoginWithSuccess()
    func didFinishLoginWithError()
    func didFinishLogOutWithSuccess()
    func didFinishLogOutWithError()
}


class KNLoginManager {
    
    class var sharedInstance : KNLoginManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNLoginManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNLoginManager()
        }
        return Static.instance!
    }
    
    init() {
        
    }
    
    var delegate:KNLoginManagerDelegate?
    //MARK API
    
    func loginUser(email:String, password:String, completed:(success: Bool, user: KNMobileUser?, errors: [(KNAPIResponse.APIError)]?) -> ()){
        KNAPIManager.sharedInstance.loginUser(email, password: password) { (success, responseObj) -> () in
            if responseObj.status == kAPIStatusOk {
                //Save user object
                var user:KNMobileUser = KNCoreDataManager.sharedInstance.saveMobileUser(responseObj.dataObject as NSDictionary)
                //Save we we have access
                KNMobileUserManager.sharedInstance.saveAccountInfoWithPass(user.userId, pass: password, accessToken: user.accessToken)
                
                
                KNFriendManager.sharedInstance.fetchFriendsFromServer({ (success, errors) -> () in
                    
                })
                
                self.delegate?.didFinishLoginWithSuccess()
                completed(success:true, user: KNMobileUserManager.sharedInstance.currentUser()!, errors: nil)
                

               

            }
            else{
                self.delegate?.didFinishLoginWithError()
                 completed(success:false, user: nil, errors: responseObj.errors)
            }
        }
    }
    
    func logoutUser(completed:(success: Bool) -> ()){
        
        KNAPIManager.sharedInstance.logoutUser { (success, responseObj) -> () in
            if (success){
                
                KNMobileUserManager.sharedInstance.resetUser()
                self.delegate?.didFinishLogOutWithSuccess()
            }
            else{
                 
                self.delegate?.didFinishLogOutWithError()
            }
            
        }
        
        completed(success: true)
        
    }
    
    
}

