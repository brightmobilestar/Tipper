//
//  AppDelegate.swift
//  Tipper
//
//  Created by Peter van de Put on 24/10/2014.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit
import CoreData
import Crashlytics

@UIApplicationMain
class KNAppDelegate: UIResponder, UIApplicationDelegate, KNLoginManagerDelegate {

    var window: UIWindow?
    var unwindSegueForTipperModule:String?

    

    
    
    var deviceToken:NSData?
    var hasGotDeviceToken:Bool?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

      
        
        
        // Flurry
//        Flurry.setCrashReportingEnabled(true)
        
        // Start Flurry
        Flurry.startSession(kFlurryApiKey)
        
        // Optional: automatically send uncaught exceptions to Google Analytics.
        GAI.sharedInstance().trackUncaughtExceptions = false
        
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        GAI.sharedInstance().dispatchInterval = 20
        
        // Optional: set Logger to VERBOSE for debug information.
        GAI.sharedInstance().logger.logLevel = GAILogLevel.Verbose
        
        // Initialize tracker. Replace with your tracking ID.
        var tracker:GAITracker = GAI.sharedInstance().trackerWithTrackingId(kGoogleAnalyticsKey)
        
        // Enable IDFA collection.
        tracker.allowIDFACollection = true
        
        // Crashlytics
        
//        Crashlytics.startWithAPIKey("f2b99f15d866e95b1ba01dd7c4cb0a6857b5bd08")
        

        
        
        if(NSUserDefaults().objectForKey(kStopAsking) == nil){
            NSUserDefaults().setBool(false, forKey: kStopAsking)
            NSUserDefaults().setInteger(0, forKey: kInitialUsageCount)
            NSUserDefaults().setObject(NSDate.getCurrentDate(), forKey: kSubsequentUsageCount)
        }
        
        
        
        KNBLETransmitter.sharedInstance
     
        
        
        KNCMSPageManager.sharedInstance.fetchAllPages { (success) -> () in
            
        }
             //Subscribe to our delegates
        KNLoginManager.sharedInstance.delegate = self
        
