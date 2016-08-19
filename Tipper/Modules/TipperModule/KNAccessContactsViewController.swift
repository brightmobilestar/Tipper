//
//  KNAccessContactsViewController.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/18/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

class KNAccessContactsViewController: KNBaseViewController, KNAddressBookManagerDelegate {
    var taskId: String = ""
    var checkCounter: Int = 0
    let maxCheck: Int = 5
    let delayPerCheck: Double = 1 //second
    
    var activityViewWrapper: KNActivityViewWrapper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        self.activityViewWrapper!.setLabelText(NSLocalizedString("accessingContacts", comment: ""))
        
        self.activityViewWrapper!.addActivityView(animateIn: true, completionHandler: nil)
        
        
        KNAddressBookManager.sharedInstance.delegate = self
        if KNMobileUserManager.sharedInstance.hasSavedUser(){
            //!
            if !KNMobileUserManager.sharedInstance.hasAddressBookSynchronized(){
                 KNAddressBookManager.sharedInstance.requestAccessContact()
            }
            else{
                
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.performSegueWithIdentifier("segueToMain", sender: self)
                })

            }
        }
        else{
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.performSegueWithIdentifier("segueToMain", sender: self)
            })
        }
       
        self.navigationController?.navigationBar.hidden = true
    }
    
    //MARK delegates
    func   didCompleteRequestAccessContact(accessGranted isAuthorized: Bool) {
        self.activityViewWrapper!.addActivityView(animateIn: true, completionHandler: nil)
        if KNMobileUserManager.sharedInstance.hasSavedUser(){
            if !KNMobileUserManager.sharedInstance.hasAddressBookSynchronized(){
                KNAddressBookManager.sharedInstance.startSyncProcess()
            }
            else{
                //didFinishSynchronization()
                //We need to delay this logic
                let delay = 0.4 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue(),{ () -> Void in
                    self.performSegueWithIdentifier("segueToMain", sender: self)
                })
                
               
            }
        }
        else{
            KNAddressBookManager.sharedInstance.startSyncProcess()
        }
        
    }
    func   didFinishSynchronization() {
        self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
            //self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.performSegueWithIdentifier("segueToMain", sender: self)
            })
        })
    }
   
}
