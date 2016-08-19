//
//  KNFriendManager.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 02/02/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit
import Foundation
class KNFriendManager {
    
    class var sharedInstance : KNFriendManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNFriendManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNFriendManager()
        }
        return Static.instance!
    }
    
    init() {
        
    }
    //MARK API
    
    //load friends from server that are in your roster
    func fetchFriendsFromServer(completed:(success: Bool, errors: [(KNAPIResponse.APIError)]?) -> ()){
        KNAPIManager.sharedInstance.getListOfFriends() { (responseObj) -> () in
            if(responseObj.status == kAPIStatusOk) {
                let apiFriends: NSArray = responseObj.dataObject as NSArray
                let rows: NSArray = responseObj.dataObject as NSArray
                for (var i = 0; i < rows.count; i++) {
                    KNCoreDataManager.sharedInstance.saveFriend(rows[i] as NSDictionary, user: KNMobileUserManager.sharedInstance.currentUser()!)
                }
                completed(success:true, errors: nil)
            }
            
            else{
                
                completed(success:false,errors: responseObj.errors)
            }
                        
        }
    }
   
    //Mark this is adding a friend to a roster
    
    func addFriendAsFavorite(oldFriend:KNFriend, completed: (success: Bool, tipperFriend: KNFriend) -> ()) {
          KNAPIManager.sharedInstance.addFriend(oldFriend.friendId) { (responseObj) -> () in
            if(responseObj.status == kAPIStatusOk){
                //This friendId may be result of search so it is not yet in Core Data
                var newFriend = KNCoreDataManager.sharedInstance.copyFriendFromMemoryToCoreData(oldFriend)
                completed(success:true,tipperFriend: newFriend)
            }
            else{
                completed(success:false,tipperFriend: oldFriend)
            }
        }
    }

    
    //kAPIFavorite
    
    func markAsFavorite(friend:KNFriend, isFavorite:Bool, completed: (success: Bool) -> ()) {
        
        if (friend.managedObjectContext != KNCoreDataManager.sharedInstance.managedObjectContext){
            //This is a temporary friend so we need to first make it a real friend
            
            addFriendAsFavorite(friend, completed: { (success, tipperFriend) -> () in
                //make it favorite
                KNAPIManager.sharedInstance.markAsFavorite(tipperFriend.friendId, isFavorite: isFavorite.boolValue) { (responseObj) -> () in
                    if responseObj.status == kAPIStatusOk {
                        completed(success:true)
                    }
                    else{
                        completed(success:false)
                    }
                    
                }
            })
            
            
        }
        else{
            KNAPIManager.sharedInstance.markAsFavorite(friend.friendId, isFavorite: isFavorite.boolValue) { (responseObj) -> () in
                if responseObj.status == kAPIStatusOk {
                    completed(success:true)
                }
                else{
                    completed(success:false)
                }
                
            }
        }
        
       
    }
    
    
    
    //used in UI to search for friends in real time. If no internet connection or server responds with array we automatically fall back on core data
    //that means however only friends from your addressbook are found
     func searchFriendsOnline(keyword:String, forUser user:KNMobileUser,Completed : (online: Bool,foundResults:Array<KNFriend>) -> ()){
        
        var foundFriends:Array<KNFriend>? = Array<KNFriend>()
        
        KNAPIManager.sharedInstance.getListOfFiends(keyword) {(responseObj) -> () in
            if(responseObj.status == kAPIStatusOk) {
                
                let apiFriends: NSArray = responseObj.dataObject as NSArray
                let rows: NSArray = responseObj.dataObject as NSArray
                for (var i = 0; i < rows.count; i++) {
                    
                    if let tmpFriend:KNFriend = KNCoreDataManager.sharedInstance.returnFriendIfExist(rows[i] as NSDictionary, user:  KNMobileUserManager.sharedInstance.currentUser()!)?{
                        
                        foundFriends!.append(tmpFriend)
                    }
                    else{
                        
                        var foundTipperFriend = KNCoreDataManager.sharedInstance.createFoundFriendWithoutSaving(rows[i] as NSDictionary, user: KNMobileUserManager.sharedInstance.currentUser()!)
                        foundFriends!.append(foundTipperFriend)
                    }
                    
                }
                Completed(online: true,foundResults:foundFriends!)
               
            }
            else {
                //Nothing or error from server so lets return it from Core data as a fallback
                foundFriends =  self.fetchFriends(searchText: keyword, forUser: user)
                Completed(online: false,foundResults:foundFriends!)
            }
        }
        
    }
    
    
    
    func friendsNearby(completed : (online: Bool,foundResults:Array<KNFriend>) -> ()){
    
        var foundFriends:Array<KNFriend>? = Array<KNFriend>()
    
        KNAPIManager.sharedInstance.getListOfFiendsNearby { (responseObj) -> () in
            if(responseObj.status == kAPIStatusOk) {
                
                let apiFriends: NSArray = responseObj.dataObject as NSArray
                let rows: NSArray = responseObj.dataObject as NSArray
                for (var i = 0; i < rows.count; i++) {
                    
                    //create a TipperFriend object BUT dont store it in Core data
                    var foundTipperFriend = KNCoreDataManager.sharedInstance.createFoundFriendWithoutSaving(rows[i] as NSDictionary, user: KNMobileUserManager.sharedInstance.currentUser()!)
                    foundFriends!.append(foundTipperFriend)
                    
                }
                completed(online: true,foundResults:foundFriends!)
                
            }
            else {
                //Nothing or error from server so lets return nil
               
                completed(online: false,foundResults:Array<KNFriend>())
            }
        }
    }
    
    func discoverFriendProfile( friendId:String, completed : (success: Bool,foundFriend:KNFriend?) -> ()){
        
        KNAPIManager.sharedInstance.discoverFriendProfile(friendId, completed: { (responseObj) -> () in
            if(responseObj.status == kAPIStatusOk) {
                
                let json: NSDictionary = responseObj.dataObject as NSDictionary
                println("json \(json)")
                if let tmpFriend:KNFriend = KNCoreDataManager.sharedInstance.returnFriendIfExist(json, user:  KNMobileUserManager.sharedInstance.currentUser()!)?{
                    completed(success: true, foundFriend: tmpFriend)
                    
                }
                else{
                    
                    var foundFriend = KNCoreDataManager.sharedInstance.createFoundFriendWithoutSaving(json, user: KNMobileUserManager.sharedInstance.currentUser()!)
                    completed(success: true, foundFriend: foundFriend)
                }
                
                
            }
            else {
                completed(success: false, foundFriend: nil)
            }
        })
    }
    
    
    
    
    //MARK CoreData
    func fetchFriends(searchText text:String, forUser user:KNMobileUser ) -> Array<KNFriend>?{
        
        var allFriends:Array<KNFriend>? = Array<KNFriend>()
        
        let context:NSManagedObjectContext = KNCoreDataManager.sharedInstance.managedObjectContext!
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        
        let entity:NSEntityDescription = NSEntityDescription.entityForName("KNFriend", inManagedObjectContext: context)!
        fetchRequest.entity = entity
        let keyword = "*" + text + "*"
        let predicate:NSPredicate = NSPredicate(format: "(publicName LIKE [c] %@  OR email LIKE [c] %@  OR mobile LIKE [c] %@     ) AND NOT (friendId = %@)  AND userId == %@", keyword, keyword,keyword , user.userId,user.userId)!
        fetchRequest.predicate = predicate
        //Ordering
        
        let sortDescriptor = NSSortDescriptor(key: "isFavorite", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
       
        
        
        var error:NSError?
        var fetchedObjects:Array? = context.executeFetchRequest(fetchRequest, error: &error)!
        println("fetchObjects count:\(fetchedObjects?.count):")
        if fetchedObjects != nil {
            
            for var i = 0; i < fetchedObjects!.count; i++ {
                var foundTipperFriend:KNFriend = fetchedObjects![i] as KNFriend
                
                allFriends!.append(foundTipperFriend)
            }
        }
        
        return allFriends
    }
    
    //MARK Helpers
    func getAvatarFilePath(tipperFriend:KNFriend) -> String {
        
        if !tipperFriend.avatar.isEmpty && tipperFriend.avatar != "" {
            return NSTemporaryDirectory().stringByAppendingPathComponent(tipperFriend.avatar)
        }
        
        return ""
    }
    
   

    
    func countFriends(forUser user:KNMobileUser) -> Int{
        let context:NSManagedObjectContext = KNCoreDataManager.sharedInstance.managedObjectContext!
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        
        let entity:NSEntityDescription = NSEntityDescription.entityForName("KNFriend", inManagedObjectContext: context)!
        fetchRequest.entity = entity
        let predicate:NSPredicate = NSPredicate(format: "userId == %@", user.userId)!
        fetchRequest.predicate = predicate
        
        var error:NSError?
        var fetchedObjects:Array? = context.executeFetchRequest(fetchRequest, error: &error)!
        
        if fetchedObjects != nil {
            return fetchedObjects!.count as Int
        }
        else{
            return 0
        }
    }
    
}

