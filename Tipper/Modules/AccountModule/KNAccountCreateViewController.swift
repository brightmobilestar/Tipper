//
//  KNAccountCreateViewController.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 07/11/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//
import UIKit
import Foundation

class KNAccountCreateViewController: KNBaseViewController, UITextFieldDelegate, KNProfileAvatarViewDelegate {
    
    @IBOutlet weak var btnBack: UIBarButtonItem?
    @IBOutlet weak var btnNext: UIBarButtonItem?
    @IBOutlet weak var tfUserName: KNTextField?
    @IBOutlet weak var tfPassword: KNTextField?
    @IBOutlet weak var tfConfirmPassword: KNTextField?
    
    @IBOutlet weak var vProfileAvatar: KNProfileAvatarView?
    var hasImageAvatar:Bool?
    
    var userNameFieldChangeCharacters:Bool = false
    var passwordFieldChangeCharacter:Bool = false
    var confirmPasswordFieldChangeCharacter:Bool = false
    
    var activityViewWrapper: KNActivityViewWrapper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        self.activityViewWrapper!.setLabelText(NSLocalizedString("creatingAccount", comment: ""))
        
        self.btnNext!.setTitlePositionAdjustment(UIOffsetMake(-8, 0), forBarMetrics: UIBarMetrics.Default)
        
        self.navigationItem.rightBarButtonItem!.enabled = false
        
        //self.vProfileAvatar!.profileAvatarImageView!.userInteractionEnabled = true
        self.vProfileAvatar?.knDelegate = self
        
