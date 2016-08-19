//
//  KNProcessManager.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 10/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit
import Foundation

protocol KNProcessManagerDelegate {
   
    func processcom()
     
}


class KNProcessManager :NSObject  , KNAddressBookManagerDelegate,  KNBLETransmitterDelegate {
    
    
    class var sharedInstance : KNProcessManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNProcessManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNProcessManager()
        }
        return Static.instance!
    }
    var delegate:KNProcessManagerDelegate?
    
    
    
    override init() {
        super.init()
        KNAddressBookManager.sharedInstance.delegate = self
        KNAddressBookManager.sharedInstance.requestAccessContact()
    }
    
    //The process manager controls events specific for this application behaviour
    
    
    // KNAddressBookManager Delegeates
    //MARK: KNAddressBookDelegate is invoked first time when access is granted
  
    func didCompleteRequestAccessContact(accessGranted isAuthorized: Bool) {
        // fetch history
        
       
        //KNAddressBookManager.sharedInstance.startSyncProcess()
    }
    
    
    
    
    func runProcessOnApplicationLaunch(){
      
        //Always load to see if there are updates privacy and terms
        KNCMSPageManager.sharedInstance.fetchAllPages { (success) -> () in
            
        }
        
    }
    
    
    
    func runProcessesOnReturningToTheApp(){
      
        if KNMobileUserManager.sharedInstance.hasSavedUser(){
            //download user's credit and debit cards
            
            
             KNTipperCardManager.sharedInstance.fetchCardsFromServer(forUser: KNMobileUserManager.sharedInstance.currentUser()!, completed: { (responseObj) -> () in
                
            })
            
            KNMobileUserManager.sharedInstance.updateUserLanguage({ (success, errors) -> () in
                
            })
            
            
            //We can start transmitting our BLE data here

            //Peter initialize queues 
            KNBLEReceiver.sharedInstance
            KNBLETransmitter.sharedInstance

           
            var me:KNMobileUser = KNMobileUserManager.sharedInstance.currentUser()!
            let userId = me.userId
            //let transmitterDictionary : Dictionary<String,String> = ["friendId": userId, "avatarURL":me.avatar,"publicName":me.publicName]
              let transmitterDictionary : Dictionary<String,String> = ["friendId": userId,"publicName":me.publicName]  
            KNBLETransmitter.sharedInstance.delegate = self
            KNBLETransmitter.sharedInstance.initService(userId, userDictionaryData:transmitterDictionary)
            KNBLETransmitter.sharedInstance.turnOn(true)
            
            
        }
        //Always load to see if there are updates privacy and terms
        
        
    }
    
    
    //MARK KNBLETransmitter delegate
    
    func transmitter(transmitter: KNBLETransmitter, powerStateChanged on: Bool) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
             println("[X] powerStateChanged   \(on)")
            KNBLETransmitter.sharedInstance.turnOn(on)
        })
    }
    
    
    
    
    
    
    
    
    func runProcessesAfterLoginSucceeded(){
       
        //Let's download cards after login. In case  people are using  multiple devices with same account
        if KNMobileUserManager.sharedInstance.hasSavedUser(){
            //download user's credit and debit cards
            
            KNMobileUserManager.sharedInstance.updateUserLanguage({ (success, errors) -> () in
                
            })
            
            KNTipperCardManager.sharedInstance.fetchCardsFromServer(forUser: KNMobileUserManager.sharedInstance.currentUser()!, completed: { (responseObj) -> () in
                
            })
            KNTipperHistoryManager.sharedInstance.fetchBalanceAndHistoryFromServer(KNMobileUserManager.sharedInstance.currentUser()!)
        }
         
    }
    
    
    
    func runProcessesAfterLogoutSucceeded(){
      
    }
    
    func runProcessesWhenApplicationCloses(){
      
        
        if !KNMobileUserManager.sharedInstance.hasSavedUser(){
            //If we dont have a saved user let's check if we have a pending registration
            if KNMobileUserManager.sharedInstance.currentEmailExistanceResponse.pendingRegistration{
                //we need to cancel it
               
                KNRegistrationManager.sharedInstance.cancelRegistration(KNMobileUserManager.sharedInstance.currentEmailExistanceResponse.userId, completed: { (success, errors) -> () in
                    
                })
            }
        }
        
    }
    
    func didFinishSynchronization() {
       
    }
    
    

    
}

