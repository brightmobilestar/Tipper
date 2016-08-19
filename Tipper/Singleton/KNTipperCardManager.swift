//
//  KNTipperCardManager.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 07/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit
import Foundation
class KNTipperCardManager {
    
    class var sharedInstance : KNTipperCardManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNTipperCardManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNTipperCardManager()
        }
        return Static.instance!
    }
    
    init() {
        
    }
   
    //MARK card operations called from VC
    //Add a card, send to API and store in core data
    
    
    func addTipperCard(brand: String, cardNumber: String, expMonth: String, expYear: String, cvc: String,user:KNMobileUser, firstName:String, lastName:String, cardType:String, completed: (((responseObj: KNAPIResponse) -> ())?) = nil){
        if (cardType == "credit"){
            KNAPIManager.sharedInstance.addCreditCard(brand, cardNumber: cardNumber, expMonth: expMonth, expYear: expYear, cvc: cvc, firstName:firstName, lastName:lastName) { (responseObj) -> () in
                if responseObj.status == kAPIStatusOk {
                    KNCoreDataManager.sharedInstance.saveTipperCard(responseObj.dataObject as NSDictionary,user:user)
                }
                if completed != nil {
                    completed!(responseObj: responseObj)
                }
                
            }
        }
        else{
            //debit
            KNAPIManager.sharedInstance.addDebitCard(brand, cardNumber: cardNumber, expMonth: expMonth, expYear: expYear, cvc: cvc, firstName: firstName, lastName: lastName) { (responseObj) -> () in
                if responseObj.status == kAPIStatusOk {
                    KNCoreDataManager.sharedInstance.saveTipperCard(responseObj.dataObject as NSDictionary,user:user)
                }
                if completed != nil {
                    completed!(responseObj: responseObj)
                }
            }
        }
        
        
    }
    
    /*
    func addCreditCard(name: String, cardNumber: String, expMonth: String, expYear: String, cvc: String,user:KNMobileUser, completed: (responseObj: KNAPIResponse) -> ()){
        
            KNAPIManager.sharedInstance.addCreditCard(name, cardNumber: cardNumber, expMonth: expMonth, expYear: expYear, cvc: cvc) { (responseObj) -> () in
                if responseObj.status == kAPIStatusOk {
                    KNCoreDataManager.sharedInstance.saveTipperCard(responseObj.dataObject as NSDictionary,user:user)
                }
                completed(responseObj: responseObj)
                
            }

    }

    func addDebitCard(name: String, cardNumber: String, expMonth: String, expYear: String, cvc: String,user:KNMobileUser, firstName:String,lastName:String, completed: (responseObj: KNAPIResponse) -> ()){
        KNAPIManager.sharedInstance.addDebitCard(name, cardNumber: cardNumber, expMonth: expMonth, expYear: expYear, cvc: cvc, firstName: firstName, lastName: lastName) { (responseObj) -> () in
           if responseObj.status == kAPIStatusOk {
                KNCoreDataManager.sharedInstance.saveTipperCard(responseObj.dataObject as NSDictionary,user:user)
            }
            completed(responseObj: responseObj)
        }
        
        
    }
    */
    //call API and delete from core data
    /*
    func deleteCard(cardObject: Card){
        KNAPIManager.sharedInstance.deleteCard(cardObject.id!) { (responseObj) -> () in
            if responseObj.status == kAPIStatusOk{
                KNCoreDataManager.sharedInstance.managedObjectContext?.deleteObject(cardObject)
            }
            else{
                
            }
        }
    }
    */
    
    func deleteTipperCard(cardObject:TipperCard,completed:(success: Bool, errorMessage:String?) -> ()){
        
        
            KNAPIManager.sharedInstance.deleteTipperCard(cardObject.id) { (success, responseObj) -> () in
                
                if responseObj.status == kAPIStatusOk {
                    // Deleted card from server successfully,
                    KNCoreDataManager.sharedInstance.deleteObject(cardObject)
                    completed(success:true,  errorMessage: nil)
                }
                else{
                    // if error occurred
                    for error in responseObj.errors {
                        
                 
                        // if card not found on server (error code is 2003), we should delete card from core data
                        if error.errorCode == "2003" {
                            KNCoreDataManager.sharedInstance.deleteObject(cardObject)
                            completed(success:false, errorMessage:error.errorMessage)
                            break
                        }
                        else{
                            completed(success:false, errorMessage:error.errorMessage)
                            break
                        }
                    }
                    KNCoreDataManager.sharedInstance.deleteObject(cardObject)
                     completed(success:true,  errorMessage: nil)
                }
            }
        
    }
    
    //MARK fetch cards from Core Data
    
    /*
    Discussion: When called with the type, it defaults to returning creditcards
    other options are debit or credit

    */
    
    func fetchCards(forUser user:KNMobileUser,cardType : String? = "credit") -> Array<TipperCard>?{
        var allCards:Array<TipperCard>? = Array<TipperCard>()
        let context:NSManagedObjectContext = KNCoreDataManager.sharedInstance.managedObjectContext!
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        
        let entity:NSEntityDescription = NSEntityDescription.entityForName("TipperCard", inManagedObjectContext: context)!
        fetchRequest.entity = entity
        var predicate:NSPredicate
        if (cardType == "all"){
            predicate = NSPredicate(format: "userId LIKE %@", user.userId)!
        }
        else {
            predicate = NSPredicate(format: "userId LIKE %@ AND type == %@", user.userId,cardType!)!
        }
     
        fetchRequest.predicate = predicate
        
        var error:NSError? = nil
        var fetchedObjects:Array? = context.executeFetchRequest(fetchRequest, error: &error)!
        if fetchedObjects != nil {
          
            for var i = 0; i < fetchedObjects!.count; i++ {
                var foundTipperCard:TipperCard = fetchedObjects![i] as TipperCard
                allCards?.append(foundTipperCard)
            
            }
        }
        return allCards
    }
    
    //Server communication fetch cards when user login
    func fetchCardsFromServer(forUser user:KNMobileUser, completed: (((responseObj: KNAPIResponse) -> ())?) = nil){
        KNAPIManager.sharedInstance.fetchCards({ (fetchedCards, responseObj) -> () in
            if(responseObj.status == kAPIStatusOk) {
                
                var newCards:Array<TipperCard>? = Array<TipperCard>()
                
                for var i = 0; i < fetchedCards!.count; i++ {
                    var jsonDict = fetchedCards![i] as NSDictionary
                    //upsert in Core Data
                    var newCard : TipperCard = KNCoreDataManager.sharedInstance.saveTipperCard(jsonDict,user:user)
                    newCards?.append(newCard)
                }
                
                if newCards != nil {
                    KNCoreDataManager.sharedInstance.syncTipperCards(newCards!, forUser: user)
                }
            }

            if completed != nil {
                completed!(responseObj: responseObj)
            }
        })
    }
    
    
    
    
   
}


 