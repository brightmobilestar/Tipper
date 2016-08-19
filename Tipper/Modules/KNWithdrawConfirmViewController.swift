//
//  KNWithdrawConfirmViewController.swift
//  Tipper
//
//  Created by Gregory Walters on 1/14/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit

class KNWithdrawConfirmViewController: KNBaseViewController, KNPasscodeViewControllerDeleagate, UITextFieldDelegate
{
    
    @IBOutlet var amountTextField: KNTextField!
    @IBOutlet var cardNameTextField: KNTextField!
    @IBOutlet var cardholderNameTextField: KNTextField!
    
    var carryOverTipAmount: String?
    var carryOverCard: TipperCard?        // Marked by luokey
    var carryOverPaypalEmail: String?       // Added by luokey
    
    var errors: [KNAPIResponse.APIError]?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.cardNameTextField.delegate = self
        self.amountTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.cardNameTextField.setTopBorder(lineColor: UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1))
        self.cardholderNameTextField.setTopBorder(lineColor: UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1))
        
        let spacerView = UIView(frame: CGRectMake(0.0, 0.0, 60.0, 10.0))
        self.cardNameTextField.leftViewMode = UITextFieldViewMode.Always
        self.cardNameTextField.leftView = spacerView
        let spacerView2 = UIView(frame: CGRectMake(0.0, 0.0, 60.0, 10.0))
        self.cardholderNameTextField.leftViewMode = UITextFieldViewMode.Always
        self.cardholderNameTextField.leftView = spacerView2
        
        if self.carryOverTipAmount != nil
        {
            self.amountTextField.attributedText = KNHelperManager.sharedInstance.attributedAmountString(self.carryOverTipAmount!)
        }
        
        if self.carryOverCard != nil
        {
            self.cardNameTextField.text = "\(self.carryOverCard!.brand) \(self.carryOverCard!.last4)"
            self.cardholderNameTextField.text = "\(self.carryOverCard!.firstName) \(self.carryOverCard!.lastName)"
        }
        
        
        // Added by luokey
        self.cardNameTextField.text = self.carryOverPaypalEmail
        self.cardholderNameTextField.text = ""
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        
        if textField == self.cardNameTextField
        {
            self.navigationController?.popViewControllerAnimated(true)
        }
        else if textField == self.amountTextField
        {
            self.navigationController!.popToViewController(self.navigationController!.viewControllers[2] as UIViewController, animated: true)
        }
        return false
    }
    
    @IBAction func backButtonTouch(sender: UIBarButtonItem)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func confirmButtonTouch(sender: UIButton)
    {
        let viewController: UIViewController = KNStoryboardManager.sharedInstance.getViewControllerInitial(kPasscodeStoryboardName) as UIViewController
        (viewController as KNPasscodeViewController).registerPasscode = false
        (viewController as KNPasscodeViewController).knPasscodeDelegate = self
        (viewController as KNPasscodeViewController).withdrawMode = true
        
        // Marked by luokey
//        (viewController as KNPasscodeViewController).withdrawCard = self.carryOverCard!
        
        // Added by luokey
        if self.carryOverCard != nil {
            (viewController as KNPasscodeViewController).withdrawCard = self.carryOverCard!
        }
        
        (viewController as KNPasscodeViewController).withdrawAmount = self.carryOverTipAmount!
        self.navigationController?.pushViewController(viewController, animated: false)
        KNNavigationAnimation.performFadeAnimation(self)
    }
    
    func didPasscodeSuccess(passcode: String){
        
        
        var convertedAmount:String = self.carryOverTipAmount!
        
        var numberFormatter:NSNumberFormatter = NSNumberFormatter()
        if let rawNumber:NSNumber = numberFormatter.numberFromString(convertedAmount){
            var amountInCents:NSNumber = NSNumber(float:(rawNumber.floatValue * 100))
            convertedAmount = numberFormatter.stringFromNumber(amountInCents)!
        }
        
        let viewController: UIViewController = KNStoryboardManager.sharedInstance.getViewControllerInitial(kMessageStoryboardName) as UIViewController
        var messageViewController: KNMessageViewController = viewController as KNMessageViewController
        messageViewController.imageName = "OvalIcon"
        messageViewController.actionDescription = NSLocalizedString("Withdrawing", comment: "")

        
        // Marked by luokey
//        KNTipperWithdrawManager.sharedInstance.withdrawBalance(toCard: self.carryOverCard!, amount: convertedAmount, pincode: passcode) { (success, responseObj) -> () in
        
        // Added by luokey
        KNTipperWithdrawManager.sharedInstance.withdrawBalanceToPaypal(amount: convertedAmount, pincode: passcode) { (success, responseObj) -> () in
            if responseObj.status == kAPIStatusOk{
                messageViewController.imageName = "OvalCheck"
                messageViewController.actionDescription = NSLocalizedString("Withdrew!", comment: "" )
                
                messageViewController.knDelegate!.didFinishLoadingView!(false, storyboardName: nil, viewControllerName: nil)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var unwindToBalanceHistory: Selector = "unwindToBalanceHistory"
                    NSTimer.scheduledTimerWithTimeInterval(1.4, target: self, selector: unwindToBalanceHistory, userInfo: nil, repeats: false)
                    appDelegate.setInitialUsageCount()
                })
            }
            else{
                messageViewController.imageName = "BigWarning"
                messageViewController.actionDescription = NSLocalizedString("Failed", comment: "" )
                messageViewController.knDelegate?.didFinishLoadingView!(false, storyboardName: nil, viewControllerName: nil)
                self.errors = responseObj.errors
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let showError: Selector = "showError"
                    NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: showError, userInfo: nil, repeats: false)
                })
            }
            
        }

       
        self.presentViewController(viewController, animated: false, completion: nil)
    }
    
    func unwindToBalanceHistory(){
        KNHelperManager.sharedInstance.setAnimationFade(self.navigationController?)
        self.navigationController?.popToViewController(self.navigationController?.viewControllers[0] as UIViewController, animated: false)
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
}
