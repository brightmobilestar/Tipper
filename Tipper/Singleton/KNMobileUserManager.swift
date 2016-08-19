//
//  KNMobileUserManager.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 09/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit
import Foundation
class KNMobileUserManager {
    
    class var sharedInstance : KNMobileUserManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNMobileUserManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNMobileUserManager()
        }
        return Static.instance!
    }
    
    init() {
        
    }
    
    var  currentEmailExistanceResponse: KNEmailExistResponse = KNEmailExistResponse()
   
    
    func currentUser() -> KNMobileUser? {
        
        let keychainPasswordItem:KeychainItemWrapper = KeychainItemWrapper(identifier: kItemNameKeychainPassowrd, accessGroup: nil)
        
        let accessToken = keychainPasswordItem.objectForKey(kSecAttrAccount) as String
        if accessToken == "" {
            return nil
        }
        
        let userId = keychainPasswordItem.objectForKey(kSecAttrLabel) as String
        let foundUser = self.fetchUser(userId)
        //let foundUser = KNCoreDataManager.sharedInstance.fetchCurrentUser(userId)
        if foundUser != nil {
            
            let password = keychainPasswordItem.objectForKey(kSecValueData) as String
            
            foundUser!.password = password
            foundUser!.accessToken = accessToken
        }
        
        return foundUser
    }
    
    //MARK Tipper specific
    func getBalance() -> Float{
        
        var userid = KNMobileUserManager.sharedInstance.currentUser()!.userId
        
        KNAPIManager.sharedInstance.fetchBalance { (success, balance, responseObj) -> () in
            if (success){
                 var userBalance = KNCoreDataManager.sharedInstance.findTipperUserBalance(userid)
                userBalance.balance = balance!
                KNCoreDataManager.sharedInstance.saveContext()
            }
            else{
                //in case API fails
            }
            
        }
        
        var userBalance = KNCoreDataManager.sharedInstance.findTipperUserBalance(userid)
        return Float(userBalance.balance)
    }
    
    
    
    
    
    func hasSavedUser() -> Bool {
        
        if self.currentUser() == nil {
            
            return false
        }
        
        return true
    }
    
    func saveAccountInfoWithPass(userId:String ,pass:String, accessToken token:String) {
        
        var keychainPasswordItem:KeychainItemWrapper = KeychainItemWrapper(identifier: kItemNameKeychainPassowrd, accessGroup: nil)
        keychainPasswordItem.setObject(userId, forKey: kSecAttrLabel)
        keychainPasswordItem.setObject(pass, forKey: kSecValueData)
        keychainPasswordItem.setObject(token, forKey: kSecAttrAccount)
    }
    
    func resetUser() {
        //delete it from core data
        var curUser:KNMobileUser = self.currentUser()!
        
        KNCoreDataManager.sharedInstance.managedObjectContext?.deleteObject(curUser)
        KNCoreDataManager.sharedInstance.saveContext()
        
        var keychainPasswordItem:KeychainItemWrapper = KeychainItemWrapper(identifier: kItemNameKeychainPassowrd, accessGroup: nil)
        keychainPasswordItem.resetKeychainItem()
         self.currentEmailExistanceResponse = KNEmailExistResponse()
        
    }
    
    func accessToken() -> String? {
        
        let keychainPasswordItem:KeychainItemWrapper = KeychainItemWrapper(identifier: kItemNameKeychainPassowrd, accessGroup: nil)
        
        let accessToken = keychainPasswordItem.objectForKey(kSecAttrAccount) as String?
        
        if accessToken == nil {
            return ""
        }
        
        return accessToken
    }

    
    func pinCode() -> String? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let  pinCode:String = userDefaults.stringForKey("pincode"){
            return pinCode
        }
        else{
            return ""
        }
      
        
      
        
        
       /*
        let keychainPasswordItem:KeychainItemWrapper = KeychainItemWrapper(identifier: kItemNameKeychainPassowrd, accessGroup: nil)
        
        let pinCode = keychainPasswordItem.objectForKey(kSecAttrService) as String?
        
        if pinCode == nil {
            return ""
        }
        */
        //return pinCode
    }
    
    func sendDeviceToken(deviceToken token:NSData,   completed: (responseObj: KNAPIResponse) -> ()){
         KNAPIManager.sharedInstance.sendDeviceToken(deviceToken: token) { (responseObj) -> () in
             
        }
    }
    
    //we store the result in core data and assign it to a temporary user property in the app delegate
    func checkIfUserExistByEmail(emailAddress email: String,completed:(success: Bool,found:Bool, emailExistResponse:KNEmailExistResponse?,apiResponse: KNAPIResponse) -> ()){
       //clean before we move on
        self.currentEmailExistanceResponse = KNEmailExistResponse(email:email, pendingRegistration:true)
        
       KNAPIManager.sharedInstance.checkIfUserExistByEmail(emailAddress: email) { (success, responseObj) -> () in
        if (success){
            if(responseObj.status! == kAPIStatusOk){
               //create an object
                if(responseObj.dataObject!.objectForKey("id") != nil) {
                    self.currentEmailExistanceResponse = KNEmailExistResponse(dataObject: responseObj.dataObject! as NSDictionary)
                    completed(success: success, found:true, emailExistResponse:KNEmailExistResponse(dataObject: responseObj.dataObject! as NSDictionary), apiResponse: responseObj)
                }
               
            }
            else{
                //there might be a 1002 error code meaning the email is NOT registered on the server
                for error:KNAPIResponse.APIError in responseObj.errors {
                    if(error.errorCode == "1002") {
                        completed(success: success,found:false, emailExistResponse:self.currentEmailExistanceResponse, apiResponse: responseObj)
                    }
                }
            }
        }
        else{
            completed(success: success, found:false, emailExistResponse:KNEmailExistResponse(), apiResponse: responseObj)
        }
        
        }
    }
    
    func fetchProfileFromServer(){
        KNAPIManager.sharedInstance.fetchtUserProfile { (success, responseObj) -> () in
            //
        }
    }
    
    func updateUser(emailAddress email: String,publicName:String, avatarName:String, password:String, paypalEmail:String, completed:(success: Bool, errors: [(KNAPIResponse.APIError)]?) -> ()){
        KNAPIManager.sharedInstance.updateUser(emailAddress: email, publicName: publicName,  avatarName:avatarName, password:password, paypalEmail:paypalEmail) { (success, responseObj) -> () in
            if(responseObj.status! == kAPIStatusOk){
                //Save it here so Core data is updated automacally
                completed(success:true ,errors: nil)
            }
            else {
                completed(success:false,  errors: responseObj.errors)
            }
        }
        
    }
    
    
    func updateNotificationSettings(acceptNotifications:Bool,completed:(success: Bool, responseObj: KNAPIResponse) -> ()){
       KNAPIManager.sharedInstance.updateNotificationSettings(acceptNotifications) { (success, responseObj) -> () in
            completed(success:success,  responseObj: responseObj)
        }
    }
    //MARK to keep track of user authorization
    func updateUserLocationManagerSettings(allowed:Bool,completed:(success: Bool, responseObj: KNAPIResponse) -> ()){
        KNAPIManager.sharedInstance.updateUserLocationManagerSettings(allowed) { (success, responseObj) -> () in
            completed(success:success,  responseObj: responseObj)
        }
    }
    
    func updateUserAcceptAddressbookSettings(allowed:Bool,completed:(success: Bool, responseObj: KNAPIResponse) -> ()){
        KNAPIManager.sharedInstance.updateUserAcceptAddressbookSettings(allowed) { (success, responseObj) -> () in
            completed(success:success,  responseObj: responseObj)
        }
    }
    
    
    
    
    
    //TODO obsolete because of KNAvatarManager
    func updateAvatar(avatarImage: UIImage,  completed:(success: Bool, errors: [(KNAPIResponse.APIError)]?) -> ()){
        
        var avatarURLString = ""
        var user = KNMobileUserManager.sharedInstance.currentUser()!
        KNAPIManager.sharedInstance.updateUserAvatar(avatarURLString, email: user.email, publicName: user.publicName) { (success, responseObj) -> () in
            if(responseObj.status! == kAPIStatusOk){
                //
                completed(success:true ,errors: nil)
            }
            else {
                completed(success:false,  errors: responseObj.errors)
            }
        }
        
    }
    
    func hasAddressBookSynchronized()->Bool{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if !userDefaults.boolForKey(kAddressBookSynced) {
           return false
        }
        else{
            return userDefaults.boolForKey(kAddressBookSynced)
        }
    }
    
    func setAddressBookSynchronized(val:Bool){
         let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(val, forKey: kAddressBookSynced)
        userDefaults.synchronize()
    }
    
    func hasPinCode()->Bool{
        return self.currentUser()!.hasPinCode.boolValue
         // self.currentUser()!.hasPinCode.boolValue

    }
  
    func checkPincode(completed: (success: Bool, changed: Bool?, errors: [(KNAPIResponse.APIError)]?) -> ()){

        
        if let pincCode:String? = self.pinCode(){
            
            if pincCode?.length == 4{
                completed(success:true, changed: true,errors: nil)
            }
            else{
                completed(success:true, changed: false,errors: nil)
            }
            
        }
        else{
            
            //only call server in case we cant check in keychain
            KNAPIManager.sharedInstance.checkPinCode { (success, responseObj) -> () in
                if(responseObj.status! == kAPIStatusOk){
                    var changed: Bool = responseObj.dataObject!.objectForKey("changed")!.boolValue
                    completed(success:true, changed: changed,errors: nil)
                }
                else {
                    completed(success:false, changed:false, errors: responseObj.errors)
                }
            }
        }
        
        
        
        
       
    }
    
    //savePinCode
 
    func savePinCode(pincode:String, completed: (success: Bool, errors: [(KNAPIResponse.APIError)]?) -> ()){
        
        KNAPIManager.sharedInstance.savePinCode(pincode, completed: { (success, responseObj) -> () in
            if(responseObj.status! == kAPIStatusOk){
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setValue(pincode, forKey:"pincode")
                
                userDefaults.synchronize()
                
                //let keychainPasswordItem:KeychainItemWrapper = KeychainItemWrapper(identifier: kItemNameKeychainPassowrd, accessGroup: nil)
                // keychainPasswordItem.setObject(pincode, forKey: kSecAttrService)
                 completed(success:true, errors: nil)
            }
            else {
                completed(success:false,  errors: responseObj.errors)
            }
        })
    }

    
    func updateUserLanguage(completed: (success: Bool, errors: [(KNAPIResponse.APIError)]?) -> ()){
        var languageCode:String = NSBundle.mainBundle().preferredLocalizations[0] as String
        KNAPIManager.sharedInstance.updateUserLanguage(languageCode) { (success, responseObj) -> () in
            if(responseObj.status! == kAPIStatusOk){
               
                completed(success:true, errors: nil)
            }
            else {
                
                completed(success:false,  errors: responseObj.errors)
            }
        }
    }

    
    //MARK Core Data
    func fetchUser(userId:String) -> KNMobileUser?{
       
        let context:NSManagedObjectContext = KNCoreDataManager.sharedInstance.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"KNMobileUser")
        let predicate:NSPredicate = NSPredicate(format:" userId == '\(userId)'")!
        
        fetchRequest.predicate=predicate
        var error: NSError?
        let results:NSArray = context.executeFetchRequest(fetchRequest, error:&error)!
        
        if(results.count == 1){
            let foundMobileUser:KNMobileUser = results.lastObject as KNMobileUser
            return foundMobileUser
        }
        else{
            return nil
        }

    }
    
         
    
   
    
}