        // Register notification to close module
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("goToMainModule"), name: kColoseCurrentModuleNotification, object: nil)
        
        self.hasImageAvatar = false
        
        // Set placeholder
        self.tfUserName?.setDefaultTextFieldWithPlaceHolder(NSLocalizedString("publicName", comment: ""))
        self.tfPassword?.setDefaultTextFieldWithPlaceHolder(NSLocalizedString("password", comment: ""))
        self.tfConfirmPassword?.setDefaultTextFieldWithPlaceHolder(NSLocalizedString("repeatPassword", comment: ""))
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapRecognizer)

        // Set localized text for UI
        self.title = NSLocalizedString("createAccount", comment: "")
        self.btnNext?.title = NSLocalizedString("next", comment: "")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
            self.vProfileAvatar!.alpha = 1.0
            self.setup()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(self.userNameFieldChangeCharacters && self.passwordFieldChangeCharacter && self.confirmPasswordFieldChangeCharacter) {
            self.goToMobileNumberController(nil)
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if( self.userNameFieldChangeCharacters && self.passwordFieldChangeCharacter && self.confirmPasswordFieldChangeCharacter) {
            self.navigationItem.rightBarButtonItem!.enabled = true
        }
        else {
            self.navigationItem.rightBarButtonItem!.enabled = false
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        textField.text! += string
        if(string == String()) {
            textField.text = textField.text.substringToIndex(textField.text.endIndex.predecessor())
        }
        
        if(textField == self.tfUserName!) {
            self.userNameFieldChangeCharacters = self.checkValidate(self.tfUserName!)
        }
        if(textField == self.tfPassword!) {
            self.passwordFieldChangeCharacter = self.checkValidate(self.tfPassword!)
            if(self.passwordFieldChangeCharacter == true) {
                self.confirmPasswordFieldChangeCharacter = self.checkValidate(self.tfConfirmPassword!)
            }
        }
        if(textField == self.tfConfirmPassword!) {
            self.confirmPasswordFieldChangeCharacter = self.checkValidate(self.tfConfirmPassword!)
        }
        if( self.userNameFieldChangeCharacters && self.passwordFieldChangeCharacter && self.confirmPasswordFieldChangeCharacter) {
            self.navigationItem.rightBarButtonItem!.enabled = true
        }
        else {
            self.navigationItem.rightBarButtonItem!.enabled = false
        }
        
        return false
    }
    
    // MARK: Private
    
    private func setup(){
        
        self.tfUserName!.addImageForLeftOrRightViewWithImage(leftImage: "ManIcon", rightImage: "TextFieldPlaceHolderIcon")
        self.tfPassword!.addImageForLeftOrRightViewWithImage(leftImage: "Lock", rightImage: "TextFieldPlaceHolderIcon")
        self.tfConfirmPassword!.addImageForLeftOrRightViewWithImage(leftImage: "Lock", rightImage: "TextFieldPlaceHolderIcon")

    }
    
    func goToMainModule(){
    
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            
            NSNotificationCenter.defaultCenter().removeObserver(self, name: kColoseCurrentModuleNotification, object: nil)
            appDelegate.gotoMainModule()
        })
    }
    
    @IBAction func backSplashScreen(sender: UIBarButtonItem?) {
        let viewcontroller : UIViewController = KNStoryboardManager.sharedInstance.getViewControllerInitial(kMainStoryboardName) as UIViewController
        self.preparePopAnimation(presentedViewController: viewcontroller)
        self.presentViewController(viewcontroller, animated: true, completion: nil)
    }
    
    @IBAction func goToMobileNumberController(sender: UIBarButtonItem?) {
        // Dismis keyboard
        self.dismissKeyboard()
        self.navigationItem.rightBarButtonItem?.enabled = false
        let createAccount: Selector = "createAccount"
        NSTimer.scheduledTimerWithTimeInterval(0.0, target: self, selector: createAccount, userInfo: nil, repeats: false)
    }
    
    func createAccount() {
        
        self.activityViewWrapper!.addActivityView(animateIn: true, completionHandler: nil)
        var avatarName:String = ""
        if  self.hasImageAvatar! {
            avatarName = kS3BaseURL+KNAvatarManager.sharedInstance.createUniqueAvatarNameForUser(self.tfUserName!.text!)
            
            //We need to upload the avatar before we pass the avatar property to the server while it doesnt exist
            KNAvatarManager.sharedInstance.uploadAvatar(avatarName: avatarName, publicRead: true, uploadProgress: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                
            }, uploadComplete: { (uploadSuccessful, errorDescription) -> Void in
                
                if (uploadSuccessful){
                    self.performRegistration(avatarName)
                }
                else{
                    
                    self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
                        self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                    })
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                            message: errorDescription)
                        self.navigationItem.rightBarButtonItem?.enabled = true
                    })
                }
               
            })
        }
        else{
            //register User without avatar`
            performRegistration("")
        }
        
    }
    
    func performRegistration(avatarName:String){
        KNRegistrationManager.sharedInstance.registerUser(KNMobileUserManager.sharedInstance.currentEmailExistanceResponse.email, username: self.tfUserName!.text!, password:  self.tfPassword!.text!, confirmPassword: self.tfConfirmPassword!.text!, avatar: avatarName, completed: { (success, user, errors) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
            })
            
            if (success){
                // go to Mobile Number screen
                
                self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in

                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                        self.performSegueWithIdentifier("MobileNumberSegue", sender: AnyObject?())
                        self.navigationItem.rightBarButtonItem?.enabled = true
                    })
                    
                    
                })
                

            }
            else{
                //show error
                
                self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
                    self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                })
                
                var errorsString: String = ""
                for error:KNAPIResponse.APIError in errors!{
                    errorsString += (error.errorMessage + "\n")
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                        message: errorsString)
                    self.navigationItem.rightBarButtonItem?.enabled = true
                })
                
            }
            
            
            
        })
    }
    
       
    func checkValidate(textField: UITextField) -> Bool {
        
        if(textField == self.tfUserName) {
            self.tfUserName!.required = true
            self.tfUserName!.isPublicName = true
            if(self.tfUserName!.validate()) {
                (textField as KNTextField).addImageForLeftOrRightViewWithImage(leftImage: "ManIcon", rightImage: "Check")
                return true
            }
            else {
                (textField as KNTextField).addImageForLeftOrRightViewWithImage(leftImage: "ManIcon", rightImage: "Warning")
            }
        }
        
        if(textField == self.tfPassword || textField == self.tfConfirmPassword) {
            (textField as KNTextField).required = true
            (textField as KNTextField).isNubmerOfCharacter = true
            
            if(textField == self.tfPassword){
                if((textField as KNTextField).validate()){
                    self.tfPassword!.addImageForLeftOrRightViewWithImage(leftImage: "Lock", rightImage: "Check")
                    if(self.tfPassword!.text == self.tfConfirmPassword!.text) {
                        self.tfConfirmPassword!.addImageForLeftOrRightViewWithImage(leftImage: "Lock", rightImage: "Check")
                        return true
                    }
                    return true
                }
                else {
                    self.tfPassword!.addImageForLeftOrRightViewWithImage(leftImage: "Lock", rightImage: "Warning")
                }
            }
            else {
                if((textField as KNTextField).validate() && self.tfPassword!.text == self.tfConfirmPassword!.text){
                    self.tfConfirmPassword!.addImageForLeftOrRightViewWithImage(leftImage: "Lock", rightImage: "Check")
                    return true
                }
                else {
                    self.tfConfirmPassword!.addImageForLeftOrRightViewWithImage(leftImage: "Lock", rightImage: "Warning")
                }
            }
        }
        
        return false
    }
    
    
    // MARK: KNProfileAvatarViewDelegate
    func didSelectedImage(selectedImage image: UIImage) {
        
        self.hasImageAvatar = true
    }
    
    //MARK: Dismiss keyboard
    func dismissKeyboard(){
        
        if self.tfUserName!.isFirstResponder() {
            
            self.tfUserName!.resignFirstResponder()
        }

        if self.tfPassword!.isFirstResponder() {
            
            self.tfPassword!.resignFirstResponder()
        }
        
        if self.tfConfirmPassword!.isFirstResponder() {
            
            self.tfConfirmPassword!.resignFirstResponder()
        }
    }
    
    @IBAction func clickAvatar(sender: AnyObject) {
        self.vProfileAvatar?.alpha = 0.3
    }

    @IBAction func endAvatarTouch(sender: AnyObject) {
        self.vProfileAvatar?.alpha = 1.0
    }
    
}

