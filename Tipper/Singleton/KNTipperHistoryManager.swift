//
//  KNTipperHistoryManager.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 08/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit
import Foundation
class KNTipperHistoryManager {
    
    class var sharedInstance : KNTipperHistoryManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNTipperHistoryManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNTipperHistoryManager()
        }
        return Static.instance!
    }
    
    init() {
        
    }
   
    //MARK API integration
    
    func fetchReceivedHistoryFromServer(forUser user:KNMobileUser, completed: (((responseObj: KNAPIResponse) -> ())?) = nil ){
        KNAPIManager.sharedInstance.getReceivedTipHistoryList { (responseObj) -> () in
            if responseObj.status == kAPIStatusOk {
                
                let rows: NSArray = responseObj.dataObject as NSArray
                for (var i = 0; i < rows.count; i++) {
                    KNCoreDataManager.sharedInstance.saveTipperHistory(rows[i] as NSDictionary, user: user,sent:false)
                }
            }
            if completed != nil {
                completed!(responseObj: responseObj)
            }
        }
    }
    
    func fetchSentHistoryFromServer(forUser user:KNMobileUser, completed: (((responseObj: KNAPIResponse) -> ())?) = nil ){
        KNAPIManager.sharedInstance.getTipHistoryList { (responseObj) -> () in
            if responseObj.status == kAPIStatusOk {
                
                let rows: NSArray = responseObj.dataObject as NSArray
                for (var i = 0; i < rows.count; i++) {
                    KNCoreDataManager.sharedInstance.saveTipperHistory(rows[i] as NSDictionary, user: user,sent:true)
                }
            }
            if completed != nil {
                completed!(responseObj: responseObj)
            }
        }
    }
    
    func fetchBalanceAndHistoryFromServer(user: KNMobileUser!, completed:(((success : Bool, errors: [(KNAPIResponse.APIError)]?) -> ())?) = nil ){
        
        // Fetch sent history
        KNTipperHistoryManager.sharedInstance.fetchSentHistoryFromServer(forUser: user) { (responseObj) -> Void in
            
            if responseObj.status == kAPIStatusOk {
                // Fetch received history
                KNTipperHistoryManager.sharedInstance.fetchReceivedHistoryFromServer(forUser: user ) { (responseObj) -> Void in
                    if responseObj.status == kAPIStatusOk {
                        // Fetch total balance
                        KNTipperWithdrawManager.sharedInstance.fetchBalance({ (success, balance, responseObj) -> () in
                            if completed != nil {
                                completed!(success:success, errors:responseObj.errors)
                            }
                        })
                    }
                    else {
                        if completed != nil {
                            completed!(success:false, errors:responseObj.errors)
                        }
                    }
                }
            }
            else{
                if completed != nil {
                    completed!(success:false, errors:responseObj.errors)
                }
            }
        }
    }
    
    //MARK Core Data
    func fetchTipperHistory(forUser user:KNMobileUser,sent:Bool) -> Array<TipperHistory>?{
        var allHistory:Array<TipperHistory>? = Array<TipperHistory>()
        let context:NSManagedObjectContext = KNCoreDataManager.sharedInstance.managedObjectContext!
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        
        let entity:NSEntityDescription = NSEntityDescription.entityForName("TipperHistory", inManagedObjectContext: context)!
        fetchRequest.entity = entity
        
        let predicate =  NSPredicate(format: "userId LIKE %@ AND isSent == %@", user.userId,sent)!
        
        fetchRequest.predicate = predicate
        
        
        //Add ordering
        let sortDescriptor = NSSortDescriptor(key: "tipDate", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        
        var error:NSError? = nil
        var fetchedObjects:Array? = context.executeFetchRequest(fetchRequest, error: &error)!
        if fetchedObjects != nil {
            
            for var i = 0; i < fetchedObjects!.count; i++ {
                var foundTipperHistory:TipperHistory = fetchedObjects![i] as TipperHistory
                allHistory?.append(foundTipperHistory)
                
            }
        }
        return allHistory
    }

   
}

