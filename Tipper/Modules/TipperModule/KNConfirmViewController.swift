//
//  KNConfirmViewController.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/18/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

class KNConfirmViewController: KNBaseViewController, KNPasscodeViewControllerDeleagate, UITextFieldDelegate {
   
    @IBOutlet weak var tfProfile: KNTextField?
    @IBOutlet weak var tfMoneyTip: KNTextField?
    @IBOutlet weak var tfCreditCard: KNTextField?
    @IBOutlet weak var btnConfirm: UIButton?
    @IBOutlet weak var lcMarginTop: NSLayoutConstraint?
    var errors: [KNAPIResponse.APIError]?
    
    var friend:KNFriend?
    var amount: String = ""
    var card:TipperCard?
    
    var unknownPersonToTip:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register notification to close module
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("closeView"), name: kColoseCurrentModuleNotification, object: nil)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        //self.viewWillAppear(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
            
            
            //MARK TODO in case friend is nil and unknownPersonToTip is set you dont have a profile of course
            
            var friendAvatarImage:UIImage? = UIImage(named: kUserPlaceHolderImageName)
            self.tfProfile!.addImageFor(leftImage: friendAvatarImage, rightImage: nil)
            
            if (self.friend != nil){
                if self.friend!.avatar.length > 0 {
                    var url : NSURL = NSURL(string: self.friend!.avatar)!
                    KNImageLoader.sharedInstance.loadImageFromURL(url,
                        placeholder: friendAvatarImage,
                        failure: nil,
                        success: { (downloadedImage:UIImage) -> () in
                            self.tfProfile!.addImageFor(leftImage: downloadedImage, rightImage: nil)
                        }
                    )
                }
                
                self.tfProfile!.text = " \(self.friend!.publicName.formatPublicName())"
              
            }
          
            else{
                //no friend but email or mobile
                self.tfProfile!.text = " \(self.unknownPersonToTip!)"
            }
            
            self.tfProfile!.resignFirstResponder()
            self.tfProfile!.endEditing(true)
            self.tfProfile!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("goProfile")))
            
            self.tfMoneyTip!.addImageForLeft("CurrencyIcon", leftGapOfImage: 15, widthOfImage: 30, rightGapOfImage: 5)
            self.tfMoneyTip!.addImageForRight("TextFieldPlaceHolderIcon", leftGapOfImage: 0, widthOfImage: 50, rightGapOfImage: 0)

            //self.tfMoneyTip!.addImageForLeftOrRightViewWithImage(leftImage: "CurrencyIcon", rightImage: "TextFieldPlaceHolderIcon")
            self.tfMoneyTip!.resignFirstResponder()
            self.tfMoneyTip!.endEditing(true)
            //self.tfMoneyTip!.text = self.amount.groupThousandNumber
            self.tfMoneyTip!.text = self.amount
            
            self.tfMoneyTip!.font = UIFont(name: "HelveticaNeue-Medium", size: 30)
            self.tfMoneyTip!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("goAmount")))
            
            self.tfMoneyTip!.attributedText = KNHelperManager.sharedInstance.attributedAmountString(self.amount)
            
            self.tfCreditCard!.addImageForLeftOrRightViewWithImage(leftImage: "CreditCardIcon", rightImage: "")
            self.tfCreditCard!.text = " \(self.card!.brand) \(self.card!.last4)"
            self.tfCreditCard!.resignFirstResponder()
            self.tfCreditCard!.endEditing(true)
            self.tfCreditCard!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("goBack")))
            
            //self.lcMarginTop!.constant = ScreenHeight*0.17
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return false
    }

    @IBAction func clickConfirmButton(sender: AnyObject) {
        let viewController: UIViewController = KNStoryboardManager.sharedInstance.getViewControllerInitial(kPasscodeStoryboardName) as UIViewController
        (viewController as KNPasscodeViewController).registerPasscode = false
        (viewController as KNPasscodeViewController).knPasscodeDelegate = self
        (viewController as KNPasscodeViewController).friend = self.friend
        (viewController as KNPasscodeViewController).amount = self.amount
        (viewController as KNPasscodeViewController).card = self.card
        (viewController as KNPasscodeViewController).unknownPersonToTip = self.unknownPersonToTip
        //KNHelperManager.sharedInstance.setAnimationPushViewController(self, push: true)
        //self.presentViewController(viewController, animated: false, completion: nil)
        self.navigationController?.pushViewController(viewController, animated: false)
        KNNavigationAnimation.performFadeAnimation(self)
    }
    
    func didPasscodeSuccess(passcode: String){
        let viewController: UIViewController = KNStoryboardManager.sharedInstance.getViewControllerInitial(kMessageStoryboardName) as UIViewController
        var messageViewController: KNMessageViewController = viewController as KNMessageViewController
        messageViewController.imageName = "OvalIcon"
        messageViewController.actionDescription = "Sending"
       
        var convertedAmount:String = self.amount.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        var numberFormatter:NSNumberFormatter = NSNumberFormatter()
        if let rawNumber:NSNumber = numberFormatter.numberFromString(self.amount){
            var amountInCents:NSNumber = NSNumber(float:(rawNumber.floatValue * 100))
            convertedAmount = numberFormatter.stringFromNumber(amountInCents)!
            
            // ----- Added by Luokey ----- //
            var dollarAmount = amountInCents.intValue / 100
            var centAmount = amountInCents.intValue % 100
            
            if (dollarAmount == 0) {
                convertedAmount = ""
            }
            else if (dollarAmount == 1) {
                convertedAmount = NSLocalizedString("aDollar", comment: "")
            }
            else {
                convertedAmount = NSString(format: "%d %@", dollarAmount, NSLocalizedString("dollars", comment: ""))
            }
            
            if (centAmount > 0) {
                if (convertedAmount.length > 0) {
                    convertedAmount = convertedAmount.stringByAppendingString(" ")
                }
                
                if (centAmount == 1) {
                    convertedAmount = convertedAmount.stringByAppendingFormat("%d %@", centAmount, NSLocalizedString("cent", comment: ""))
                }
                else {
                    convertedAmount = convertedAmount.stringByAppendingFormat("%d %@", centAmount, NSLocalizedString("cents", comment: ""))
                }
            }
            // ----- Added by Luokey ----- //
        }
        
        self.presentViewController(viewController, animated: false, completion: nil)

        //MARK TODO in case friend is nil and unknownPersonToTip is set you dont have a profile of course
        
        if (friend != nil){
            
            KNTipperTipManager.sharedInstance.tipAFriend(self.friend!.friendId, amountInCents: convertedAmount,cardId:self.card!.id, pinCode: passcode) { (success, errors) -> () in
                if (success) {
                   
                    /*
                    messageViewController.imageName = "OvalCheck"
                    messageViewController.actionDescription = "Sent"
                    
                    messageViewController.knDelegate!.didFinishLoadingView!(false, storyboardName: nil, viewControllerName: nil)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        var unwindToMain: Selector = "unwindToMain"
                        NSTimer.scheduledTimerWithTimeInterval(1.4, target: self, selector: unwindToMain, userInfo: nil, repeats: false)
                        appDelegate.setInitialUsageCount()
                    })
                    */
                    
                }
                else{
                 
                    /*
                    messageViewController.imageName = "BigWarning"
                    messageViewController.actionDescription = "Failed"
                    messageViewController.knDelegate?.didFinishLoadingView!(false, storyboardName: nil, viewControllerName: nil)
                    self.errors = errors
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let showError: Selector = "showError"
                        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: showError, userInfo: nil, repeats: false)
                    })
                    */
                    
                }
            }
            
        }
        else{
            //in case of non existing friend
           
            KNTipperTipManager.sharedInstance.tipAnUnknown(self.unknownPersonToTip!, amountInCents: convertedAmount, cardId: self.card!.id, pinCode: passcode, completed: { (success, errors) -> () in
                
                if (success) {
                    
                    messageViewController.imageName = "OvalCheck"
                    messageViewController.actionDescription = "Sent"
                    
                    messageViewController.knDelegate!.didFinishLoadingView!(false, storyboardName: nil, viewControllerName: nil)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        var unwindToMain: Selector = "unwindToMain"
                        NSTimer.scheduledTimerWithTimeInterval(1.4, target: self, selector: unwindToMain, userInfo: nil, repeats: false)
                        appDelegate.setInitialUsageCount()
                    })
                    
                }
                else{
                    
                    messageViewController.imageName = "BigWarning"
                    messageViewController.actionDescription = "Failed"
                    messageViewController.knDelegate?.didFinishLoadingView!(false, storyboardName: nil, viewControllerName: nil)
                    self.errors = errors
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let showError: Selector = "showError"
                        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: showError, userInfo: nil, repeats: false)
                    })
                    
                }

            })
            
        }
        
    }
    
    func showError(){
        var errorsString: String = ""
        for error:KNAPIResponse.APIError in self.errors!{
            errorsString += (error.errorMessage + "\n")
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                message: errorsString)
        })
    }
    
    func unwindToMain(){
        
        // close search box in KNMainViewController
        let mainViewController = self.navigationController?.viewControllers[1] as? KNMainViewController
        if mainViewController != nil && mainViewController!.isSearching == true {
            
            mainViewController!.didTouchRightButton(nil)
        }
        
        KNHelperManager.sharedInstance.setAnimationFade(self.navigationController?)
        self.navigationController?.popToViewController(self.navigationController?.viewControllers[1] as UIViewController, animated: false)
    }
    
    func closeView(){
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kColoseCurrentModuleNotification, object: nil)
        
        let appDelegate:KNAppDelegate = UIApplication.sharedApplication().delegate as KNAppDelegate
        self.performSegueWithIdentifier(appDelegate.unwindSegueForTipperModule, sender: self)
    }
    
    func goProfile() {
        KNHelperManager.sharedInstance.setAnimationFade(self.navigationController?)
        self.navigationController?.popToViewController(self.navigationController?.viewControllers[2] as UIViewController, animated: false)
    }
    
    func goAmount() {
        KNHelperManager.sharedInstance.setAnimationFade(self.navigationController?)
        self.navigationController?.popToViewController(self.navigationController?.viewControllers[3] as UIViewController, animated: false)
    }
    
    func goBack() {
        KNHelperManager.sharedInstance.setAnimationFade(self.navigationController?)
        self.navigationController?.popViewControllerAnimated(false)
    }
}
