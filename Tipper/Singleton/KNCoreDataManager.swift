//
//  KNCoreDataManager.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 02/11/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//
import CoreData

//@objc(User)

class KNCoreDataManager {
    
    class var sharedInstance : KNCoreDataManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNCoreDataManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNCoreDataManager()
        }
        return Static.instance!
    }
    
    init() {
         saveContext();
    }
    
    //MARK public methods

    ///MARK Tipper Card
    //private used for upsert
    func findTipperCard(id:String,user:KNMobileUser) -> TipperCard{
        let fetchRequest = NSFetchRequest(entityName:"TipperCard")
        let predicate:NSPredicate = NSPredicate(format:"id == '\(id)'  AND userId == '\(user.userId)'")!
        fetchRequest.predicate=predicate
        var error: NSError?
        let results:NSArray = managedObjectContext!.executeFetchRequest(fetchRequest, error:&error)!
        if(results.count == 1){
            let foundTipperCard:TipperCard = results.lastObject as TipperCard
            return foundTipperCard
        }
        else{
            var foundTipperCard =  KNCoreDataManager.sharedInstance.intitializeAnEntityObjectByEntityName("TipperCard", withIsForSaving: true) as TipperCard
            foundTipperCard.id = id
            foundTipperCard.userId = user.userId
            return foundTipperCard
        }
        
    }
    
    func saveTipperCard(dataObject:NSDictionary, user:KNMobileUser)->TipperCard {
        let tipperCard:TipperCard = findTipperCard( dataObject["id"] as NSString,user:user) as TipperCard
        //Set properties
        if(dataObject["id"] != nil) {
            tipperCard.id = dataObject["id"] as String
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
        if(dataObject["firstName"] != nil) {
            tipperCard.firstName = dataObject["firstName"] as String
        }
        if(dataObject["lastName"] != nil) {
            tipperCard.lastName = dataObject["lastName"] as String
        }
         //save the object
        KNCoreDataManager.sharedInstance.saveContext()
        //and return
        return tipperCard
    }
    
    func syncTipperCards( newCards: Array<TipperCard>, forUser user:KNMobileUser) {
        
        let cardIds = newCards.map({$0.cardId})
        
        let context:NSManagedObjectContext = KNCoreDataManager.sharedInstance.managedObjectContext!
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        
        let entity:NSEntityDescription = NSEntityDescription.entityForName("TipperCard", inManagedObjectContext: context)!
        fetchRequest.entity = entity
        
        let predicate:NSPredicate = NSPredicate(format: "NOT (cardId IN %@) AND userId LIKE %@", cardIds, user.userId)!
        fetchRequest.predicate = predicate
        

        
        // Execute the fetch
        var error:NSError?
        var deletedCards:Array? = context.executeFetchRequest(fetchRequest, error: &error)!
        
        for var i = 0; i < deletedCards?.count; i++ {
            
            let deletedCard:TipperCard = deletedCards?[i] as TipperCard
            context.deleteObject(deletedCard)
        }
        
        error = nil
        if (!context.save(&error)){
            
        }

    }

    
    //MARK Tipper History
    //private used for upsert
    func findTipperHistory(id:String,user:KNMobileUser) -> TipperHistory{
        let fetchRequest = NSFetchRequest(entityName:"TipperHistory")
        let predicate:NSPredicate = NSPredicate(format:"historyId == '\(id)'  AND userId == '\(user.userId)'")!
        fetchRequest.predicate=predicate
        
        let sortDescriptor = NSSortDescriptor(key: "tipDate", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
    
        var error: NSError?
        let results:NSArray = managedObjectContext!.executeFetchRequest(fetchRequest, error:&error)!
        if(results.count == 1){
            let foundTipperHistory:TipperHistory = results.lastObject as TipperHistory
            return foundTipperHistory
        }
        else{
            var foundTipperHistory =  KNCoreDataManager.sharedInstance.intitializeAnEntityObjectByEntityName("TipperHistory", withIsForSaving: true) as TipperHistory
            foundTipperHistory.historyId = id
            foundTipperHistory.userId = user.userId
            return foundTipperHistory
        }
        
    }
    //There are two different API's for sent and received history but there is no indication in the API response so therefore we need to pass it here as a parameter
    func saveTipperHistory(dataObject:NSDictionary, user:KNMobileUser,sent:Bool)   {
       
        let tipperHistory:TipperHistory = findTipperHistory( dataObject["id"] as NSString,user:user) as TipperHistory
        //Set properties
        if(dataObject["friendFullName"] != nil) {
            tipperHistory.friendFullName = dataObject["friendFullName"] as String
        }
        else{
            tipperHistory.friendFullName = ""
        }
     
        if(dataObject.objectForKey("friendName") != nil) {
            tipperHistory.friendFullName = dataObject.objectForKey("friendName") as String
        }
         
        if(dataObject.objectForKey("amount") != nil) {
            tipperHistory.tipAmount = dataObject.objectForKey("amount") as NSNumber
        }
        
        if(dataObject.objectForKey("createdAt") != nil) {
            let dateString = dataObject.objectForKey("createdAt") as String
            
            let rfc3339DateFormatter = NSDateFormatter()
            let en_US_POSIX = NSLocale(localeIdentifier: "en_US_POSIX")
            rfc3339DateFormatter.locale = en_US_POSIX
            rfc3339DateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
            rfc3339DateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
            //to avoid crashes with invalid date string we use an optional to assign
            if let d:NSDate = rfc3339DateFormatter.dateFromString(dateString)?{

                tipperHistory.tipDate =  d 
            }
            else{
            }
            

        }
        tipperHistory.isSent =  NSNumber(bool:sent)
        //save the object
        KNCoreDataManager.sharedInstance.saveContext()
        //and return
        
    }
    
    //MARK Kn Friend
    func findKNFriend(id:String,user:KNMobileUser) -> KNFriend{
        let fetchRequest = NSFetchRequest(entityName:"KNFriend")
        let predicate:NSPredicate = NSPredicate(format:"friendId == '\(id)'  AND userId == '\(user.userId)'")!
        fetchRequest.predicate=predicate
        var error: NSError?
        let results:NSArray = managedObjectContext!.executeFetchRequest(fetchRequest, error:&error)!
        if(results.count == 1){
            let foundTipperFriend:KNFriend = results.lastObject as KNFriend
            return foundTipperFriend
        }
        else{
            var foundTipperFriend =  KNCoreDataManager.sharedInstance.intitializeAnEntityObjectByEntityName("KNFriend", withIsForSaving: true) as KNFriend
            foundTipperFriend.friendId = id
            foundTipperFriend.userId = user.userId
            return foundTipperFriend
        }
        
    }
    
    func findKNFriend(id:String) -> KNFriend?{
        let fetchRequest = NSFetchRequest(entityName:"KNFriend")
        let predicate:NSPredicate = NSPredicate(format:"friendId == '\(id)'")!
        fetchRequest.predicate=predicate
        var error: NSError?
        let results:NSArray = managedObjectContext!.executeFetchRequest(fetchRequest, error:&error)!
        if results.count >= 1 {
            let foundTipperFriend:KNFriend = results.lastObject as KNFriend
            return foundTipperFriend
        }
        else {
            return nil
        }
    }
    
    //Helper for search results
    func returnFriendIfExist(dataObject:NSDictionary,user:KNMobileUser) -> KNFriend?{
        var friendId:String = dataObject["id"] as NSString
        let fetchRequest = NSFetchRequest(entityName:"KNFriend")
        let predicate:NSPredicate = NSPredicate(format:"friendId == '\(friendId)'  AND userId == '\(user.userId)'")!
        fetchRequest.predicate=predicate
        var error: NSError?
        let results:NSArray = managedObjectContext!.executeFetchRequest(fetchRequest, error:&error)!
        if(results.count == 1){
            let foundTipperFriend:KNFriend = results.lastObject as KNFriend
            return foundTipperFriend
        }
        else{
           return nil
        }
    }
    
    func saveFriend(dataObject:NSDictionary, user:KNMobileUser)   {
        
        let friend:KNFriend = findKNFriend( dataObject["id"] as NSString,user:user) as KNFriend
        //Set properties
        if(dataObject["friendId"] != nil) {
            friend.friendId = dataObject["friendId"] as String
        }
        if(dataObject.objectForKey("avatar") != nil) {
            friend.avatar = dataObject.objectForKey("avatar") as String
        }
        if(dataObject.objectForKey("publicName") != nil) {
            friend.publicName = dataObject.objectForKey("publicName") as String
        }
        if(dataObject.objectForKey("email") != nil)
        {
            friend.email = dataObject.objectForKey("email") as? String
        }
        if(dataObject.objectForKey("mobile") != nil)
        {
            friend.mobile = dataObject.objectForKey("mobile") as? String
        }

        if(dataObject.objectForKey("favorite") != nil) {
            friend.isFavorite = dataObject.objectForKey("favorite") as NSNumber
        }
        //save the object
        KNCoreDataManager.sharedInstance.saveContext()
        //and return
        
    }
    
    //MARK special case
    /*
    Discussion:
    When doing search for friends via API to tip someone not in your friend list, we get result from API and we need to create a TipperFriend object but DONT store it
    */
    
    func createFoundFriendWithoutSaving(dataObject:NSDictionary, user:KNMobileUser) -> KNFriend {
        
        //the withISForSaving:false sets the NSManagedObjectContext to nill so it wont save
         var foundFriend =  KNCoreDataManager.sharedInstance.intitializeAnEntityObjectByEntityName("KNFriend", withIsForSaving: false) as KNFriend
        foundFriend.friendId = dataObject["id"] as NSString
        foundFriend.userId = user.userId
        if(dataObject["friendId"] != nil) {
            foundFriend.friendId = dataObject["friendId"] as String
        }
        if(dataObject.objectForKey("avatar") != nil) {
            foundFriend.avatar = dataObject.objectForKey("avatar") as String
        }
        if(dataObject.objectForKey("publicName") != nil) {
            foundFriend.publicName = dataObject.objectForKey("publicName") as String
        }
        if(dataObject.objectForKey("isFavorite") != nil) {
            foundFriend.isFavorite = dataObject.objectForKey("isFavorite") as NSNumber
        }
        return foundFriend
        
    }
    
    /*
    Discussion:
    When a friendId is a result from a search action, the friend might not be stored in Core Data, therefore when you add it to favorites we need to copy this friend into a coredata friend

    */
    
    func copyFriendFromMemoryToCoreData(memoryFriend:KNFriend) -> KNFriend{
        
        var alreadyFriend: KNFriend? = self.findKNFriend(memoryFriend.friendId)
        
        if alreadyFriend != nil{
            alreadyFriend!.isFavorite = true
            alreadyFriend!.avatar = memoryFriend.avatar
            alreadyFriend!.userId = memoryFriend.userId
            KNCoreDataManager.sharedInstance.saveContext()
            return alreadyFriend!
        }
        else {
            var newFriend =  self.intitializeAnEntityObjectByEntityName("KNFriend", withIsForSaving: true) as KNFriend
            newFriend.friendId = memoryFriend.friendId
            newFriend.isFavorite = true
            newFriend.publicName = memoryFriend.publicName
            newFriend.avatar = memoryFriend.avatar
            newFriend.userId = memoryFriend.userId
            KNCoreDataManager.sharedInstance.saveContext()
            return newFriend
        }
    }
    
    
    
    //******************************************************************************************************************************************
    //***    TipperUserBalance
    //******************************************************************************************************************************************
    
    func findTipperUserBalance(userId:String) -> TipperUserBalance{
        let fetchRequest = NSFetchRequest(entityName:"TipperUserBalance")
        let predicate:NSPredicate = NSPredicate(format:" userId == '\(userId)'")!
        fetchRequest.predicate=predicate
        var error: NSError?
        let results:NSArray = managedObjectContext!.executeFetchRequest(fetchRequest, error:&error)!
        if(results.count == 1){
            let foundTipperUserBalance:TipperUserBalance = results.lastObject as TipperUserBalance
            return foundTipperUserBalance
        }
        else{
            var foundTipperUserBalance =  KNCoreDataManager.sharedInstance.intitializeAnEntityObjectByEntityName("TipperUserBalance", withIsForSaving: true) as TipperUserBalance
            foundTipperUserBalance.userId = userId
            foundTipperUserBalance.balance = NSNumber(float: 0)
            return foundTipperUserBalance
        }
        
    }
    
    func saveTipperUserBalance(userId:String,balance:Float?) -> TipperUserBalance  {

        let tipperUserBalance:TipperUserBalance = findTipperUserBalance(userId) as TipperUserBalance
        //Set properties
        
        if(balance != nil) {
           tipperUserBalance.balance = NSNumber(float: balance!)
        }
       
        //save the object
        KNCoreDataManager.sharedInstance.saveContext()
        return tipperUserBalance
        
    }
    
    
    
    
    //******************************************************************************************************************************************
    //***    The following functions are generic for Dolphin based backend systems
    //******************************************************************************************************************************************
    
    //******************************************************************************************************************************************
    //***    KNCMSPage
    //******************************************************************************************************************************************
    func findCMSPage(id:String) -> KNCMSPage{
        let fetchRequest = NSFetchRequest(entityName:"KNCMSPage")
        let predicate:NSPredicate = NSPredicate(format:" pageId == '\(id)'")!
        fetchRequest.predicate=predicate
        var error: NSError?
        let results:NSArray = managedObjectContext!.executeFetchRequest(fetchRequest, error:&error)!
        if(results.count == 1){
            let foundCMSPage:KNCMSPage = results.lastObject as KNCMSPage
            return foundCMSPage
        }
        else{
            var foundCMSPage =  KNCoreDataManager.sharedInstance.intitializeAnEntityObjectByEntityName("KNCMSPage", withIsForSaving: true) as KNCMSPage
            foundCMSPage.pageId = id
            return foundCMSPage
        }
        
    }
    func saveCMSPage(dataObject:NSDictionary) -> KNCMSPage  {
     
        let cmsPage:KNCMSPage = findCMSPage( dataObject["_id"] as NSString) as KNCMSPage
        //Set properties
        
        if(dataObject.objectForKey("content") != nil) {
            cmsPage.content = dataObject.objectForKey("content") as String
        }
        else{
            cmsPage.content = ""
        }
        if(dataObject.objectForKey("slug") != nil) {
            cmsPage.slug = dataObject.objectForKey("slug") as String
        }
        if(dataObject.objectForKey("title") != nil) {
            cmsPage.title = dataObject.objectForKey("title") as String
        }
                //save the object
        KNCoreDataManager.sharedInstance.saveContext()
        return cmsPage
        
    }
    
    
    
    //******************************************************************************************************************************************
    //***    KNMobileUser
    //******************************************************************************************************************************************
    
    //MARK Mobile USer User
    func findMobileUser(id:String) -> KNMobileUser{
        let fetchRequest = NSFetchRequest(entityName:"KNMobileUser")
        let predicate:NSPredicate = NSPredicate(format:" userId == '\(id)'")!
        fetchRequest.predicate=predicate
        var error: NSError?
        let results:NSArray = managedObjectContext!.executeFetchRequest(fetchRequest, error:&error)!
        if(results.count == 1){
            let foundMobileUser:KNMobileUser = results.lastObject as KNMobileUser
            return foundMobileUser
        }
        else{
            var foundMobileUser =  KNCoreDataManager.sharedInstance.intitializeAnEntityObjectByEntityName("KNMobileUser", withIsForSaving: true) as KNMobileUser
            foundMobileUser.userId = id
            foundMobileUser.isVerified = false
            return foundMobileUser
        }
        
    }
    
    func countUsers() -> Int{
    
        let fetchRequest = NSFetchRequest(entityName:"KNMobileUser")
         var error: NSError?
        let results:NSArray = managedObjectContext!.executeFetchRequest(fetchRequest, error:&error)!
        
        if (results.count > 0){
            for var index = 0; index < results.count; ++index{
                let foundUser:KNMobileUser = results[index] as KNMobileUser
                 
            }
        }
        
        
        return results.count
        
    }
    
    func saveMobileUser(dataObject:NSDictionary) -> KNMobileUser  {
        
        let mobileUser:KNMobileUser = findMobileUser( dataObject["id"] as NSString) as KNMobileUser
        //Set properties
        println("jso \(dataObject)")
        if(dataObject.objectForKey("avatar") != nil) {
            mobileUser.avatar = dataObject.objectForKey("avatar") as String
        }
        else{
            mobileUser.avatar = ""
        }
        if(dataObject.objectForKey("publicName") != nil) {
            mobileUser.publicName = dataObject.objectForKey("publicName") as String
        }
        if(dataObject.objectForKey("email") != nil) {
            mobileUser.email = dataObject.objectForKey("email") as String
        }
        if(dataObject.objectForKey("mobile") != nil) {
            mobileUser.phoneNumber = dataObject.objectForKey("mobile") as String
        }
        
        if(dataObject.objectForKey("accessToken") != nil) {
            mobileUser.accessToken = dataObject.objectForKey("accessToken") as String
        }
        if(dataObject.objectForKey("token") != nil) {
            mobileUser.accessToken = dataObject.objectForKey("token") as String
        }
        if(dataObject.objectForKey("hasPinCode") != nil) {
            mobileUser.hasPinCode = dataObject.objectForKey("hasPinCode") as NSNumber
        }
        
        
        // Added by luokey
        if(dataObject.objectForKey("paypalEmail") != nil) {
            mobileUser.paypalEmail = dataObject.objectForKey("paypalEmail") as String
        }
        else {
            mobileUser.paypalEmail = ""
        }
        
        // Added by luokey
        NSUserDefaults().setBool(false, forKey: kShowWithdrawConfirmation)
        
        //save the object
        KNCoreDataManager.sharedInstance.saveContext()
       return mobileUser
        
    }
    
    
    
    
    
    
    
    
    //******************************************************************************************************************************************
    //***    End of generic for Dolphin based backend systems
    //******************************************************************************************************************************************
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
        }()
    /*
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Tipper", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    */
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Tipper.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    

    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Tipper", withExtension: "momd")!
        //return NSManagedObjectModel(contentsOfURL: modelURL)!
        
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        // Check if we are running as test or not
        let environment = NSProcessInfo.processInfo().environment as [String : AnyObject]
        let isTest = (environment["XCInjectBundle"] as? String)?.pathExtension == "xctest"
        
        // Create the module name
        let moduleName = (isTest) ? "Tipper" : "Tipper" //Tipper_Tests
        
        // Create a new managed object model with updated entity class names
        var newEntities = [] as [NSEntityDescription]
        for (_, entity) in enumerate(managedObjectModel.entities) {
            let newEntity = entity.copy() as NSEntityDescription
            newEntity.managedObjectClassName = "\(moduleName).\(entity.name)"
            newEntities.append(newEntity)
        }
        let newManagedObjectModel = NSManagedObjectModel()
        newManagedObjectModel.entities = newEntities
        
        return newManagedObjectModel
        
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    func deleteObject(object: NSManagedObject ){
        self.managedObjectContext?.deleteObject(object)
        self.saveContext()
    }
    
    func deleteObjects(objects: Array<NSManagedObject>){
        for obj in objects {
            self.managedObjectContext?.deleteObject(obj)
        }
    }
    
    
    func intitializeAnEntityObjectByEntityName<T:NSManagedObject>(name:String, withIsForSaving forSaving:Bool) -> T{
    
        var entity:NSEntityDescription = NSEntityDescription.entityForName(name, inManagedObjectContext: self.managedObjectContext!)!
        
        var object:T
        
        if forSaving == true {
        
            object = T(entity: entity, insertIntoManagedObjectContext: self.managedObjectContext)
        }else{
            
            object = T(entity: entity, insertIntoManagedObjectContext:nil)
        }
        
        return object
    }
    
    
/*
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.knodeit.CloudBeacon" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        return urls[urls.count-1] as NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Tipper2", withExtension: "momd")!
        //return NSManagedObjectModel(contentsOfURL: modelURL)!
        
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        // Check if we are running as test or not
        let environment = NSProcessInfo.processInfo().environment as [String : AnyObject]
        let isTest = (environment["XCInjectBundle"] as? String)?.pathExtension == "xctest"
        
        // Create the module name
        let moduleName = (isTest) ? "Tipper" : "Tipper" //Tipper_Tests
        
        // Create a new managed object model with updated entity class names
        var newEntities = [] as [NSEntityDescription]
        for (_, entity) in enumerate(managedObjectModel.entities) {
            let newEntity = entity.copy() as NSEntityDescription
            newEntity.managedObjectClassName = "\(moduleName).\(entity.name)"
            newEntities.append(newEntity)
        }
        let newManagedObjectModel = NSManagedObjectModel()
        newManagedObjectModel.entities = newEntities
        
        return newManagedObjectModel
        
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Tipper2.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                abort()
            }
        }
    }
*/

}

