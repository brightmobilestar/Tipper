//
//  KNAddressBookManager.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 10/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit
import Foundation
import AddressBook

protocol KNAddressBookManagerDelegate {
    
     func didCompleteRequestAccessContact(accessGranted isAuthorized:Bool)
     func didFinishSynchronization()
}



class KNAddressBookManager:NSObject {
    
    class var sharedInstance : KNAddressBookManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNAddressBookManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNAddressBookManager()
        }
        return Static.instance!
    }
    
    override init() {
        super.init()
    }
    
 
    
    var taskId: String = ""
    var checkCounter: Int = 0
    let maxCheck: Int = 25
    let delayPerCheck: Double = 1 //second
    
    var delegate:KNAddressBookManagerDelegate?
    
    
    
    lazy var addressBook: ABAddressBookRef = {
        var error: Unmanaged<CFError>?
        return ABAddressBookCreateWithOptions(nil,
            &error).takeRetainedValue() as ABAddressBookRef
        }()
    
    
   
    //MARK callback handler
    //This can only be done in ObjC so therefore there s the KNAddresBookCallbackManager
    
    
    
    
    func accessGranted() -> Bool {
        
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        
        //Setup observer and register AB callback
         NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("startSyncProcess"), name: "KNAddressBookChanged", object: nil)
        
        
         KNAddressBookCallbackManager.sharedInstance()
        return (authorizationStatus == ABAuthorizationStatus.Authorized)
        
       
        
    }
    
    func hasRequestedAccessContact() -> Bool {
        
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        
        return (authorizationStatus != ABAuthorizationStatus.NotDetermined)
    }
    
    func requestAccessContact() {
        
        var accessGranted:Bool = false
        let strongSelf = self
        
        switch ABAddressBookGetAuthorizationStatus(){
        case .Authorized:
            accessGranted = true
            
            if KNMobileUserManager.sharedInstance.hasSavedUser(){
                KNMobileUserManager.sharedInstance.updateUserAcceptAddressbookSettings(true, completed: { (success, responseObj) -> () in
                    
                })
            }
            self.delegate?.didCompleteRequestAccessContact(accessGranted: accessGranted)
            
            
            
             case .Denied:
                
                if KNMobileUserManager.sharedInstance.hasSavedUser(){
                    KNMobileUserManager.sharedInstance.updateUserAcceptAddressbookSettings(false, completed: { (success, responseObj) -> () in
                        
                    })
                }
            strongSelf.delegate?.didCompleteRequestAccessContact(accessGranted: accessGranted)
            
        case .NotDetermined:
            ABAddressBookRequestAccessWithCompletion(addressBook,
                {[weak self] (granted: Bool, error: CFError!) in
                    if KNMobileUserManager.sharedInstance.hasSavedUser(){
                        KNMobileUserManager.sharedInstance.updateUserAcceptAddressbookSettings(accessGranted, completed: { (success, responseObj) -> () in
                            
                        })
                    }
                    if granted{
                        
                        strongSelf.delegate?.didCompleteRequestAccessContact(accessGranted: accessGranted)
                    } else {
                        
                        strongSelf.delegate?.didCompleteRequestAccessContact(accessGranted: accessGranted)
                    }
                    
            })
        default:
            if KNMobileUserManager.sharedInstance.hasSavedUser(){
                KNMobileUserManager.sharedInstance.updateUserAcceptAddressbookSettings(accessGranted, completed: { (success, responseObj) -> () in
                    
                })
            }
            self.delegate?.didCompleteRequestAccessContact(accessGranted: accessGranted)
        }
    }
    
    func fetchContactsFromAddressBook() -> Array<KNAddressRecord>{
        
        var contacts:Array<KNAddressRecord> = Array<KNAddressRecord>()
        
        if  !self.accessGranted() {
            
            return contacts
        }
        
        let addressBook: ABAddressBookRef = self.addressBook
        
        var allSources:NSArray? = ABAddressBookCopyArrayOfAllSources(addressBook).takeRetainedValue() as NSArray
        
        // Added by luokey
        if (allSources == nil || allSources!.count < 1) {
            return contacts
        }
        
        
        for source in allSources!   {
            
            
            let allPeople = ABAddressBookCopyArrayOfAllPeopleInSource(addressBook, source as ABRecord!).takeRetainedValue() as NSArray
            
           // let allPeople = ABAddressBookCopyArrayOfAllPeople(
           //     addressBook).takeRetainedValue() as NSArray
            
        
            for person: ABRecordRef in allPeople{
                
                
                var contact:KNAddressRecord = KNAddressRecord()
                
                
                var firstName: String? = ""
                var lastName: String? = ""
                if let takeRetainedFirstNameValue = ABRecordCopyValue(person, kABPersonFirstNameProperty) {
                    firstName = Unmanaged<NSObject>.fromOpaque(takeRetainedFirstNameValue.toOpaque()).takeRetainedValue() as? String
                }
                if let takeRetainedLastNameValue = ABRecordCopyValue(person, kABPersonLastNameProperty) {
                    lastName = Unmanaged<NSObject>.fromOpaque(takeRetainedLastNameValue.toOpaque()).takeRetainedValue() as? String
                }
                
                var recordId = String(ABRecordGetRecordID(person))
                
                var emails = readEmailsForPerson(person)
                
                var phones = readPhoneNumbersForPerson(person)
                
               //without emails and mobile its useless to sent it
                if (emails.count > 0 || phones.count > 0){
                    contact.recID = recordId
                    contact.firstName = firstName == nil ? "" : firstName!
                    contact.lastName = lastName == nil ? "" : lastName!
                    contact.emails = emails
                    contact.phoneNumbers = phones
                    contacts.append(contact)
                }
                
                
            }
            
        }
        // NSArray *sources = (__bridge NSArray *) sourcesRef;
        
            
            
        return contacts
    }
    
    
    
    
    
    
    /*
    func fetchContactsFromAddressBook() -> Array<KNAddressRecord>{
        
        var contacts:Array<KNAddressRecord> = Array<KNAddressRecord>()
        
        if  !self.accessGranted() {
            
            return contacts
        }
        
        let addressBook: ABAddressBookRef = self.addressBook
        
        /* Get all the people in the address book */
        let allPeople = ABAddressBookCopyArrayOfAllPeople(
            addressBook).takeRetainedValue() as NSArray
        
        for person: ABRecordRef in allPeople{
            
          
            var contact:KNAddressRecord = KNAddressRecord()
            
            
            var firstName: String? = ""
            var lastName: String? = ""
            if let takeRetainedFirstNameValue = ABRecordCopyValue(person, kABPersonFirstNameProperty) {
                firstName = Unmanaged<NSObject>.fromOpaque(takeRetainedFirstNameValue.toOpaque()).takeRetainedValue() as? String
            }
            if let takeRetainedLastNameValue = ABRecordCopyValue(person, kABPersonLastNameProperty) {
                lastName = Unmanaged<NSObject>.fromOpaque(takeRetainedLastNameValue.toOpaque()).takeRetainedValue() as? String
            }
            
            var recordId = String(ABRecordGetRecordID(person))
            
            var emails = readEmailsForPerson(person)
            
            var phones = readPhoneNumbersForPerson(person)
            
            contact.recID = recordId
            contact.firstName = firstName == nil ? "" : firstName!
            contact.lastName = lastName == nil ? "" : lastName!
            contact.emails = emails
            contact.phoneNumbers = phones
            
            println("contact \(contact.lastName)")
            contacts.append(contact)
        }
        
        return contacts
    }
    */
    func readEmailsForPerson(person: ABRecordRef) -> Array<String>{
        
        var returnedEmails:Array<String> = Array<String>()
        
        let emails: ABMultiValueRef = ABRecordCopyValue(person,
            kABPersonEmailProperty).takeRetainedValue()
        
        for counter in 0..<ABMultiValueGetCount(emails){
            
            let email = ABMultiValueCopyValueAtIndex(emails,
                counter).takeRetainedValue() as String
            
            returnedEmails.append(email.lowercaseString)
        }
        
        return returnedEmails
    }
    
    func readPhoneNumbersForPerson(person: ABRecordRef) -> Array<String>{
        
        var returnedPhones:Array<String> = Array<String>()
        let phones: ABMultiValueRef = ABRecordCopyValue(person,
            kABPersonPhoneProperty).takeRetainedValue()
        
        for counter in 0..<ABMultiValueGetCount(phones){
            
            let phone = ABMultiValueCopyValueAtIndex(phones,
                counter).takeRetainedValue() as String
            
            if phone.trimmedPhoneNumber.length >= 7{
                returnedPhones.append(phone.trimmedPhoneNumber)
            }
            
        }
        
        return returnedPhones
    }
    
    //can be called from Process Manager
    
    func startSyncProcess(){
        
        let contacts = self.fetchContactsFromAddressBook()
        KNAPIManager.sharedInstance.synAddressBook(contacts) { (responseObj) -> () in
            if responseObj.status == kAPIStatusOk {
                self.getTaskId()
            } else {
                self.delegate?.didFinishSynchronization()
            }
        }
        
     }
    
    //MARK: Monitor sync task status
    func getTaskId() {
        KNAPIManager.sharedInstance.getTaskId({ (responseObj) -> () in
            if responseObj.status == kAPIStatusOk {
                let data = responseObj.dataObject as NSDictionary
                self.taskId = data["id"] as String
                self.checkTaskStatus(self.taskId)
                
            }
        })
    }
    
    func checkTaskStatus(taskId: String) {
        KNAPIManager.sharedInstance.getTaskStatus(taskId, completed: { (responseObj) -> () in
            if responseObj.status == kAPIStatusOk {
                let data = responseObj.dataObject as NSDictionary
                let taskStatus = data["status"] as String
                if taskStatus.lowercase == "done" {
                    KNFriendManager.sharedInstance.fetchFriendsFromServer({ (success, errors) -> () in
                        
                        println("")
                        KNMobileUserManager.sharedInstance.setAddressBookSynchronized(true)
                        self.delegate?.didFinishSynchronization()
                        
                    })

                    
                    
                } else {
                    self.retryCheck()
                }
            } else {
                self.retryCheck()
            }
        })
    }
    
    //MARK: Timer tick
    func retryCheck() {
        self.checkCounter += 1
        if self.checkCounter >= self.maxCheck {
            self.delegate?.didFinishSynchronization()
        } else {
            delay(self.delayPerCheck, { () -> () in
                self.checkTaskStatus(self.taskId)
            })
        }
    }

    
    
    
    
}

