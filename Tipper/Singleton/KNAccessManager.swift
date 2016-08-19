//
//  KNAccessManager.swift
//  Tipper
//
//  Created by Peter van de Put on 19/01/2015.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation
class KNAccessManager: NSObject {
    
    
    class var sharedInstance : KNAccessManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNAccessManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNAccessManager()
        }
        return Static.instance!
    }
    
   
    func requestAccessForPushNotifications(){
        // MARK : -- Register for remote notifications
        
        if UIApplication.sharedApplication().respondsToSelector("registerUserNotificationSettings:") {
            // It's iOS 8
            var types: UIUserNotificationType = UIUserNotificationType.Badge | UIUserNotificationType.Alert |  UIUserNotificationType.Sound
            var settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes:types, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
            
        }
        else{
            //< iOS 8
            var types = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(types)
            
        }

    }


    func requestAccessForCoreLocationManager(){
        KNLocationManager.sharedInstance.startLocationUpdates()
        
    }
    
}
