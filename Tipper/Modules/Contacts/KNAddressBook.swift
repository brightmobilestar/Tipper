//
//  KNAddressBook.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/27/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit
import AddressBook

protocol KNAddressBookDelegate {

    func didCompleterequestAccessContact(accessGranted isAuthorized:Bool)
}

class KNAddressBook: NSObject {
    
    class var sharedInstance : KNAddressBook {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNAddressBook? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNAddressBook()
        }
        return Static.instance!
    }
    
    var delegate:KNAddressBookDelegate?
    
    lazy var addressBook: ABAddressBookRef = {
        var error: Unmanaged<CFError>?
        return ABAddressBookCreateWithOptions(nil,
            &error).takeRetainedValue() as ABAddressBookRef
        }()
    
    func accessGranted() -> Bool {
    
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        
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
            self.delegate?.didCompleterequestAccessContact(accessGranted: accessGranted)
            //readFromAddressBook(addressBook)
            
        case .Denied:
            strongSelf.delegate?.didCompleterequestAccessContact(accessGranted: accessGranted)
            
        case .NotDetermined:
            ABAddressBookRequestAccessWithCompletion(addressBook,
                {[weak self] (granted: Bool, error: CFError!) in
                    
                    if granted{
                        
                        strongSelf.delegate?.didCompleterequestAccessContact(accessGranted: accessGranted)
                    } else {
                        
                        strongSelf.delegate?.didCompleterequestAccessContact(accessGranted: accessGranted)
                    }
                    
            })
        default:
            
            self.delegate?.didCompleterequestAccessContact(accessGranted: accessGranted)
        }
    }
    
    func getContacts() -> Array<KNAddressRecord>{
    
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
            
            contacts.append(contact)
        }
        
        return contacts
    }
    
    func readEmailsForPerson(person: ABRecordRef) -> Array<String>{
        
        var returnedEmails:Array<String> = Array<String>()
        
        let emails: ABMultiValueRef = ABRecordCopyValue(person,
            kABPersonEmailProperty).takeRetainedValue()
        
        for counter in 0..<ABMultiValueGetCount(emails){
            
            let email = ABMultiValueCopyValueAtIndex(emails,
                counter).takeRetainedValue() as String
            
            returnedEmails.append(email)
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
            
            returnedPhones.append(phone.trimmedPhoneNumber)
        }
        
        return returnedPhones
    }
}
