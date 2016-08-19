//
//  KNDeleteCCViewController.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/18/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

protocol KNDeleteCCViewDelegate {
    func cardIsDeleted()
}


class KNDeleteCCViewController: KNBaseViewController, UIAlertViewDelegate {
    
    // MARK: Public variable
    var delegate:KNDeleteCCViewDelegate?
    //var card:Card?
    var card:TipperCard?
    var activityViewWrapper: KNActivityViewWrapper?
    
    
    // MARK: IBOutlets
    
    
    @IBOutlet weak var cardNameLabel: UILabel!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cardNameLabel.text = "\(self.card!.brand) \(self.card!.last4)"
        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        self.activityViewWrapper!.setLabelText(NSLocalizedString("deleting", comment: ""))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Event Handling
    @IBAction func deleteCardButtonDidTouch(sender: UIButton) {
        if iOS8OrHigher {
            
            let alertController = UIAlertController(title: NSLocalizedString("notice", comment: ""), message: NSLocalizedString("deleteCardConfirm", comment: ""), preferredStyle: .Alert)
            
            let deleteAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default) { (alertAction) -> Void in
                self.deleteCard()
            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            
            let alert = UIAlertView()
            alert.delegate = self
            alert.title = NSLocalizedString("notice", comment: "")
            alert.message = NSLocalizedString("deleteCardConfirm", comment: "")
            alert.addButtonWithTitle(NSLocalizedString("cancel", comment: ""))
            alert.addButtonWithTitle(NSLocalizedString("ok", comment: ""))
            alert.show()
        }
    }
    
    @IBAction func cancelButtonDidTouch(sender: UIButton) {
        // Remove this view
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    func deleteCard() {
        self.activityViewWrapper!.addActivityView(animateIn: true, completionHandler: nil)
        
        
        KNTipperCardManager.sharedInstance.deleteTipperCard(card!) { (success, errorMessage) -> () in
            if (success){
                
                //invoke delegate
                self.delegate?.cardIsDeleted()
                self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
                    self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                    self.dismissViewControllerAnimated(true, completion: {})
                    
                })
                
                
            }
            else{
                self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
                
                    self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                    KNAlertStandard.sharedInstance.showAlert(self, title: NSLocalizedString("error", comment: ""),
                        message: errorMessage!)
                     self.dismissViewControllerAnimated(true, completion: {})
                })
                
            }
           
        }
        
        
        
        
        
        
        /*
        KNAPIClientManager.sharedInstance.deleteCard(self.card!.id!, completed: { (responseObj) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if responseObj.status == kAPIStatusOk {
                    
                    self.delegate?.cardIsDeleted()
                    
                    // delete local data
                    Card.deleteCard(self.card!)
                    
                    self.dismissViewControllerAnimated(true, completion: {})
                } else {
                    if (responseObj.errors.count > 0) {
                        KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                            message: responseObj.errors[0].errorMessage)
                    } else {
                        KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                            message: "unknownError")
                    }
                }
            })
        })
*/
    }
    
    //MARK: UIAlertView Delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            self.deleteCard()
        }
    }

}
