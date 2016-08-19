//
//  KNSearchFriendsManager.swift
//  Tipper
//
//  Created by Peter van de Put on 25/01/2015.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation


class KNSearchFriendsManager: NSObject {
    
    
    class var sharedInstance : KNSearchFriendsManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNSearchFriendsManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNSearchFriendsManager()
        }
        return Static.instance!
    }
    
    override init() {
        
    }
    
    //MARK function to be called from mainVC
     var foundFriends:Array<KNFriend>?
   
    func search(searchText:String)->Array<KNFriend>?{
        if (KNMobileUserManager.sharedInstance.hasSavedUser()){
            return fetchLocalFriends(searchText: searchText, forUser: KNMobileUserManager.sharedInstance.currentUser()!)
        }
        else{
            return  Array<KNFriend>()
        }
    }
   
    //MARK local search
    private func fetchLocalFriends(searchText text:String, forUser user:KNMobileUser ) -> Array<KNFriend>?{
        
        var allFriends:Array<KNFriend>? = Array<KNFriend>()
        
        let context:NSManagedObjectContext = KNCoreDataManager.sharedInstance.managedObjectContext!
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        
        let entity:NSEntityDescription = NSEntityDescription.entityForName("KNFriend", inManagedObjectContext: context)!
        fetchRequest.entity = entity
        let keyword = "*" + text + "*"
        
        // Marked by luokey
//        let predicate:NSPredicate = NSPredicate(format: "(publicName LIKE [c] %@ OR email LIKE [c] %@ OR mobile LIKE [c] %@) AND NOT (friendId = %@) AND userId == %@", keyword, keyword, keyword, user.userId, user.userId)!
        
        // Added by luokey
        var phoneNumberKeyword: NSString? = keyword
        var range: NSRange? = NSMakeRange(0, phoneNumberKeyword!.length)
        phoneNumberKeyword = phoneNumberKeyword!.stringByReplacingOccurrencesOfString("(", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: range!)
        range = NSMakeRange(0, phoneNumberKeyword!.length)
        phoneNumberKeyword = phoneNumberKeyword!.stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: range!)
        
        range = NSMakeRange(0, phoneNumberKeyword!.length)
        let noDashPhoneNumberKeyword = phoneNumberKeyword!.stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: range!)
        
        let predicate:NSPredicate = NSPredicate(format: "(publicName LIKE [c] %@ OR email LIKE [c] %@ OR mobile LIKE [c] %@ OR mobile LIKE [c] %@ OR mobile LIKE [c] %@) AND NOT (friendId = %@) AND userId == %@",
            keyword, keyword, keyword, phoneNumberKeyword!, noDashPhoneNumberKeyword, user.userId, user.userId)!
        
        
        fetchRequest.predicate = predicate
       
        //Ordering
        let sortDescriptorFavorite = NSSortDescriptor(key: "isFavorite", ascending: false)
        let sortDescriptorAlphabeticalOrder = NSSortDescriptor(key: "publicName", ascending: true)
        let sortDescriptors = [sortDescriptorFavorite, sortDescriptorAlphabeticalOrder]
        fetchRequest.sortDescriptors = sortDescriptors
        
        
        var error:NSError?
        var fetchedObjects:Array? = context.executeFetchRequest(fetchRequest, error: &error)!
        //println("local friends found count:\(fetchedObjects?.count):")
        if fetchedObjects != nil {
            for var i = 0; i < fetchedObjects!.count; i++ {
                var foundTipperFriend:KNFriend = fetchedObjects![i] as KNFriend
                
                allFriends!.append(foundTipperFriend)
            }
        }
        
        return allFriends
    }
    //MARK server search
    func searchFriendsOnline(keyword:String, forUser user:KNMobileUser, completed : (foundResults:Array<KNFriend>) -> ()){
        
       var foundFriends:Array<KNFriend>?  = fetchLocalFriends(searchText: keyword, forUser: KNMobileUserManager.sharedInstance.currentUser()!)
        
        
        KNAPIManager.sharedInstance.getListOfFiends(keyword) {(responseObj) -> () in
              if(responseObj.status == kAPIStatusOk) {
                
                let apiFriends: NSArray = responseObj.dataObject as NSArray
                let rows: NSArray = responseObj.dataObject as NSArray
                for (var i = 0; i < rows.count; i++) {
                    
                    if let tmpFriend:KNFriend = KNCoreDataManager.sharedInstance.returnFriendIfExist(rows[i] as NSDictionary, user:  KNMobileUserManager.sharedInstance.currentUser()!)?{
                        
                    }
                    else{
                       
                        var foundTipperFriend = KNCoreDataManager.sharedInstance.createFoundFriendWithoutSaving(rows[i] as NSDictionary, user: KNMobileUserManager.sharedInstance.currentUser()!)
                        foundFriends!.append(foundTipperFriend)
                    }
                    
                }
                completed(foundResults:foundFriends!)
                
            }
            else{
                 var foundFriends:Array<KNFriend>? = Array<KNFriend>()
                 completed(foundResults:foundFriends!)
            }
            
        }
        
    }
    
    func getListOfFiendsNearby(completed : (foundResults:Array<KNFriend>) -> ()){
        
        var foundFriends:Array<KNFriend>? = Array<KNFriend>()
        
        KNAPIManager.sharedInstance.getListOfFiendsNearby { (responseObj) -> () in
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
                completed(foundResults:foundFriends!)
            }
            else{
                var foundFriends:Array<KNFriend>? = Array<KNFriend>()
                completed(foundResults:foundFriends!)
            }
        }
    }
    
    
}

