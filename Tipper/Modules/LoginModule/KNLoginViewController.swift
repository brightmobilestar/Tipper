//
//  KNLoginViewController.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/18/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

class KNLoginViewController: KNBaseViewController, UITextFieldDelegate {
   
    @IBOutlet weak var btnBack: UIBarButtonItem?
    @IBOutlet weak var btnNext: UIBarButtonItem?
    @IBOutlet weak var imgvAvatar: KNImageView?
    @IBOutlet weak var lbUserName: UILabel?
    @IBOutlet weak var tfPassword: KNTextField?
    @IBOutlet var forgotPasswordButton: UIButton!
    
    var viewsMovingWithKeyboard = [UIView]()
    var lowestViewThatShouldNotGetCoveredByKeyboard: UIView?
    let marginBetweenKeyboardAndLowestView: CGFloat = 30
    
    var activityViewWrapper: KNActivityViewWrapper?
    
    override func viewDidLoad() {
          super.viewDidLoad()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "textFieldTextChanged:", name:UITextFieldTextDidChangeNotification, object: nil)
        
        self.forgotPasswordButton.titleLabel!.text = NSLocalizedString("forgotPassword?", comment: "")
        
        self.tfPassword!.keyboardAnimationDisabled = true
        
        self.viewsMovingWithKeyboard.append(self.tfPassword!)
        self.viewsMovingWithKeyboard.append(self.forgotPasswordButton)
        self.viewsMovingWithKeyboard.append(self.imgvAvatar!)
        self.viewsMovingWithKeyboard.append(self.lbUserName!)
        