        return true
    }

    func  application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool
    {
        
        var urlString:String = url.absoluteString!
        var prefixStr:String = "tipper://com.knodeit.tipper/api/password/email/reset/"
        
        if urlString.lowercaseString.rangeOfString(prefixStr) != nil
        {
            var token = urlString.lastPathComponent
            let newPasswordStoryboard = UIStoryboard(name: "NewPasswordStoryboard", bundle: nil)
            let newPasswordViewController = newPasswordStoryboard.instantiateViewControllerWithIdentifier("KNNewPasswordViewController") as KNNewPasswordViewController
            
            let topViewController = self.topViewController()
            if !topViewController.isMemberOfClass(KNNewPasswordViewController.classForCoder())
            {
                newPasswordViewController.resetPasswordToken = token
                self.topViewController().presentViewController(newPasswordViewController, animated: false, completion: nil)
            }
            else
            {
                (topViewController as KNNewPasswordViewController).resetPasswordToken = token
            }
        }
        else
        {
            println("send some error saying invalid url")
        }
        
        return true

    }
    
    func topViewController() -> UIViewController
    {
        return self.topViewController(UIApplication.sharedApplication().keyWindow!.rootViewController!)
    }
    
    func topViewController(rootViewController: UIViewController) -> UIViewController
    {
        if rootViewController.presentedViewController == nil
        {
            return rootViewController
        }
        if rootViewController.presentedViewController!.isKindOfClass(UINavigationController.classForCoder())
        {
            var navigationController = rootViewController.presentedViewController! as UINavigationController
            var lastViewController: UIViewController = navigationController.viewControllers.last as UIViewController
            return self.topViewController(lastViewController)
        }
        var presentedViewController = rootViewController.presentedViewController! as UIViewController
        return self.topViewController(presentedViewController)
    }
    
    func topViewControllerOrNavigationController() -> UIViewController
    {
        return self.topViewControllerOrNavigationController(UIApplication.sharedApplication().keyWindow!.rootViewController!)
    }
    
    func topViewControllerOrNavigationController(rootViewController: UIViewController) -> UIViewController
    {
        if rootViewController.presentedViewController == nil
        {
            return rootViewController
        }
        var presentedViewController = rootViewController.presentedViewController! as UIViewController
        return self.topViewController(presentedViewController)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     
        
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
      
        self.topViewControllerOrNavigationController().updateViewConstraints()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        
        //TODO remove old legacycy
        /*
        if let loggedUser = self.loggedUser {
        
            KNAPIClientManager.sharedInstance.deleteRegistration(loggedUser.userId?, completed: { (success, errors) -> () in
                
            })
        }
        */
        KNProcessManager.sharedInstance.runProcessesWhenApplicationCloses()
    }
    
   
    
 
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        self.deviceToken = deviceToken
        hasGotDeviceToken = true
        if (KNMobileUserManager.sharedInstance.hasSavedUser()){
            KNMobileUserManager.sharedInstance.sendDeviceToken(deviceToken: deviceToken, completed: { (responseObj) -> () in
                //tell server we accept
                KNMobileUserManager.sharedInstance.updateNotificationSettings(true, completed: { (success, responseObj) -> () in
                    
                })
            })
        }
    }
    
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
        self.deviceToken = nil
        //tell server we dont accept
        KNMobileUserManager.sharedInstance.updateNotificationSettings(false, completed: { (success, responseObj) -> () in
            
        })
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        let state = application.applicationState
        if state == UIApplicationState.Active {
        
        }
        
        var user : KNMobileUser? = KNMobileUserManager.sharedInstance.currentUser()?
        if user != nil  {
            KNTipperHistoryManager.sharedInstance.fetchBalanceAndHistoryFromServer(user)
        }
    }
    
    //MARK: --
    
    func askForRating() -> Bool {
        let days = NSDate.getBetweenDays(NSUserDefaults().objectForKey(kSubsequentUsageCount) as NSDate, endDate: NSDate.getCurrentDate()!)
        var subsequence: Bool = days >= kSubsequentIntervalToAsk
        var initialUsage: Bool = (NSUserDefaults().objectForKey(kInitialUsageCount) as Int) >= kInitialIntervalToAsk
        var stopAsk: Bool = NSUserDefaults().objectForKey(kStopAsking) as Bool ? false : true
        
        return stopAsk && (subsequence || initialUsage)
    }
    
    func setInitialUsageCount() {
        var count: Int = NSUserDefaults().objectForKey(kInitialUsageCount) as Int
        count += 1
        NSUserDefaults().setInteger(count, forKey: kInitialUsageCount)
    }

    func loadApplicationStoryboard(){
        var mainView: UIStoryboard!
        mainView = UIStoryboard(name: kApplicationStoryboardName, bundle: nil)
        let viewcontroller : UIViewController = mainView.instantiateViewControllerWithIdentifier(kApplicationMasterPage) as UIViewController
        self.window!.rootViewController = viewcontroller
    }
  
    func gotoMainModule(){
        let vc:UIViewController = KNStoryboardManager.sharedInstance.getViewControllerInitial(kTipperStoryboardName)
        self.window!.rootViewController = vc
    }
    
    
    
    //MARK login delegates
    func didFinishLoginWithSuccess(){
        // update device token on server
        if (self.deviceToken != nil && self.hasGotDeviceToken == true) {
            
            if (KNMobileUserManager.sharedInstance.hasSavedUser()){
                KNMobileUserManager.sharedInstance.sendDeviceToken(deviceToken: self.deviceToken!, completed: { (responseObj) -> () in
                    
                })
            }
            
            
        }
        KNProcessManager.sharedInstance.runProcessesAfterLoginSucceeded()
    }
    
    func didFinishLoginWithError(){
        
    }
    func didFinishLogOutWithSuccess(){
         KNProcessManager.sharedInstance.runProcessesAfterLogoutSucceeded()
    }
    func didFinishLogOutWithError(){
        
        
    }
    func didLogin(){
        
        

    }
    
    
}

