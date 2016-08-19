//
//  KNStandardAlertView.swift
//  Tipper
//
//  Created by Jay N on 12/16/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import Foundation

class KNAlertStandard {
    
    class var sharedInstance : KNAlertStandard {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNAlertStandard? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNAlertStandard()
        }
        return Static.instance!
    }
    
    //[self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    
    func showAlert(controller: UIViewController, title: String, message: String, buttonTitle:String = "ok") {
        
        if iOS8OrHigher
        {
            let alertController = UIAlertController(title: NSLocalizedString(title, comment: ""), message: NSLocalizedString(message, comment: ""), preferredStyle: .Alert)
            
             
            let okAction: UIAlertAction = UIAlertAction(title: NSLocalizedString(buttonTitle, comment: ""), style: .Default) { action -> Void in
                
            }
            
            alertController.addAction(okAction)
            
            controller.presentViewController(alertController, animated: true, completion: nil)
            
        }
        else
        {
            let alert = UIAlertView()
            alert.title = NSLocalizedString(title, comment: "")
            alert.message = NSLocalizedString(message, comment: "")
            alert.addButtonWithTitle(NSLocalizedString(buttonTitle, comment: ""))
            alert.show()
        }
    }
    
}