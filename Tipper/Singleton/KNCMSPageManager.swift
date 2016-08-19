//
//  KNCMSPageManager.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 14/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation


class KNCMSPageManager: NSObject {
    
    
    class var sharedInstance : KNCMSPageManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNCMSPageManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNCMSPageManager()
        }
        return Static.instance!
    }
    
    override init() {
        
    }
    
   
    
    func fetchAllPages(completed: (success: Bool) -> ()) {
        KNAPIManager.sharedInstance.fetchAllCMSPages { (success, responseObj) -> () in
            if (success){
                if responseObj.status == kAPIStatusOk {
                    //Save  object
                    
                    let rows: NSArray = responseObj.dataObject as NSArray
                    for (var i = 0; i < rows.count; i++) {
                        KNCoreDataManager.sharedInstance.saveCMSPage(rows[i] as NSDictionary)
                    }
                }
            }
            else{
                println("error")
            }
             completed(success: success)
        }
        
    }
    
    func fetchCMSPageBySlug(slug:String, completed: (success: Bool) -> ()) {
        
        KNAPIManager.sharedInstance.fetchCMSPageBySlug(slug) { (success, responseObj) -> () in
            if (success){
                if responseObj.status == kAPIStatusOk {
                    //Save  object
                     KNCoreDataManager.sharedInstance.saveCMSPage(responseObj.dataObject as NSDictionary)
            }

            completed(success: success)
            }
        }
    }
    
    
    func fetchCMSPage(slug:String) -> KNCMSPage?{
        let context:NSManagedObjectContext = KNCoreDataManager.sharedInstance.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"KNCMSPage")
        let predicate:NSPredicate = NSPredicate(format:" slug == '\(slug)'")!
        
        fetchRequest.predicate=predicate
        var error: NSError?
        let results:NSArray = context.executeFetchRequest(fetchRequest, error:&error)!
        if(results.count == 1){
            let foundCMSPage:KNCMSPage = results.lastObject as KNCMSPage
            return foundCMSPage
        }
        else{
            return nil
        }
        
    }



}