        self.lowestViewThatShouldNotGetCoveredByKeyboard = self.forgotPasswordButton
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil);
        
        self.btnNext!.setTitlePositionAdjustment(UIOffsetMake(-8, 0), forBarMetrics: UIBarMetrics.Default)
        
        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics:UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        
        self.navigationItem.rightBarButtonItem!.enabled = false
        //use Kesher to load lazy
        if let avatar = KNMobileUserManager.sharedInstance.currentEmailExistanceResponse.avatar?{
            let avatarURL = NSURL(string:avatar)!
            var placeholder:UIImage = UIImage(named: "AddPhoto")!
            self.imgvAvatar!.loadImageFromURL(avatarURL, placeholder: placeholder)
        }
            var userName = KNMobileUserManager.sharedInstance.currentEmailExistanceResponse.publicName.formatPublicName()
    
        self.lbUserName!.text = NSLocalizedString("welcomeBack", comment: "") + userName + "."
        self.tfPassword?.setDefaultTextField()
        self.tfPassword?.toolbar?.hidden = true
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
            
            self.btnNext!.setTitlePositionAdjustment(UIOffsetMake(-8, 0), forBarMetrics: UIBarMetrics.Default)
            
            self.tfPassword!.toolbar?.hidden = true
            self.tfPassword!.addImageForLeftOrRightViewWithImage(leftImage: "Lock", rightImage: "TextFieldPlaceHolderIcon")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    func textFieldTextChanged(sender : AnyObject)
    {
        self.tfPassword!.required = true
        if(self.tfPassword!.validate() && self.tfPassword!.secureTextEntry) {
            self.navigationItem.rightBarButtonItem!.enabled = true
        }
        else {
            self.navigationItem.rightBarButtonItem!.enabled = false
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        /*
        self.tfPassword!.text! += string
        var isBackSpace: Bool = "\(string[0].utf8)" == "" ? true : false
        if(isBackSpace)
        {
            self.tfPassword!.text = self.tfPassword!.text.substringToIndex(self.tfPassword!.text.endIndex.predecessor())
            if self.tfPassword!.text.length == 0
            {
                self.tfPassword!.secureTextEntry = false
            }
        }
        
        if self.tfPassword!.text!.length == 1 && self.tfPassword!.secureTextEntry == false
        {
            self.tfPassword!.secureTextEntry = true
            self.tfPassword!.text = string
        }
        */
        
        /*
        self.tfPassword!.required = true
        if(self.tfPassword!.validate() && self.tfPassword!.secureTextEntry) {
            self.navigationItem.rightBarButtonItem!.enabled = true
        }
        else {
            self.navigationItem.rightBarButtonItem!.enabled = false
        }
        */
        
        return true
    }
    
    func textFieldDidEndEditing() {
        if(self.tfPassword!.secureTextEntry == false){
            self.tfPassword!.text! = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        self.goToMain()
        //NSTimer.scheduledTimerWithTimeInterval(kChangeStoryboardTimer, target: self, selector: Selector("goToMain"), userInfo: nil, repeats: false)
        return true
    }
    
    // MARK: IBActions
    
    @IBAction func backSplashScreen(sender: AnyObject) {
        let viewcontroller : UIViewController = KNStoryboardManager.sharedInstance.getViewControllerInitial(kMainStoryboardName) as UIViewController
        self.preparePopAnimation(presentedViewController: viewcontroller)
        self.presentViewController(viewcontroller, animated: true, completion: nil)
    }
    
    @IBAction func goToMainScreen(sender: AnyObject) {
        self.tfPassword!.resignFirstResponder()
        self.goToMain()
    }
    
    @IBAction func forgotPasswordButtonTouchUpInside(sender: UIButton)
    {
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.tfPassword!.resignFirstResponder()
        
        self.activityViewWrapper!.setLabelText(NSLocalizedString("sendingEmail", comment: ""))
        self.activityViewWrapper!.addActivityView(animateIn: true) { (success) -> Void in
            self.tfPassword!.text! = ""
        }
        
        KNPasswordManager.sharedInstance.forgotPasswordWithEmail(KNMobileUserManager.sharedInstance.currentEmailExistanceResponse.email, completed: { (success, errors) -> () in
            self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
                
                if success == true
                {
                    self.activityViewWrapper!.setLabelText(NSLocalizedString("emailSent", comment: ""))
                    self.activityViewWrapper!.removeActivityViewSuccess()
                }
                else
                {
                    self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                    KNAlertStandard.sharedInstance.showAlert(self, title: "Error", message: errors![0].errorMessage.stringByReplacingOccurrencesOfString(".", withString: "", options: nil, range: nil), buttonTitle: "Ok")
                }
            })
        })
    }
    
    // MARK: Private
    
    func goToMain() {
        
        self.navigationItem.rightBarButtonItem?.enabled = false
        let checkPassword: Selector = "checkPassword"
        NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: checkPassword, userInfo: nil, repeats: false)
        
    }
    


    func checkPassword() {
        self.tfPassword!.required = true
        if(self.tfPassword!.validate()) {
            
            self.activityViewWrapper!.setLabelText(NSLocalizedString("loggingIn", comment: ""))
            self.activityViewWrapper!.addActivityView(animateIn: true, completionHandler: nil)
            
            KNLoginManager.sharedInstance.loginUser(KNMobileUserManager.sharedInstance.currentEmailExistanceResponse.email, password: self.tfPassword!.text, completed: { (success, user, errors) -> () in
                

    
                if (success){
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        if  KNAddressBookManager.sharedInstance.hasRequestedAccessContact(){
                            
                            if KNMobileUserManager.sharedInstance.hasAddressBookSynchronized(){
                                let viewcontroller : UIViewController = KNStoryboardManager.sharedInstance.getViewControllerWithIdentifierFromStoryboard(kMainViewController , storyboardName: kTipperStoryboardName) as UIViewController
                                
                                self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
                                    
                                    print()
                                    self.navigationController?.pushViewController(viewcontroller, animated: true)
                                    
                                    
                                    
                                    
                                    
                                })
                            }
                            else{
                                let viewcontroller : UIViewController = KNStoryboardManager.sharedInstance.getViewControllerWithIdentifierFromStoryboard(kAccessContactsViewController , storyboardName: kTipperStoryboardName) as UIViewController
                                
                                self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
                                    
                                    self.navigationController?.pushViewController(viewcontroller, animated: true)
                                    self.navigationController?.viewControllers.removeAtIndex(0)
                                    
                                })
                            }
                            
       
                        
                        }else{
                            
                            let viewcontroller : UIViewController = KNStoryboardManager.sharedInstance.getViewControllerWithIdentifierFromStoryboard(kAccessContactsViewController , storyboardName: kTipperStoryboardName) as UIViewController
                            
                            self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
                                
                                self.navigationController?.pushViewController(viewcontroller, animated: true)
                                self.navigationController?.viewControllers.removeAtIndex(0)
                                
                            })
                            
                        }
                        
                        self.navigationController?.navigationBar.hidden = true
                        self.navigationItem.rightBarButtonItem?.enabled = true
                    })
                }
                else{
                    
                    self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
                        
                        self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                        
                        var errorString = ""
                        for error:KNAPIResponse.APIError in errors! {
                            errorString += (error.errorMessage + "\n")
                        }
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            KNAlertStandard.sharedInstance.showAlert(self.navigationController!, title: "Error", message: errorString)
                          
                            
                            
                            self.navigationItem.rightBarButtonItem?.enabled = true
                        })
                        
                    })

                }
            })
        }
    }

    func animateViewsWithKeyboard(notification: NSNotification)
    {
        let notificationInfo = notification.userInfo! as Dictionary
        let finalKeyboardFrame = notificationInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        let keyboardAnimationDuration: NSTimeInterval = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as Double
        let keyboardAnimationCurveNumber = notificationInfo[UIKeyboardAnimationCurveUserInfoKey] as UInt
        let animationOptions = UIViewAnimationOptions(keyboardAnimationCurveNumber << 16)
        
        if(notification.name == UIKeyboardWillShowNotification)
        {
            let finalKeyboardYPosition = self.view.frame.size.height - finalKeyboardFrame.size.height
            let lowestUncoveredYPosition = self.lowestViewThatShouldNotGetCoveredByKeyboard!.frame.origin.y + self.lowestViewThatShouldNotGetCoveredByKeyboard!.frame.size.height + self.marginBetweenKeyboardAndLowestView
            let moveDistance = lowestUncoveredYPosition - finalKeyboardYPosition
            
            if(moveDistance > 0)
            {
                
                UIView.animateWithDuration(keyboardAnimationDuration, delay: 0, options: animationOptions, animations: { () -> Void in
                    
                    for view in self.viewsMovingWithKeyboard
                    {
                        view.layer.transform = CATransform3DMakeTranslation(0.0, -moveDistance, 0.0)
                    }
                    
                    }, completion: nil)
                
            }
            
        }
        if(notification.name == UIKeyboardWillHideNotification)
        {
            UIView.animateWithDuration(keyboardAnimationDuration, delay: 0, options: animationOptions, animations: { () -> Void in
                
                for view in self.viewsMovingWithKeyboard
                {
                    view.layer.transform = CATransform3DMakeTranslation(0.0, 0.0, 0.0)
                }
                
                }, completion: nil)
        }
        
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        self.animateViewsWithKeyboard(notification)
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        self.animateViewsWithKeyboard(notification)
    }
    
}
