//
//  KNValidationCodeViewController.swift
//  Tipper
//
//  Created by Jay N on 11/18/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

class KNValidationCodeViewController: KNBaseViewController, KNNumberKeyboardDelegate {
    
    //MARK: IBOutlets
    @IBOutlet weak var ValidationView: UIView?
    @IBOutlet weak var bottomLineView: UIView?
    @IBOutlet weak var backButton: UIBarButtonItem?
    @IBOutlet weak var resendCodeButton: UIBarButtonItem?
    @IBOutlet weak var validationCodeTitleLabel: UILabel?
    
    @IBOutlet weak var firstCodeTextField: UITextField?
    @IBOutlet weak var secondCodeTextField: UITextField?
    @IBOutlet weak var thirdCodeTextField: UITextField?
    @IBOutlet weak var fourthCodeTextField: UITextField?
    
    var activityViewWrapper: KNActivityViewWrapper?
    
    //MARK: Contraints
    @IBOutlet weak var guideVerticalContraint: NSLayoutConstraint?
    @IBOutlet weak var codeVerticalContraint: NSLayoutConstraint?
    @IBOutlet weak var codeHeightContraint: NSLayoutConstraint?
    
    //MARK: Private
    private var keyboardView:KNNumberKeyboard!
    private var passCode:String = ""

    
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        self.activityViewWrapper?.setLabelText(NSLocalizedString("sendingVerificationCode", comment: ""))
        self.updateContraints()
        self.layoutControls()
    }
    
    //MARK: Update Contraints
    func updateContraints() {
        var heightRate = ScreenHeight/800
        self.guideVerticalContraint!.constant *= heightRate
        self.codeVerticalContraint!.constant *= heightRate
        self.codeHeightContraint!.constant *= heightRate
        
        if IsIphone4 {
            self.guideVerticalContraint!.constant /= 2
            self.codeVerticalContraint!.constant /= 2
        }
    }

    func layoutControls() {
        dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
            // Layout keyboard
            self.keyboardView = KNNumberKeyboard.initFromNib()
            self.keyboardView.delegate = self
            self.keyboardView.resizeKeyboardFollowFrame(self.ValidationView!.frame)
            self.view.addSubview(self.keyboardView)
            
            var textFieldBorderColor:CGColorRef = UIColor(red: 194/255.0, green: 200/255.0, blue: 210/255.0, alpha: 1).CGColor
            self.firstCodeTextField!.layer.borderColor = textFieldBorderColor
            self.firstCodeTextField!.layer.borderWidth = 0.5
            self.firstCodeTextField!.layer.cornerRadius = 2
            self.secondCodeTextField!.layer.borderColor = textFieldBorderColor
            self.secondCodeTextField!.layer.borderWidth = 0.5
            self.secondCodeTextField!.layer.cornerRadius = 2
            self.thirdCodeTextField!.layer.borderColor = textFieldBorderColor
            self.thirdCodeTextField!.layer.borderWidth = 0.5
            self.thirdCodeTextField!.layer.cornerRadius = 2
            self.fourthCodeTextField!.layer.borderColor = textFieldBorderColor
            self.fourthCodeTextField!.layer.borderWidth = 0.5
            self.fourthCodeTextField!.layer.cornerRadius = 2
            
            // Change top and bottom line height
            self.bottomLineView!.frame.size.height = 0.3
            
            // Set localized text for UI
            self.title = NSLocalizedString("validationCode", comment: "")
            self.resendCodeButton?.title = NSLocalizedString("resend", comment: "")
            self.validationCodeTitleLabel?.text = NSLocalizedString("validationCodeTitle", comment: "")
        }
    }
    
    //MARK: KNNumberKeyboard Delegate
    func keyboardPressNumber(character: String) {
        if countElements(self.passCode) >= 4 || character == "." {
            return
        }
        
        self.passCode += character
        self.codeChange()
    }
    
    func keyboardPressDelete() {
        if countElements(self.passCode) > 0 {
            self.passCode = dropLast(self.passCode)
            self.codeChange()
        }
    }
    
    func codeChange() {
        switch countElements(self.passCode) {
        case 1:
            self.firstCodeTextField?.text = self.passCode[0]
            self.secondCodeTextField?.text = ""
        case 2:
            self.secondCodeTextField?.text = self.passCode[1]
            self.thirdCodeTextField?.text = ""
        case 3:
            self.thirdCodeTextField?.text = self.passCode[2]
            self.fourthCodeTextField?.text = ""
        case 4:
            self.fourthCodeTextField?.text = self.passCode[3]
            delay(0.5, { () -> () in
                self.verifyCode()
            })
        default:
            self.firstCodeTextField?.text = ""
        }
    }
    
    //MARK: IBActions
    @IBAction func goBack(sender: UIBarButtonItem)
    {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func verifyCode() {
        
        
        
        let viewController: KNMessageViewController = KNStoryboardManager.sharedInstance.getViewControllerInitial(kMessageStoryboardName) as KNMessageViewController
        viewController.actionDescription = NSLocalizedString("verifying", comment: "")
        KNHelperManager.sharedInstance.setAnimationPushViewControllerNonAsync(self, push: true)
        self.presentViewController(viewController, animated: false, completion: nil)
        
        KNRegistrationManager.sharedInstance.sendVerificationCode(KNMobileUserManager.sharedInstance.currentEmailExistanceResponse.userId, verificationCode: self.passCode) { (success, responseObj) -> () in
          
 
            
      
            if(responseObj.status == kAPIStatusOk)
            {
                 
                //login the user
                KNLoginManager.sharedInstance.loginUser(KNMobileUserManager.sharedInstance.currentEmailExistanceResponse.email, password: KNMobileUserManager.sharedInstance.currentEmailExistanceResponse.password!, completed: { (success, user, errors) -> () in
                    if (success){
                        viewController.imageName = "OvalCheck"
                        viewController.actionDescription = NSLocalizedString("verified", comment: "")
                        viewController.knDelegate?.didFinishLoadingView!(true,storyboardName: kTipperStoryboardName,viewControllerName: nil)
                        //Peter Try asking push notifications here
                        KNAccessManager.sharedInstance.requestAccessForPushNotifications()
                        
                        
                    }
                    else{
                        if ( errors != nil ) {
                            viewController.imageName = "BigWarning"
                            viewController.actionDescription = NSLocalizedString("invalidVerificationCode", comment: "")
                            viewController.knDelegate?.didFinishLoadingView!(false,storyboardName: nil,viewControllerName: nil)
                        } else {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                                    message: "unknownError")
                            })
                        }
                    }
                })
            }
            else{
               
                viewController.imageName = "BigWarning"
                viewController.actionDescription = NSLocalizedString("invalidVerificationCode", comment: "")
                viewController.knDelegate?.didFinishLoadingView!(false,storyboardName: nil,viewControllerName: nil)
               //Clean
                self.firstCodeTextField?.text = ""
                self.secondCodeTextField?.text = ""
                self.thirdCodeTextField?.text = ""
                self.fourthCodeTextField?.text = ""
               
                
            }
            
        }
    }
    
    @IBAction func resendCode(sender: UIBarButtonItem) {
        
        self.activityViewWrapper!.setLabelText(NSLocalizedString("resending", comment: ""))
        self.activityViewWrapper!.addActivityView(animateIn: true, completionHandler: nil)
       
        

        
        KNRegistrationManager.sharedInstance.requestNewVerificationCode(KNMobileUserManager.sharedInstance.currentEmailExistanceResponse.userId) { (success, responseObj) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
                    self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                })
                if(responseObj.status == kAPIStatusOk) {
                    KNAlertStandard.sharedInstance.showAlert(self, title: "",
                        message: "resendCodeSuccess")
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
        }
        
       
    }

}
