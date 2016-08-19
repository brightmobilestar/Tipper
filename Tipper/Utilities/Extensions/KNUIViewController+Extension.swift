//
//  KNUIViewControllerExtension.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/24/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import Foundation

extension UIViewController {
    
    class func  topViewController() -> UIViewController
        {
        
        return self.topViewController(UIApplication.sharedApplication().keyWindow!.rootViewController!)
    }
    
    class func topViewController(rootViewController :UIViewController) ->  UIViewController
        {
    
            if  rootViewController.presentedViewController == nil {
                return rootViewController
            }
            
            if rootViewController.presentedViewController!.isMemberOfClass(UINavigationController){
            
                var navigationController:UINavigationController = rootViewController.presentedViewController as UINavigationController
                
                var lastViewController:UIViewController = navigationController.viewControllers.last as UIViewController
                
                return self.topViewController(lastViewController)
            }
            
            
            var presentedViewController:UIViewController = rootViewController.presentedViewController as UIViewController!
            
            return self.topViewController(presentedViewController)
    }
    
}