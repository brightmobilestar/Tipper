//
//  KNTipperCardExtension.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 08/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation
 
import CoreData

extension TipperCard{
    /*
    //private function that is used to find an existing object by _id and retrurn it or create it as a new object
    func findTipperCard(id:String) -> TipperCard{
        let fetchRequest = NSFetchRequest(entityName:"TipperCard")
        let predicate:NSPredicate = NSPredicate(format:"id == '\(id)'")!
        fetchRequest.predicate=predicate
        var error: NSError?
        let results:NSArray = managedObjectContext!.executeFetchRequest(fetchRequest, error:&error)!
        if(results.count == 1){
            let foundTipperCard:TipperCard = results.lastObject as TipperCard
            return foundTipperCard
        }
        else{
            let foundTipperCard = NSEntityDescription.insertNewObjectForEntityForName("TipperCard", inManagedObjectContext: managedObjectContext!) as TipperCard
            foundTipperCard.id = id
            return foundTipperCard
        }
        
    }
    
    func saveTipperCard(dataObject:NSDictionary)->TipperCard {
        let tipperCard:TipperCard = findTipperCard( dataObject["id"] as NSString) as TipperCard
        //Set properties
        if(dataObject["id"] != nil) {
            self.id = dataObject["id"] as String
        }
        if(dataObject["cardId"] != nil) {
            tipperCard.cardId = dataObject["cardId"] as String
        }
        if(dataObject["brand"] != nil) {
            tipperCard.brand = dataObject["brand"] as String
        }
        if(dataObject["last4"] != nil) {
            tipperCard.last4 = dataObject["last4"] as String
        }
        if(dataObject["exp_month"] != nil) {
            tipperCard.expiredMonth = dataObject["exp_month"] as String
        }
        if(dataObject["exp_year"] != nil) {
            tipperCard.expiredYear = dataObject["exp_year"] as String
        }
        if(dataObject["default"] != nil) {
            tipperCard.isDefault = dataObject["default"] as NSNumber
        }
        if(dataObject["type"] != nil) {
            tipperCard.type = dataObject["type"] as String
        }
        //save the object
        KNCoreDataManager.sharedInstance.saveContext()
        //and return
        return tipperCard
    }
*/
}