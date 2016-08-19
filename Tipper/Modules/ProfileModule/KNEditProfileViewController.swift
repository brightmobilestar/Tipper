//
//  KNEditProfileViewController.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/18/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

@objc protocol KNEditProfileViewControllerDelegate {
    @objc optional func didEditProfileSuccess(profile: KNMobileUser?)
}

class KNEditProfileViewController: KNBaseViewController, UITextFieldDelegate, KNProfileAvatarViewDelegate {

    @IBOutlet weak var btnBack: UIBarButtonItem?
    @IBOutlet weak var btnSave: UIBarButtonItem?
    @IBOutlet weak var scrvWrapView: UIScrollView?
    @IBOutlet weak var tfUserName: KNTextField?
    @IBOutlet weak var tfEmail: KNTextField?
    @IBOutlet weak var tfPassword: KNTextField?
    @IBOutlet weak var tfConfirmPassword: KNTextField?
    @IBOutlet weak var tfPaypalEmail: KNTextField?  // Added by luokey
    @IBOutlet weak var vProfileAvatar: KNProfileAvatarView?
    @IBOutlet weak var lcBottomMargin: NSLayoutConstraint?
    
    @IBOutlet var imageButton: KNImageButton!
    @IBOutlet var changePhotoButton: UIButton!


    var knDelegate: KNEditProfileViewControllerDelegate?
    var hasImageAvatar:Bool = false
    var userNameTextField:Bool = false
    var userNameValidate:Bool = false
    var emailTextField:Bool = false
    var emailValidate:Bool = false
    var passwordTextField:Bool = false
    var confirmPasswordTextField:Bool = false
    var paypalEmailTextField:Bool = false   // Added by luokey
    var paypalEmailValidate:Bool = false    // Added by luokey
    var allField: Bool = false
    var activityViewWrapper: KNActivityViewWrapper?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "textFieldTextChanged:", name:UITextFieldTextDidChangeNotification, object: nil)
        
        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        // Do any additional setup after loading the view.
        self.vProfileAvatar!.setText(NSLocalizedString("changePhoto", comment: ""))
     
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        if  !KNMobileUserManager.sharedInstance.currentUser()!.avatar.isEmpty{
            self.vProfileAvatar!.profileAvatarImageButton!.showActivityView()
            
            KNAvatarManager.sharedInstance.getAvatarImage(placeholder: "AddPhoto") { (downloadSuccessful, avatarImage, errorDescription) -> Void in
                self.vProfileAvatar!.profileAvatarImageButton!.removeActivityView()
                if downloadSuccessful {
                    self.vProfileAvatar!.profileAvatarImageButton!.setImage(avatarImage!)
                }
            }
        }
       
        
        
        
        self.tfUserName!.text = KNMobileUserManager.sharedInstance.currentUser()!.publicName
        self.tfEmail!.text = KNMobileUserManager.sharedInstance.currentUser()!.email
        self.vProfileAvatar!.knDelegate = self
        self.imageButton.extendHitbox = true
        
        // Added by luokey
