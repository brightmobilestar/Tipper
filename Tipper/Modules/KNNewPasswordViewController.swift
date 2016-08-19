//
//  KNNewPasswordViewController.swift
//  Tipper
//
//  Created by Gregory Walters on 1/19/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit

class KNNewPasswordViewController: KNBaseViewController, UITextFieldDelegate
{
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var newPasswordTextField: KNTextField!
    @IBOutlet var repeatPasswordTextField: KNTextField!
    @IBOutlet var changePasswordLabel: UILabel!
    @IBOutlet var confirmButton: UIButton!
    
    var resetPasswordToken: String!
    
    var activityViewWrapper: KNActivityViewWrapper!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.cancelButton.titleLabel!.text = NSLocalizedString("cancel", comment: "")
        self.confirmButton.titleLabel!.text = NSLocalizedString("confirm", comment: "")
        self.changePasswordLabel.text = NSLocalizedString("changePassword", comment: "")
        self.newPasswordTextField.setDefaultTextFieldWithPlaceHolder(NSLocalizedString("newPassword", comment: ""))
        self.newPasswordTextField.toolbar!.hidden = true
        self.repeatPasswordTextField.setDefaultTextFieldWithPlaceHolder(NSLocalizedString("repeatPassword", comment: ""))
        self.repeatPasswordTextField.toolbar!.hidden = true
        self.newPasswordTextField.delegate = self
        self.repeatPasswordTextField.delegate = self
        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        self.activityViewWrapper!.setLabelText(NSLocalizedString("savingPassword", comment: ""))
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        
        // Added by luokey
//        let notificationCenter = NSNotificationCenter.defaultCenter()
//        notificationCenter.addObserver(self, selector: "textFieldTextChanged:", name:UITextFieldTextDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    // Added by luokey
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setup()
    }
    
    private func setup(){
        
        self.newPasswordTextField?.setDefaultTextField()
        self.repeatPasswordTextField?.setDefaultTextField()
        
        self.newPasswordTextField!.addImageForLeftOrRightViewWithImage(leftImage: "", rightImage: "TextFieldPlaceHolderIcon")
        self.repeatPasswordTextField!.addImageForLeftOrRightViewWithImage(leftImage: "", rightImage: "TextFieldPlaceHolderIcon")
    }
    
    private func updateTextField() {
        
        self.newPasswordTextField!.addImageForLeftOrRightViewWithImage(leftImage: "", rightImage: "TextFieldPlaceHolderIcon")
        self.repeatPasswordTextField!.addImageForLeftOrRightViewWithImage(leftImage: "", rightImage: "TextFieldPlaceHolderIcon")
    }
    
    func checkValidate(textField: UITextField) -> Bool{
        
        if (textField == self.newPasswordTextField || textField == self.repeatPasswordTextField)
        {
            self.newPasswordTextField!.isNubmerOfCharacter = true
            self.repeatPasswordTextField!.isNubmerOfCharacter = true
            
            if (textField == self.newPasswordTextField) {
                if ((textField as KNTextField).validate()) {
                    self.newPasswordTextField!.addImageForLeftOrRightViewWithImage(leftImage: "", rightImage: "Check")
                    return true
                }
                else {
                    self.newPasswordTextField!.addImageForLeftOrRightViewWithImage(leftImage: "", rightImage: "Warning")
                }
            }
            else {
                if ((textField as KNTextField).validate() && self.newPasswordTextField!.text == self.repeatPasswordTextField!.text) {
                    self.repeatPasswordTextField!.addImageForLeftOrRightViewWithImage(leftImage: "", rightImage: "Check")
                    return true
                }
                else {
                    self.repeatPasswordTextField!.addImageForLeftOrRightViewWithImage(leftImage: "", rightImage: "Warning")
                }
            }
        }
        
        return false
    }
    
    func textFieldTextChanged(sender : AnyObject) {
        
        self.checkForSavingTextField(sender.object as UITextField)
    }
    
    func checkForSavingTextField(textField: UITextField) {
        
        if(textField == self.newPasswordTextField) {
            self.checkValidate(self.newPasswordTextField!)
        }
        
        if(textField == self.repeatPasswordTextField){
            self.checkValidate(self.repeatPasswordTextField!)
        }
    }
    
    
    
    
    

    @IBAction func cancelButtonTouchUpInside(sender: UIButton)
    {
        KNNavigationAnimation.performFadeAnimation(self)
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func confirmButtonTouchUpInside(sender: UIButton)
    {
        self.dismissKeyboard()
        
        if self.newPasswordTextField.text == ""
        {
            KNAlertStandard.sharedInstance.showAlert(self, title: NSLocalizedString("pleaseEnterAPassword", comment: ""), message: "", buttonTitle: NSLocalizedString("ok", comment: ""))
        }
        else if self.repeatPasswordTextField.text == ""
        {
            KNAlertStandard.sharedInstance.showAlert(self, title: NSLocalizedString("pleaseRepeatThePassword", comment: ""), message: "", buttonTitle: NSLocalizedString("ok", comment: ""))
        }
        else if self.newPasswordTextField.text != self.repeatPasswordTextField.text
        {
            KNAlertStandard.sharedInstance.showAlert(self, title: NSLocalizedString("passwordsDontMatch", comment: ""), message: "", buttonTitle: NSLocalizedString("ok", comment: ""))
        }
        else if self.newPasswordTextField.text.length < 5
        {
            KNAlertStandard.sharedInstance.showAlert(self, title: NSLocalizedString("passwordTooShort", comment: ""), message: "Password must be 5 to 20 characters in length", buttonTitle: NSLocalizedString("ok", comment: ""))
        }
        else if self.newPasswordTextField.text.length > 20
        {
            KNAlertStandard.sharedInstance.showAlert(self, title: NSLocalizedString("passwordTooLong", comment: ""), message: "Password must be 5 to 20 characters in length", buttonTitle: NSLocalizedString("ok", comment: ""))
        }
        else
        {
            self.activityViewWrapper.addActivityView(animateIn: true, completionHandler: nil)
                KNPasswordManager.sharedInstance.resetPasswordWithEmail(self.resetPasswordToken, password: self.newPasswordTextField.text, confirmPassword: self.repeatPasswordTextField.text) { (success, errors) -> () in
        
                self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
    
                    if success == true
                    {
                       
                        dispatch_async(dispatch_get_main_queue(), {
                            KNNavigationAnimation.performFadeAnimation(self)
                            self.dismissViewControllerAnimated(false, completion: nil)
                        })
                    }
                    else
                    {
                        self.activityViewWrapper.removeActivityView(animateOut: true, completionHandler: { (success) -> Void in

                            dispatch_async(dispatch_get_main_queue(), {

                                if errors![0].errorMessage == "User not found"
                                {
                                    KNAlertStandard.sharedInstance.showAlert(self, title: NSLocalizedString("resetPasswordLinkExpired",comment:""), message: "", buttonTitle: NSLocalizedString("ok", comment: ""))
                                }
                                else
                                {
                                    KNAlertStandard.sharedInstance.showAlert(self, title: errors![0].errorMessage.stringByReplacingOccurrencesOfString(".", withString: "", options: nil, range: nil), message: "", buttonTitle: NSLocalizedString("ok", comment: ""))
                                }
    
                            })
    
                        })
                        
                        println("reset failed: \(errors![0].errorMessage)")
                    }
                
                })
                        
            }
            
        }
        
    }
    
    func dismissKeyboard()
    {
        self.newPasswordTextField.resignFirstResponder()
        self.repeatPasswordTextField.resignFirstResponder()
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        var castedTextField: KNTextField = textField as KNTextField
        castedTextField.text = castedTextField.text + string
        var isBackSpace: Bool = "\(string[0].utf8)" == "" ? true : false
        if(isBackSpace)
        {
            castedTextField.text = castedTextField.text.substringToIndex(castedTextField.text.endIndex.predecessor())
            if castedTextField.text.length == 0
            {
                castedTextField.secureTextEntry = false
            }
        }

        if castedTextField.text!.length == 1 && castedTextField.secureTextEntry == false
        {
            castedTextField.secureTextEntry = true
            castedTextField.text = string
        }

        castedTextField.required = true
        if(castedTextField.validate() && castedTextField.secureTextEntry) {
            //self.navigationItem.rightBarButtonItem!.enabled = true
        }
        else {
            //self.navigationItem.rightBarButtonItem!.enabled = false
        }
        
        // Added by luokey
        self.checkForSavingTextField(textField)
        
        return false
    }

    func textFieldDidEndEditing(textField: UITextField)
    {
        var castedTextField: KNTextField = textField as KNTextField
        if(castedTextField.secureTextEntry == false)
        {
            castedTextField.text = ""
        }
    }
    
    // Added by luokey
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.dismissKeyboard()
        
        self.confirmButtonTouchUpInside(self.confirmButton)
        
        return false
    }
    
}
