//
//  KNAPIManager.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 11/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit
import Foundation

class KNAPIManager {
    
    // MARK: Shared Instance
    class var sharedInstance : KNAPIManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNAPIManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNAPIManager()
        }
        return Static.instance!
    }
    
    init() {
        
    }
    
    //MARK get accessToken for current logged in user
    
    func currentUserAccessToken() -> Dictionary<String, String>{
        if (KNMobileUserManager.sharedInstance.accessToken() != nil) {
            return ["access_token": KNMobileUserManager.sharedInstance.accessToken()!]
        }
        return Dictionary<String, String>()
    }
    
    
    //****************************************************************************************************************************************
    //********
    //********      Called via KNLoginManager
    //********
    //********
    
    //Mark Login User called via KNLoginManager
    func loginUser(email: String, password: String,  completed:(success: Bool, responseObj: KNAPIResponse) -> ()){
        let params: Dictionary<String, String> = ["email" : email, "password": password]
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPILogin) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
        }
    }
    
    func logoutUser(completed: (success: Bool,responseObj: KNAPIResponse) -> ()) {
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(self.currentUserAccessToken(), url: kAPILogout) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
        }
    }
    
    
    //********
    //****************************************************************************************************************************************
    
    
    
    
    
    //****************************************************************************************************************************************
    //********
    //********      Called via KNRegistrationManager
    //********
    //********
    
    
    // **** STEP 1
    
    // MARK: Create account
    func registerUser(email:String, username:String, password:String, confirmPassword:String, avatar:String,completed:(success: Bool,responseObj: KNAPIResponse) -> ()) {
        
        let params: Dictionary<String, String> = ["avatar": avatar,"email" : email, "publicName": username, "password": password, "confirmPassword": confirmPassword, "appVersion": KNHelperManager.sharedInstance.getAppVersion()]
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIRegister) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
            
            
        }
        
    }
    
    // **** STEP 2
    func addMobileNumber(userId: String, mobile: String, completed: (success: Bool,responseObj: KNAPIResponse) -> ()) {
        var trimmedMobileNumber:String = mobile.trimmedPhoneNumber
        let params: Dictionary<String, String> = ["userId" : userId, "mobile" : trimmedMobileNumber]
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIRequestVerification) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
        }
    }
    
    func addMobileNumberAndCountryCode(userId: String, mobile: String, countryCode:String, completed: (success: Bool,responseObj: KNAPIResponse) -> ()) {
        var trimmedMobileNumber:String = mobile.trimmedPhoneNumber
        let params: Dictionary<String, String> = ["userId" : userId, "mobile" : trimmedMobileNumber,"countryCode":countryCode]
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPISendVerificationRequest) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
        }
    }
    
    // **** STEP 3
 
    func sendVerificationCode(userId: String, verificationCode: String, completed: (success: Bool,responseObj: KNAPIResponse) -> ()) {
        
        let params: Dictionary<String, String> = ["userId": userId, "code": verificationCode]
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIPhoneVerification) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
            
        }
    }
    
    
    
  
    
    
    //*** Optional 3B
    
    func requestNewVerificationCode(userId: String, completed: (success: Bool,responseObj: KNAPIResponse) -> ()) {
        
        let params: Dictionary<String, String> = ["userId" : userId]
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIResendCodeToPhone) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
        }
    }
    
    //*** Step 4 optional
    
    func cancelRegistration(userId: String, completed: (success: Bool,responseObj: KNAPIResponse) -> ()) {
        
        let params: Dictionary<String, String> = ["userId": userId]
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIDeleteRegister) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
        }
    }
    
    //********
    //****************************************************************************************************************************************
    
    
    
    //****************************************************************************************************************************************
    //********
    //********  Called via KNMobileUserManager
   
    
    func sendDeviceToken(deviceToken token:NSData, completed: (responseObj: KNAPIResponse) -> ()){
        
        #if TARGET_IPHONE_SIMULATOR
            
            #else
            
            var cleanDeviceToken:NSString = token.description  as NSString
            
            cleanDeviceToken = cleanDeviceToken.stringByReplacingOccurrencesOfString("<", withString: "") as NSString
            cleanDeviceToken = cleanDeviceToken.stringByReplacingOccurrencesOfString(">", withString: "") as NSString
            cleanDeviceToken = cleanDeviceToken.stringByReplacingOccurrencesOfString(" ", withString: "") as NSString
            
            var params:Dictionary<String, String> = ["deviceToken": cleanDeviceToken]
            params.append(self.currentUserAccessToken())
            KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPISendDeviceToken, postCompleted: { (success, apiResponse) -> () in
                completed(responseObj: apiResponse)
            })
        #endif
        
    }
    
    // MARK: Check email exist
    
    func checkIfUserExistByEmail(emailAddress email: String,completed:(success: Bool, responseObj: KNAPIResponse) -> ()){
        let params: Dictionary<String, String> = ["email" : email]
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPICheckEmailExist) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
        }
    }
    
    //OBSOLETE
    /*
    func forgotPassword(mobile:String,completed:(success: Bool, responseObj: KNAPIResponse) -> ()){
        
        var params:Dictionary<String, String> = ["mobile": mobile]
        params.append(self.currentUserAccessToken())
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIForgotPassword) { (success, apiResponse) -> () in
           completed(success:success, responseObj: apiResponse)
        }
    }
    */
    
    // MARK:  User Profile
    func fetchtUserProfile(completed:(success: Bool, responseObj: KNAPIResponse) -> ()){
        let params: Dictionary<String, String> = ["access_token": KNMobileUserManager.sharedInstance.currentUser()!.accessToken]
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIGetProfile) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
        }
    }
    
    
    func updateNotificationSettings(acceptNotifications:Bool,completed:(success: Bool, responseObj: KNAPIResponse) -> ()){
        var params: Dictionary<String, AnyObject> = ["acceptNotifications": acceptNotifications]
        params.append(self.currentUserAccessToken())
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIUpdateNotificationSettings) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
        }
    }
    
    func updateUserLocationManagerSettings(allowed:Bool,completed:(success: Bool, responseObj: KNAPIResponse) -> ()){
        var params: Dictionary<String, AnyObject> = ["allowed": allowed]
        params.append(self.currentUserAccessToken())
        
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIUserAcceptedLocationManager) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
        }
    }
    
    func updateUserAcceptAddressbookSettings(allowed:Bool,completed:(success: Bool, responseObj: KNAPIResponse) -> ()){
        var params: Dictionary<String, AnyObject> = ["allowed": allowed]
        params.append(self.currentUserAccessToken())
          
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIUserAcceptedAddressBookAccess) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
        }
    }
    
    
    
    func updateUserLanguage(languageCode: String, completed: (success: Bool,responseObj: KNAPIResponse) -> ()) {
        var params: Dictionary<String, String> = ["languageCode": languageCode]
        params.append(self.currentUserAccessToken())
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIsetUserLangauge) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
            
        }
    }
  
    func updateUserAvatar(avatar: String, email: String,publicName: String, completed: (success: Bool,responseObj: KNAPIResponse) -> ()) {
        var params: Dictionary<String, String> = ["avatar": avatar,"email" : email, "publicName": publicName]
        params.append(self.currentUserAccessToken())
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIUpdateProfile) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
            
        }
    }
    
    //MARK to change email or public name
    func updateUser(emailAddress email: String,publicName:String,  avatarName:String, password:String, paypalEmail:String,  completed: (success: Bool,responseObj: KNAPIResponse) -> ()) {
        var params: Dictionary<String, String> = ["email" : email, "publicName": publicName, "avatar":avatarName, "password":password, "confirmPassword":password, "paypalEmail":paypalEmail]
        params.append(self.currentUserAccessToken())
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIUpdateProfile) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
            
        }
    }
    
    func changePassword(forMobile mobileNumber:String, resetCode:String, password: String,confirmPassword:String,  completed: (success: Bool,responseObj: KNAPIResponse) -> ()) {
        var params: Dictionary<String, String> = ["mobile" : mobileNumber, "code" : resetCode,"password" : password, "confirmPassword": confirmPassword]
        params.append(self.currentUserAccessToken())
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIUpdateProfile) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
            
        }
    }
    
    func savePinCode(pinCode: String, completed:(success: Bool, responseObj: KNAPIResponse) -> ()){
        var params: Dictionary<String, String> = ["password": KNMobileUserManager.sharedInstance.currentUser()!.password,"pincode" : pinCode]
        params.append(self.currentUserAccessToken())
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPISetUpPinCode) { (success, apiResponse) -> () in
           completed(success:success, responseObj:apiResponse)
        }
    }
    
     func checkPinCode(completed:(success: Bool, responseObj: KNAPIResponse) -> ()){
        let params: Dictionary<String, String> = ["access_token": KNMobileUserManager.sharedInstance.currentUser()!.accessToken]
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPICheckPinCode) { (success, apiResponse) -> () in
            completed(success:success, responseObj:apiResponse)
            
        }
    }
    
    //********
    //****************************************************************************************************************************************
    
    
 
    
    
    
    
    
    
    
    
    
    // MARK: Get current blance
    func getCurrentBlance(accessToken: String, completed:(success: Bool, balance: Float?, errors: [(KNAPIResponse.APIError)]?) -> ()){
        
        let params: Dictionary<String, String> = ["access_token": accessToken]
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIGetCurrentBlance) { (success, apiResponse) -> () in
            if(apiResponse.status! == kAPIStatusOk){
                var balance: Float = apiResponse.dataObject!.objectForKey("balance")!.floatValue
                completed(success:true, balance: balance, errors: nil)
            }
            else {
                completed(success:false, balance: nil, errors: apiResponse.errors)
            }
            
        }
    }
   
    
    //****************************************************************************************************************************************
    //********  KNFriendManager
    
   
    // MARK: Friends
    func getListOfFriends(completed: (responseObj: KNAPIResponse) -> ()) {
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(self.currentUserAccessToken(), url: kAPIGetListOfFriends) { (success, apiResponse) -> () in
            completed(responseObj: apiResponse)
        }
    }
    
    func getListOfFiends(keyword: String, completed: (responseObj: KNAPIResponse) -> ()) {
        var params: Dictionary<String, String> = ["text": keyword,"limit":kSearchResultLimit]
        params.append(self.currentUserAccessToken())
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPISearchFriends) { (success, apiResponse) -> () in
            completed(responseObj: apiResponse)
        }
    }
    
    
    func getListOfFiendsNearby(completed: (responseObj: KNAPIResponse) -> ()) {
        var params:Dictionary<String,String> = ["access_token":KNMobileUserManager.sharedInstance.currentUser()!.accessToken]
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIFriendsNearby) { (success, apiResponse) -> () in
            completed(responseObj: apiResponse)
        }
    }
    
    
    
    
    func addFriend(friendId: String, completed: (responseObj: KNAPIResponse) -> ()) {
        var params:Dictionary<String, String> = ["friendId": friendId]
        params.append(self.currentUserAccessToken())
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIAddFriend) { (success, apiResponse) -> () in
            completed(responseObj: apiResponse)
        }
    }
    
    
    func markAsFavorite(friendId: String,isFavorite:Bool, completed: (responseObj: KNAPIResponse) -> ()) {
        var params:Dictionary<String, AnyObject> = ["friendId": friendId,"isFavorite":isFavorite]
        params.append(self.currentUserAccessToken())
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIFavorite) { (success, apiResponse) -> () in
            
            
            completed(responseObj: apiResponse)
        }
    }

    func discoverFriendProfile(friendId: String, completed: (responseObj: KNAPIResponse) -> ()) {
        var params:Dictionary<String, AnyObject> = ["friendId": friendId]
        params.append(self.currentUserAccessToken())
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIDiscoverFriendProfile) { (success, apiResponse) -> () in
            
            
            completed(responseObj: apiResponse)
        }
    }



    
    //********
    //****************************************************************************************************************************************
    
    //****************************************************************************************************************************************
    //********  KNCMSPageManager
    
    
    func fetchCMSPageBySlug(slug:String, completed: (success:Bool, responseObj: KNAPIResponse) -> ()) {
       
        
        
        var fullURL:String = kAPIGetCMSPageBySlug + slug
              KNCommunicationsManager.sharedInstance.postAndReturnDictionaryWithoutParameters(fullURL) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
        }
    }
    
    func fetchAllCMSPages(completed: (success:Bool, responseObj: KNAPIResponse) -> ()) {
          var params:Dictionary<String, String> = ["": ""]
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIGetCMSPages) { (success, apiResponse) -> () in
              completed(success:success, responseObj: apiResponse)
        }
        /*
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionaryWithoutParameters(kAPIGetCMSPages) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
            
        }
*/
    }
    
    //********
    //****************************************************************************************************************************************
    
    
    
    //****************************************************************************************************************************************
    //********  KNAddressBookManager
    
    
    //MARK: Sync address book
    func synAddressBook(contacts:Array<KNAddressRecord>, completed: (responseObj: KNAPIResponse) -> ()){
        
        var contactsParam:Array<Dictionary<String, String>> = Array<Dictionary<String, String>>()
        for contact:KNAddressRecord in contacts {
            
            let phone:String = contact.phoneNumbers != nil && contact.phoneNumbers!.count > 0 ? contact.phoneNumbers![0] : ""
            let email:String = contact.emails != nil && contact.emails!.count > 0 ? contact.emails![0] : ""
            
            let param:Dictionary<String, String> = ["id":"\(contact.recID!)", "p":"\(phone)", "e":"\(email)"]
            
            contactsParam.append(param)
        }
        var params: Dictionary<String, AnyObject> = ["contacts": contactsParam]
        params.append(self.currentUserAccessToken())
        
        KNCommunicationsManager.sharedInstance.postMultipartAndReturnDictionary(params, url: kAPISyncAddressBook) { (success, apiResponse) -> () in
            completed(responseObj: apiResponse)
        }
        
    }
    
    func getTaskId(completed: (responseObj: KNAPIResponse) -> ()) {
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(self.currentUserAccessToken(), url: kAPIGetTaskId) { (success, apiResponse) -> () in
            completed(responseObj: apiResponse)
        }
    }
    
    func getTaskStatus(taskId: String, completed: (responseObj: KNAPIResponse) -> ()) {
        var params: Dictionary<String, String> = ["taskId": taskId]
        params.append(self.currentUserAccessToken())
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPITaskStatus) { (success, apiResponse) -> () in
            completed(responseObj: apiResponse)
        }
    }
    //********
    //****************************************************************************************************************************************
   
    
    
    //****************************************************************************************************************************************
    //********  KNTipperCardManager
    //MARK: Cards
    func addCreditCard(brand: String, cardNumber: String, expMonth: String, expYear: String, cvc: String, firstName:String, lastName:String, completed: (responseObj: KNAPIResponse) -> ()) {
        
        // Marked by luokey
//        var params:Dictionary<String, String> = ["name": name, "cardNumber": cardNumber, "expMonth": expMonth, "expYear": expYear, "cvc": cvc,"firstName":firstName,"lastName":lastName]
        
        // Modified By luokey
        var name:NSString = NSString(format: "%@ %@", firstName, lastName)
        name = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        var params:Dictionary<String, String> = [
            "name": name,
            "brand": brand.lowercaseString,
            "cardNumber": cardNumber,
            "expMonth": expMonth,
            "expYear": expYear,
            "cvc": cvc,
//            "firstName":firstName,
//            "lastName":lastName
        ]
        
        
        params.append(self.currentUserAccessToken())
       
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIAddCard) { (success, apiResponse) -> () in
            completed(responseObj: apiResponse)
        }
    }
    
    
    
    // Get list registered cards
    func fetchCards(completed: (cards:NSArray?, responseObj: KNAPIResponse) -> ()) {
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(self.currentUserAccessToken(), url: kAPIListRegisteredCards) { (success, apiResponse) -> () in
            
            var allCards:NSArray = NSArray()
            if (apiResponse.status == kAPIStatusOk) {
                if let fetchedCards:NSArray = apiResponse.dataObject! as? NSArray{
                    allCards = fetchedCards
                }
            }
            completed(cards: allCards, responseObj: apiResponse)
        }
    }
    
    // Delete a Credit card
    func deleteTipperCard(cardId: String, completed:(success: Bool, responseObj: KNAPIResponse) -> ()) {
        var params:Dictionary<String, String> = ["cardId": cardId]
        params.append(self.currentUserAccessToken())

        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIDeleteTipperCard) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
        }
    }
    
    func addDebitCard(brand: String, cardNumber: String, expMonth: String, expYear: String, cvc: String,firstName:String, lastName:String, completed: (responseObj: KNAPIResponse) -> ()) {
        
        // Marked by luokey
//        var params:Dictionary<String, String> = ["name": name, "cardNumber": cardNumber, "expMonth": expMonth, "expYear": expYear, "cvc": cvc, "firstName":firstName,"lastName":lastName]
        
        // Added By luokey
        var name:NSString = NSString(format: "%@ %@", firstName, lastName)
        name = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        var params:Dictionary<String, String> = [
            "name": name,
            "brand": brand.lowercaseString,
            "cardNumber": cardNumber,
            "expMonth": expMonth,
            "expYear": expYear,
            "cvc": cvc,
//            "firstName":firstName,
//            "lastName":lastName
        ]
        
        params.append(self.currentUserAccessToken())
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIDebitAddCard) { (success, apiResponse) -> () in
            completed(responseObj: apiResponse)
        }
    }
    
    //********
    //****************************************************************************************************************************************
    
    
    
    //****************************************************************************************************************************************
    //********  KNLocationManager
    
    
    
    func updateUserLocation(Coordinates latitude:String, longitude:String ,completed:(success: Bool, responseObj: KNAPIResponse) -> ()){
        var params:Dictionary<String, String> = ["latitude": latitude, "longitude": longitude]
        params.append(self.currentUserAccessToken())
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIUpdateUserLocation) { (success, apiResponse) -> () in
            completed(success:success,responseObj: apiResponse)
        }

        
    }
    //********
    //****************************************************************************************************************************************
   
    
    //****************************************************************************************************************************************
    //********  KNPasswordManager
    
    
    //REQUEST email
    func forgotPasswordWithEmail(email:String,   completed:(success: Bool, responseObj: KNAPIResponse) -> ()){
        var params:Dictionary<String, String> = ["email": email]
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIForgotPasswordWithEmail) { (success, apiResponse) -> () in
            completed(success:success,responseObj: apiResponse)
        }
    }
    
    //REQUEST SMS with a code
    func forgotPasswordWithMobile(mobile:String, completed:(success: Bool, responseObj: KNAPIResponse) -> ()){
        var params:Dictionary<String, String> = ["mobile": mobile]
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIForgotPasswordWithMobile) { (success, apiResponse) -> () in
            completed(success:success,responseObj: apiResponse)
        }
    }
    
    //RESET
    
    func resetPasswordWithEmail(token:String, password:String, confirmPassword:String, completed:(success: Bool, responseObj: KNAPIResponse) -> ()){
        var params:Dictionary<String, String> = ["token":token,"password":password,"confirmPassword":confirmPassword ]
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIResetPasswordWithEmail) { (success, apiResponse) -> () in
            completed(success:success,responseObj: apiResponse)
        }
    }
    
    
    func resetPasswordWithMobile(mobile:String, code:String, password:String, confirmPassword:String,  completed:(success: Bool, responseObj: KNAPIResponse) -> ()){
       var params:Dictionary<String, String> = ["mobile": mobile, "code":code,"password":password,"confirmPassword":confirmPassword ]
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIResetPasswordWithMobile) { (success, apiResponse) -> () in
            completed(success:success,responseObj: apiResponse)
        }
    }

    
    
    
    
    
    //********
    //****************************************************************************************************************************************
    
    
    
    //****************************************************************************************************************************************
    //********  KNTipperManager
    
    func tipAFriend(friendId:String, amountInCents:String, cardId:String, pinCode:String,completed: (success: Bool,responseObj: KNAPIResponse) -> ()) {
        var params: Dictionary<String, String> = ["amount":amountInCents, "friendId":friendId, "pincode":pinCode,"cardId":cardId]
        params.append(self.currentUserAccessToken())
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIBalanceTip) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
        }
    }
    
    func tipAnUnknown(sendTo:String, amountInCents:String, cardId:String, pinCode:String,completed: (success: Bool,responseObj: KNAPIResponse) -> ()) {
        var params: Dictionary<String, String> = ["amount":amountInCents, "text":sendTo, "pincode":pinCode,"cardId":cardId]
        params.append(self.currentUserAccessToken())
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPITipNonExistingUser) { (success, apiResponse) -> () in
            completed(success:success, responseObj: apiResponse)
        }
    }
    
    
    
    //********
    //****************************************************************************************************************************************
    
    
    
    //****************************************************************************************************************************************
    //********  KNTipperHistoryManager
    
    
    // Get Send Tip History List
    func getTipHistoryList(completed: (responseObj: KNAPIResponse) -> ()) {
        
        var params:Dictionary<String,String> = ["access_token":KNMobileUserManager.sharedInstance.currentUser()!.accessToken]
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIListTipHistory) { (success, apiResponse) -> () in
            completed(responseObj: apiResponse)
        }
    }
    
    // Get Received Tip History List
    func getReceivedTipHistoryList(completed: (responseObj: KNAPIResponse) -> ()) {
        
        var params:Dictionary<String,String> = ["access_token":KNMobileUserManager.sharedInstance.currentUser()!.accessToken]
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIReceivedTipHistory) { (success, apiResponse) -> () in
            completed(responseObj: apiResponse)
        }
    }
    //********
    //****************************************************************************************************************************************
    
    
    //****************************************************************************************************************************************
    //********  KNTipperWtihdrawManager
  
    
    func fetchBalance(completed: (success: Bool,balance: Float?, responseObj: KNAPIResponse) -> ()){
        var params:Dictionary<String,String> = ["access_token":KNMobileUserManager.sharedInstance.currentUser()!.accessToken]
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIGetCurrentBlance) { (success, apiResponse) -> () in
            
            if(apiResponse.status! == kAPIStatusOk){
                var balance: Float = apiResponse.dataObject!.objectForKey("balance")!.floatValue
                completed(success:success, balance: balance, responseObj: apiResponse)
            }
            else {
                completed(success:success, balance: nil, responseObj: apiResponse)
            }
        }
    }
    
    
    // Withdraw balance to a debitCard
    func withdrawBalance(toCard debitCard: TipperCard, amount amountInCents:String, pincode:String, completed: (success: Bool,responseObj: KNAPIResponse) -> ()) {
        
        
        var params:Dictionary<String, String> = ["cardId": debitCard.id, "firstName": debitCard.firstName, "lastName": debitCard.lastName, "amount": amountInCents, "pincode":pincode]
        params.append(self.currentUserAccessToken())
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIWithdrawBalance) { (success, apiResponse) -> () in
            
            
           
            completed(success:success, responseObj: apiResponse)
        }
    }
    
    // Added by luokey
    // Withdraw balance to a Paypal account
    func withdrawBalanceToPaypal(amount amountInCents:String, pincode:String, completed: (success: Bool,responseObj: KNAPIResponse) -> ()) {
        
        
        var params:Dictionary<String, String> = ["amount": amountInCents, "pincode":pincode]
        params.append(self.currentUserAccessToken())
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIWithdrawBalance) { (success, apiResponse) -> () in
            
            
            
            completed(success:success, responseObj: apiResponse)
        }
    }
    
    //********
    //****************************************************************************************************************************************
    

    //TODO Delete Debit a card
    func deleteDebitCard(cardId: String, completed:(responseObj: KNAPIResponse) -> ()) {
        
        var params:Dictionary<String, String> = ["cardId": cardId]
        params.append(self.currentUserAccessToken())
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPIDeleteDebitCard) { (success, apiResponse) -> () in
            completed(responseObj: apiResponse)
        }
    }
    
    //TODO Set default Debit card
    func setDefaultDebitCard(cardId: String, completed:(responseObj: KNAPIResponse) -> ()) {
        
        var params:Dictionary<String, String> = ["cardId": cardId]
        params.append(self.currentUserAccessToken())
        
        KNCommunicationsManager.sharedInstance.postAndReturnDictionary(params, url: kAPISetDefaultDebitCard) { (success, apiResponse) -> () in
            completed(responseObj: apiResponse)
        }
    }
}