//        var currentUser: KNMobileUser? = KNMobileUserManager.sharedInstance.currentUser()
        var paypalEmail: String? = KNMobileUserManager.sharedInstance.currentUser()!.paypalEmail
        if (paypalEmail != nil) {
            self.tfPaypalEmail!.text = paypalEmail
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
            
            self.setup()
        //}
        
    }
    
    
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        /*
        dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
            
            self.setup()
        }
        */
    }

    
    @IBAction func imageButtonTouchUpInside(sender: KNImageButton) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.imageButton.alpha = 1.0
            self.changePhotoButton.alpha = 1.0
        })
    }
    
    @IBAction func imageButtonTouchDragOutside(sender: KNImageButton) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.imageButton.alpha = 1.0
            self.changePhotoButton.alpha = 1.0
        })
    }
    
    @IBAction func imageButtonTouchCancel(sender: KNImageButton) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.imageButton.alpha = 1.0
            self.changePhotoButton.alpha = 1.0
        })
    }
    
    @IBAction func imageButtonTouchUpOutside(sender: KNImageButton) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.imageButton.alpha = 1.0
            self.changePhotoButton.alpha = 1.0
        })
    }
    
    
    @IBAction func imageButtonTouchDown(sender: KNImageButton) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.imageButton.alpha = 0.3
            self.changePhotoButton.alpha = 0.3
        })
    }
    
    @IBAction func imageButtonTouchDragInside(sender: KNImageButton) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.imageButton.alpha = 0.3
            self.changePhotoButton.alpha = 0.3
        })
    }
    
    
    
    private func setup(){
    
        self.tfUserName?.setDefaultTextField()
        self.tfEmail?.setDefaultTextField()
        self.tfPassword?.setDefaultTextField()
        self.tfConfirmPassword?.setDefaultTextField()
        self.tfPaypalEmail?.setDefaultTextField()   // Added by luokey
        
        self.tfUserName!.addImageForLeftOrRightViewWithImage(leftImage: "ManIcon", rightImage: "TextFieldPlaceHolderIcon")
        self.tfEmail!.addImageForLeftOrRightViewWithImage(leftImage: "EmailIcon", rightImage: "TextFieldPlaceHolderIcon")
        self.tfPassword!.addImageForLeftOrRightViewWithImage(leftImage: "Lock", rightImage: "TextFieldPlaceHolderIcon")
        self.tfConfirmPassword!.addImageForLeftOrRightViewWithImage(leftImage: "Lock", rightImage: "TextFieldPlaceHolderIcon")
        self.tfPaypalEmail!.addImageForLeftOrRightViewWithImage(leftImage: "EmailIcon", rightImage: "TextFieldPlaceHolderIcon")     // Added by luokey
        
        
        // Added by luokey
        self.tfEmail?.autocorrectionType = UITextAutocorrectionType.No;
        self.tfPaypalEmail?.autocorrectionType = UITextAutocorrectionType.No;
        
        
        self.tfUserName!.scrollView?.contentSize = CGSizeMake(ScreenWidth, 435.0)
    }
    
    private func updateTextField() {
        self.tfUserName!.addImageForLeftOrRightViewWithImage(leftImage: "ManIcon", rightImage: "TextFieldPlaceHolderIcon")
        self.tfEmail!.addImageForLeftOrRightViewWithImage(leftImage: "EmailIcon", rightImage: "TextFieldPlaceHolderIcon")
        self.tfPassword!.addImageForLeftOrRightViewWithImage(leftImage: "Lock", rightImage: "TextFieldPlaceHolderIcon")
        self.tfConfirmPassword!.addImageForLeftOrRightViewWithImage(leftImage: "Lock", rightImage: "TextFieldPlaceHolderIcon")
        self.tfPaypalEmail!.addImageForLeftOrRightViewWithImage(leftImage: "EmailIcon", rightImage: "TextFieldPlaceHolderIcon")     // Added by luokey
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //var futureText = textField.text.stringByReplacingCharactersInRange(range, withString: string)
        //var futureText = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        /*
        textField.text! += string
        if(string == String()) {
            textField.text = textField.text.substringToIndex(textField.text.endIndex.predecessor())
        }
        self.checkForSavingTextField(textField)
        */
        
        // Added by luokey
        if textField.isEqual(self.tfUserName) && string == " "
        {
            return false
        }
        
        return true
    }
    
    func textFieldTextChanged(sender : AnyObject) {
        
        self.checkForSavingTextField(sender.object as UITextField)
        //self.checkForSavingTextField(self.tfUserName!)
        //self.checkForSavingTextField(self.tfEmail!)
        //self.checkForSavingTextField(self.tfPassword!)
        //self.checkForSavingTextField(self.tfConfirmPassword!)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {

    }
    
    // MARK: IBAction
    @IBAction func goToSettingScreen(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveProfile(sender: AnyObject) {
        self.dismissKeyboard()
        self.navigationItem.rightBarButtonItem?.enabled = false
        let sendRequest: Selector = "sendRequest"
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: sendRequest, userInfo: nil, repeats: false)
    }
    
    // MARK: Private
    func sendRequest() {
        
        self.activityViewWrapper!.setLabelText(NSLocalizedString("saving", comment: ""))
        self.activityViewWrapper!.addActivityView(animateIn: true, completionHandler: nil)
        self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
            
        
        var password = KNMobileUserManager.sharedInstance.currentUser()!.password
        //1. get new password from UI if set
        if(self.tfPassword!.text != "" && self.tfConfirmPassword!.text != "" && self.tfPassword!.text == self.tfConfirmPassword!.text)
        {
            //if the password is changed keep it
            password = self.tfPassword!.text
        }
        
        //set the public Name
      
        var publicName:String  = self.tfUserName!.text
        
        var emailAddress:String  = self.tfEmail!.text
            
            // Added by luokey
            var paypalEmailAddress:String  = self.tfPaypalEmail!.text
        
        //set avatarName
        var avatarName:String = KNMobileUserManager.sharedInstance.currentUser()!.avatar
        
        //is there a new picture taken?
        if (self.hasImageAvatar){
            
            avatarName = KNAvatarManager.sharedInstance.createUniqueAvatarNameForUser(self.tfUserName!.text!)
            var avatarFullURL:String = kS3BaseURL+KNAvatarManager.sharedInstance.createUniqueAvatarNameForUser(self.tfUserName!.text!)
                
                //We need to upload the avatar before we pass the avatar property to the server while it doesnt exist
                KNAvatarManager.sharedInstance.uploadAvatar(avatarName: avatarName, publicRead: true, uploadProgress: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                    
                    }, uploadComplete: { (uploadSuccessful, errorDescription) -> Void in
                        
                        if (uploadSuccessful){
                           //Update our account
                            KNMobileUserManager.sharedInstance.updateUser(emailAddress: emailAddress, publicName: publicName, avatarName: avatarFullURL, password: password, paypalEmail: paypalEmailAddress) { (success, errors) -> () in
                                if (success){
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        
                                        
                                        
                                        
                                        //update our user object
                                        KNMobileUserManager.sharedInstance.currentUser()!.publicName = publicName
                                        KNMobileUserManager.sharedInstance.currentUser()!.email = emailAddress
                                        KNMobileUserManager.sharedInstance.currentUser()!.password = password
                                        KNMobileUserManager.sharedInstance.currentUser()!.avatar = avatarFullURL
                                        KNMobileUserManager.sharedInstance.currentUser()!.paypalEmail = paypalEmailAddress      // Added by luokey
                                        KNCoreDataManager.sharedInstance.saveContext()
                                        
                                        
                                         self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                                        
                                        self.knDelegate?.didEditProfileSuccess!(KNMobileUserManager.sharedInstance.currentUser()!)
                                        self.navigationController?.popToViewController(self.navigationController!.viewControllers[2] as UIViewController, animated: true)
                                        self.navigationItem.rightBarButtonItem?.enabled = true
                                    })
                                }
                                else{
                                    
                                    self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                                    
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
                            }
                            
                        }
                        else{
                            
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                                    message: errorDescription)
                                self.navigationItem.rightBarButtonItem?.enabled = true
                            })
                        }
                })
        }
        else{
            //Update account directly
            
            KNMobileUserManager.sharedInstance.updateUser(emailAddress: emailAddress, publicName: publicName, avatarName: KNMobileUserManager.sharedInstance.currentUser()!.avatar, password: password, paypalEmail: paypalEmailAddress) { (success, errors) -> () in
                if (success){
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        //update our user object
                        KNMobileUserManager.sharedInstance.currentUser()!.publicName = publicName
                        KNMobileUserManager.sharedInstance.currentUser()!.email = emailAddress
                        KNMobileUserManager.sharedInstance.currentUser()!.password = password
                        KNMobileUserManager.sharedInstance.currentUser()!.paypalEmail = paypalEmailAddress      // Added by luokey
                        KNCoreDataManager.sharedInstance.saveContext()
                        
                        self.knDelegate?.didEditProfileSuccess!(KNMobileUserManager.sharedInstance.currentUser()!)
                        
                        // Marked by luokey
//                        self.navigationController?.popToViewController(self.navigationController!.viewControllers[2] as UIViewController, animated: true)
                        
                        // Added by luokey
                        self.navigationController?.popViewControllerAnimated(true)
                        
                        self.navigationItem.rightBarButtonItem?.enabled = true
                        
                        
                         self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                    })
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                        
                         self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                        
                        self.knDelegate?.didEditProfileSuccess!(KNMobileUserManager.sharedInstance.currentUser()!)
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        self.navigationItem.rightBarButtonItem?.enabled = true
                        
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
            }
            
            
            
        }
        
        
         })
        
      
    }
    
    
    
    
    
        /*
    func sendRequest() {
    
    
        var passowrd:String = KNUserManager.sharedInstance.currentUser()!.password!
        if(self.tfPassword!.text != "" && self.tfConfirmPassword!.text != "" && self.tfPassword!.text == self.tfConfirmPassword!.text)
        {
            passowrd = self.tfPassword!.text
        }
    
        var avatarName:String = appDelegate.loggedUser!.avatar!
        var oldCachedImage:String = appDelegate.loggedUser!.getAvatarFilePath();
        if  self.hasImageAvatar == true {
    
            avatarName = appDelegate.loggedUser!.getAvatarNameForUploading()
        }
    
        appDelegate.loggedUser!.publicName = self.tfUserName!.text
        KNAPIClientManager.sharedInstance.updateAccount(avatarName, email: self.tfEmail!.text, username: self.tfUserName!.text, password: passowrd, confirmPassowrd: passowrd, accessToken: KNUserManager.sharedInstance.currentUser()!.accessToken!, loggedUser: appDelegate.loggedUser!) { (success, user, errors) -> () in

            if(success) {
                
                appDelegate.loggedUser = user
                User.parseUser(user!)
                KNUserManager.sharedInstance.saveAccountInfoWithPass(user!.userId! , pass: appDelegate.loggedUser!.password!, accessToken: appDelegate.loggedUser!.accessToken!)
                if self.hasImageAvatar == true {
                    
                    appDelegate.loggedUser!.uploadAvatar(avatarName:avatarName,  { (uploadSuccessful, errorDescription) -> Void in
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
    
                        })
                        
                        if uploadSuccessful == false {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                                    message: errorDescription)
                                self.navigationItem.rightBarButtonItem?.enabled = true
                            })
                        }
                        else {
                            self.hasImageAvatar = false
                            self.updateTextField()
                            self.knDelegate?.didEditProfileSuccess!(appDelegate.loggedUser!)
                            self.navigationController?.popToRootViewControllerAnimated(true)
                            self.navigationItem.rightBarButtonItem?.enabled = true
                        }
                    })
                }
                else{
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
    
                        self.tfPassword!.text = ""
                        self.tfConfirmPassword!.text = ""
                        self.updateTextField()
                        self.knDelegate?.didEditProfileSuccess!(appDelegate.loggedUser!)
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        self.navigationItem.rightBarButtonItem?.enabled = true
                    })
                }
            }
            else {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
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
        }
    }
    */
    
    func checkValidate(textField: UITextField) -> Bool{

        if(textField == self.tfUserName)
        {
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
        
        if(textField == self.tfEmail)
        {
            self.tfEmail!.isEmailField = true
            if(self.tfEmail!.validate()) {
                (textField as KNTextField).addImageForLeftOrRightViewWithImage(leftImage: "EmailIcon", rightImage: "Check")
                return true
            }
            else {
                (textField as KNTextField).addImageForLeftOrRightViewWithImage(leftImage: "EmailIcon", rightImage: "Warning")
            }
        }
        
        if(textField == self.tfPassword || textField == self.tfConfirmPassword)
        {
            self.tfPassword!.isNubmerOfCharacter = true
            self.tfConfirmPassword!.isNubmerOfCharacter = true
            if(textField == self.tfPassword){
                if((textField as KNTextField).validate()){
                    self.tfPassword!.addImageForLeftOrRightViewWithImage(leftImage: "Lock", rightImage: "Check")
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
        
        // Added by luokey
        if(textField == self.tfPaypalEmail)
        {
            self.tfPaypalEmail!.isEmailField = true
            if(self.tfPaypalEmail!.validate()) {
                (textField as KNTextField).addImageForLeftOrRightViewWithImage(leftImage: "EmailIcon", rightImage: "Check")
                return true
            }
            else {
                (textField as KNTextField).addImageForLeftOrRightViewWithImage(leftImage: "EmailIcon", rightImage: "Warning")
            }
        }
        
        return false
    }
    
    func checkForSaving()
    {
        allField = self.hasImageAvatar
        if(self.hasImageAvatar)
        {
            self.navigationItem.rightBarButtonItem!.enabled = true
        }
        else {
            self.navigationItem.rightBarButtonItem!.enabled = false
        }
    }
    
    func checkForSavingTextField(textField: UITextField) {
        
        if(textField == self.tfUserName) {
            self.userNameTextField = self.checkValidate(self.tfUserName!)
            //self.userNameValidate = (appDelegate.loggedUser!.publicName == self.tfUserName!.text) ? false : true
            self.userNameValidate = (KNMobileUserManager.sharedInstance.currentUser()!.publicName == self.tfUserName!.text) ? false : true
            self.allField = self.userNameTextField && self.userNameValidate
        }
        
        if(textField == self.tfEmail) {
            self.emailTextField = self.checkValidate(self.tfEmail!)
            //self.emailValidate = (appDelegate.loggedUser!.email == self.tfEmail!.text) ? false : true
            self.emailValidate = (KNMobileUserManager.sharedInstance.currentUser()!.email == self.tfEmail!.text) ? false : true
            self.allField = self.emailTextField && self.emailValidate
        }
        
        if(textField == self.tfPassword) {
            self.passwordTextField = self.checkValidate(self.tfPassword!)
            self.allField = self.passwordTextField
        }
        
        if(textField == self.tfConfirmPassword){
            self.confirmPasswordTextField = self.checkValidate(self.tfConfirmPassword!)
            self.allField = self.confirmPasswordTextField
        }
        
        // Added by luokey
        if(textField == self.tfPaypalEmail) {
            self.paypalEmailTextField = self.checkValidate(self.tfPaypalEmail!)
            //self.emailValidate = (appDelegate.loggedUser!.email == self.tfEmail!.text) ? false : true
            self.paypalEmailValidate = (KNMobileUserManager.sharedInstance.currentUser()!.paypalEmail == self.tfPaypalEmail!.text) ? false : true
            self.allField = self.paypalEmailTextField && self.paypalEmailValidate
        }
        
        
        // Marked by luokey
//        if(((self.userNameTextField && self.userNameValidate) || (self.emailTextField && self.emailValidate) || (self.passwordTextField && confirmPasswordTextField) || self.hasImageAvatar) && self.allField)
        
        // Added by luokey
        if(((self.userNameTextField && self.userNameValidate) || (self.emailTextField && self.emailValidate) || (self.passwordTextField && confirmPasswordTextField) || (self.paypalEmailTextField && self.paypalEmailValidate) || self.hasImageAvatar) && self.allField)
        {
            self.navigationItem.rightBarButtonItem!.enabled = true
        }
        else {
            self.navigationItem.rightBarButtonItem!.enabled = false
        }
    }
    
    //MARK delegate from Camera
    func didSelectedImage(selectedImage image: UIImage) {
        self.hasImageAvatar = true
        self.checkForSaving()
    }
    
    private func dismissKeyboard(){
        
        if self.tfEmail!.isFirstResponder() {
            self.tfEmail!.resignFirstResponder()
        }
        
        if self.tfUserName!.isFirstResponder() {
            self.tfUserName!.resignFirstResponder()
        }
        
        if self.tfPassword!.isFirstResponder() {
            self.tfPassword!.resignFirstResponder()
        }
        
        if self.tfConfirmPassword!.isFirstResponder() {
            self.tfConfirmPassword!.resignFirstResponder()
        }
        
        // Added by luokey
        if self.tfPaypalEmail!.isFirstResponder() {
            self.tfPaypalEmail!.resignFirstResponder()
        }
    }

}
