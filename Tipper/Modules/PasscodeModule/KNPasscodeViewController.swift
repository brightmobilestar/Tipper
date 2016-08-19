//
//  KNPasscodeViewController.swift
//  Tipper
//
//  Created by Jay N. on 11/26/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

let kKNPasscodeMargintopRatio:CGFloat = 0.1
let kKNPasscodeMarginTitleRatio:CGFloat = 0.045
let kKNPasscodeKeyboardHeightRatio:CGFloat = 0.1625
let kKNPasscodePasscodeViewMarginBottomRatio:CGFloat = 50
let kKNPasscodeStandardMarginBottomRatio:CGFloat = 0.4
let kKNPasscodeMarginBottomDecrease:CGFloat = 0.002
let kKNPasscodeMaxNumberOfKeys:UInt = 4
let kKNPasscodeMinNumberOfKeys:UInt = 0

let kPasscodeResultVisibleDuration = 0.7

import UIKit

@objc protocol KNPasscodeViewControllerDeleagate{
    
    @objc optional func didRegisterPasscodeSuccess()
    @objc optional func didPasscodeSuccess(passcode: String)
}

class KNPasscodeViewController: KNBaseViewController, KNNumberKeyboardDelegate {

    @IBOutlet weak var vWrapper: UIView?
    @IBOutlet weak var lbTitle: UILabel?
    @IBOutlet weak var vPasscode: UIView?
    @IBOutlet var vNumbers: [UIView]!
    @IBOutlet weak var btnClose: UIButton?
    @IBOutlet weak var lcMarginTop: NSLayoutConstraint?
    @IBOutlet weak var lcMarginTitle: NSLayoutConstraint?
    //@IBOutlet weak var lcMarginBottom: NSLayoutConstraint?
    @IBOutlet weak var lcViewKeyboardHeight: NSLayoutConstraint?
    @IBOutlet weak var lcButtonHeight: NSLayoutConstraint?
    var registerPasscode:Bool = false
    var passcode: String?
    var repeatPasscode: String?
    var startRepeatPasscode: Bool = false
    
    
    var withdrawMode: Bool = false
    var withdrawCard: TipperCard!
    var withdrawAmount: String!
    
    var knPasscodeDelegate:KNPasscodeViewControllerDeleagate?
    var checkRegisterPasscodeInProfile: Bool = false
    var activityViewWrapper: KNActivityViewWrapper?
    var sendTipActivityViewWrapper: KNActivityViewWrapper!
    var withdrawActivityViewWrapper: KNActivityViewWrapper!
    
    var friend:KNFriend?
    var amount: String = ""
    var card:TipperCard?
    var unknownPersonToTip:String?
    
    var blockButtons = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.passcode = ""
        self.repeatPasscode = ""
        
        // Register notification to close module
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("goToSettingsModule"), name: kColoseCurrentModuleNotification, object: nil)
        
        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        self.activityViewWrapper!.setLabelText(NSLocalizedString("savingPasscode", comment: ""))
        
        self.sendTipActivityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        
        self.withdrawActivityViewWrapper = KNActivityViewWrapper(parentViewController: self)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        self.lcMarginTop!.constant = ScreenHeight*kKNPasscodeMargintopRatio
        self.lcMarginTitle!.constant = ScreenHeight*kKNPasscodeMarginTitleRatio
        self.lcViewKeyboardHeight!.constant = ScreenHeight*kKNPasscodeKeyboardHeightRatio
        var keyboardPositionY = ((ScreenWidth - kKNPasscodePasscodeViewMarginBottomRatio) + self.lcViewKeyboardHeight!.constant)/2 + ScreenHeight/2
        var bottomContraint:CGFloat = kKNPasscodeStandardMarginBottomRatio
        var buttonPosition:CGFloat = ScreenHeight - ScreenHeight*bottomContraint - self.lcButtonHeight!.constant
        while( buttonPosition <  keyboardPositionY)
        {
            bottomContraint = bottomContraint - kKNPasscodeMarginBottomDecrease
            buttonPosition = ScreenHeight - ScreenHeight*bottomContraint - self.lcButtonHeight!.constant 
        }
        //self.lcMarginBottom!.constant = ScreenHeight*bottomContraint

        
        // Added by luokey
        
        var constraints: NSArray? = self.view.constraints()
        for constraint in constraints! {
            if (constraint.firstItem.isEqual(self.btnClose)) {
                let newValue = (ScreenHeight + buttonPosition + self.btnClose!.frame.size.height) / 2 - ScreenHeight
                (constraint as NSLayoutConstraint).constant = newValue
            }
        }
        
        var center: CGPoint = self.btnClose!.center
        center.y = (ScreenHeight + buttonPosition) / 2
        self.btnClose?.center = center
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
            for numberView in self.vNumbers {
                numberView.layer.masksToBounds = true
                numberView.layer.cornerRadius = CGRectGetHeight(numberView.bounds)/2
                numberView.layer.borderWidth = 2
                numberView.layer.borderColor = UIColor.blackColor().CGColor
            }
            
            var keyboardView:KNNumberKeyboard = KNNumberKeyboard.initFromNib()
            keyboardView.delegate = self
            keyboardView.resizeKeyboardFollowFrame(self.vPasscode!.frame)
            self.vWrapper!.addSubview(keyboardView)
            
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: KNNumberKeyboardDelegate
    
    func keyboardPressDelete() {
        
        if self.blockButtons == true {
            return
        }
        
        if self.startRepeatPasscode {
            if(self.repeatPasscode!.length == 0) {
                return
            }
            if strlen(self.repeatPasscode!) > kKNPasscodeMinNumberOfKeys {
                (self.vNumbers[strlen(self.repeatPasscode!) - 1] as UIView).backgroundColor = UIColor.clearColor()
                self.repeatPasscode! = self.repeatPasscode!.substringToIndex(self.repeatPasscode!.endIndex.predecessor())
            }
        }
        else {
            if(self.passcode!.length == 0) {
                return
            }
            if strlen(self.passcode!) > kKNPasscodeMinNumberOfKeys {
                (self.vNumbers[strlen(self.passcode!) - 1] as UIView).backgroundColor = UIColor.clearColor()
                self.passcode! = self.passcode!.substringToIndex(self.passcode!.endIndex.predecessor())
            }
        }
    }
    
    func keyboardPressNumber(character: String) {
        
        println("keyboardPressNumber")
        
        if self.blockButtons == true {
            return
        }
        
        if character == "." {
            return
        }
        
        if self.startRepeatPasscode {
            if strlen(self.repeatPasscode!) < kKNPasscodeMaxNumberOfKeys {
                (self.vNumbers[strlen(self.repeatPasscode!) - 0] as UIView).backgroundColor = UIColor.blackColor()
                self.repeatPasscode! += character
            }
            
            if strlen(self.repeatPasscode!) == kKNPasscodeMaxNumberOfKeys {
                
                if(self.repeatPasscode! == self.passcode!) {
  
                    self.activityViewWrapper!.addActivityView(animateIn: true, completionHandler: nil)
                    KNMobileUserManager.sharedInstance.savePinCode(self.passcode!, completed: { (success, errors) -> () in
                        
                        self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
                            
                            if(success == true)
                            {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    //self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                                    self.knPasscodeDelegate?.didRegisterPasscodeSuccess!()
                                    self.closePasscode()
                                })
                            }
                            else
                            {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                                })
                                var errorsString: String = ""
                                for error:KNAPIResponse.APIError in errors!
                                {
                                    errorsString += (error.errorMessage + "\n")
                                }
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                                        message: errorsString)
                                    
                                    self.lbTitle!.text = NSLocalizedString("enterPasscode", comment: "")
                                    self.startRepeatPasscode = false
                                    self.viewDidLoad()
                                    for numberView in self.vNumbers {
                                        numberView.backgroundColor = UIColor.clearColor()
                                    }
                                })
                            }
                            
                        })
                        
                    })

                }
                else
                {
                    KNAlertStandard.sharedInstance.showAlert(self, title: "error", message: "passcodeNotMatch")
                    self.lbTitle!.text = NSLocalizedString("enterPasscode", comment: "")
                    self.startRepeatPasscode = false
                    self.viewDidLoad()
                    for numberView in self.vNumbers
                    {
                        numberView.backgroundColor = UIColor.clearColor()
                    }
                }
            }
        }
        else {
            if strlen(self.passcode!) < kKNPasscodeMaxNumberOfKeys {
                (self.vNumbers[strlen(self.passcode!) - 0] as UIView).backgroundColor = UIColor.blackColor()
                self.passcode! += character
            }
            
            if strlen(self.passcode!) == kKNPasscodeMaxNumberOfKeys {
                println("fourth")
                self.blockButtons = true
                self.delay(0.3, closure: { () -> () in
                    println("delay")
                    if(self.registerPasscode)
                    {
                        self.lbTitle!.text = NSLocalizedString("repeatPasscode", comment: "")
                        for numberView in self.vNumbers
                        {
                            numberView.backgroundColor = UIColor.clearColor()
                        }
                        self.startRepeatPasscode = true
                    }
                    else
                    {
                        //MARK add verification of the code
                        //KNHelperManager.sharedInstance.setAnimationPushViewController(self, push: true)
                        //self.knPasscodeDelegate!.didPasscodeSuccess!(self.passcode!)
                        
                        if self.registerPasscode == true
                        {
                            self.dismissViewControllerAnimated(false, completion: { () -> Void in
                                //self.knPasscodeDelegate!.didPasscodeSuccess!(self.passcode!)
                            })
                        }
                        else
                        {
                            if self.withdrawMode == true{
                                
                                var convertedAmount:String = self.withdrawAmount
                                
                                var numberFormatter:NSNumberFormatter = NSNumberFormatter()
                                if let rawNumber:NSNumber = numberFormatter.numberFromString(convertedAmount){
                                    var amountInCents:NSNumber = NSNumber(float:(rawNumber.floatValue * 100))
//                                    convertedAmount = numberFormatter.stringFromNumber(amountInCents)!        // Marked by luokey
                                    convertedAmount = numberFormatter.stringFromNumber(rawNumber)!              // Added by luokey
                                }
                                
                                self.withdrawActivityViewWrapper.setLabelText(NSLocalizedString("Withdrawing", comment: ""))
                                self.withdrawActivityViewWrapper.setImage(UIImage(named: "OvalIcon")!)
                                self.withdrawActivityViewWrapper.addActivityView(animateIn: true, completionHandler: nil)

                                // Marked by luokey
//                                KNTipperWithdrawManager.sharedInstance.withdrawBalance(toCard: self.withdrawCard, amount: convertedAmount, pincode: self.passcode!) { (success, responseObj) -> () in
                                // Added by luokey
                                KNTipperWithdrawManager.sharedInstance.withdrawBalanceToPaypal(amount: convertedAmount, pincode: self.passcode!) { (success, responseObj) -> () in
                                    
                                    self.withdrawActivityViewWrapper.minimumVisibleDurationCompletionHandler({ () -> Void in
                                        
                                        if responseObj.status == kAPIStatusOk {
                                            
                                            println("success")
                                            self.withdrawActivityViewWrapper.setLabelText(NSLocalizedString("Withdrew!", comment: ""))
                                            self.withdrawActivityViewWrapper.stopSpinning()
                                            self.withdrawActivityViewWrapper.setImage(UIImage(named: "OvalCheck")!)
                                            
                                            self.delay(kPasscodeResultVisibleDuration, closure: { () -> () in
                                                print()
                                                
                                                self.showWithdrawConfirmation()
                                                
                                                // Marked by luokey
//                                                self.navigationController?.popToViewController(self.navigationController?.viewControllers[1] as UIViewController, animated: true)
                                            })
                                            
                                        }
                                        else {
                                            
                                            println("fail")
                                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                for var i = 0; i < 4; ++i {
                                                    (self.vNumbers[i] as UIView).backgroundColor = UIColor.clearColor()
                                                }
                                                self.passcode = ""
                                                self.repeatPasscode = ""
                                            })
                                            
                                            self.withdrawActivityViewWrapper.setLabelText(NSLocalizedString("Failed", comment: ""))
                                            self.withdrawActivityViewWrapper.stopSpinning()
                                            self.withdrawActivityViewWrapper.setImage(UIImage(named: "BigWarning")!)
                                            
                                            self.delay(kPasscodeResultVisibleDuration, closure: { () -> () in
                                                self.withdrawActivityViewWrapper.removeActivityView(animateOut: true, completionHandler: nil)
                                                self.showError(responseObj.errors)
                                                
                                            })
                                            
                                            
                                        }
                                        
                                    })
                                    
                                }
                                


                            }
                            
                            else{
                                //We are tipping
                            
                            var convertedAmount:String = self.amount.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                                
                                // ----- Added by Luokey ----- //
                                var numberFormatter:NSNumberFormatter = NSNumberFormatter()
                                if let rawNumber:NSNumber = numberFormatter.numberFromString(self.amount){
                                    var amountInCents:NSNumber = NSNumber(float:(rawNumber.floatValue * 100))
                                    convertedAmount = numberFormatter.stringFromNumber(amountInCents)!
                                    
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
                                }
                                // ----- Added by Luokey ----- //
                            
                            self.sendTipActivityViewWrapper.setLabelText(NSLocalizedString("sending", comment: ""))
                            self.sendTipActivityViewWrapper.setImage(UIImage(named: "OvalIcon")!)
                            self.sendTipActivityViewWrapper.addActivityView(animateIn: true, completionHandler: nil)
                            
                            if self.friend != nil {
                                
                                println("friend")
                                KNTipperTipManager.sharedInstance.tipAFriend(self.friend!.friendId, amountInCents: convertedAmount,cardId:self.card!.id, pinCode: self.passcode!) { (success, errors) -> () in
                                    
                                    self.sendTipActivityViewWrapper.minimumVisibleDurationCompletionHandler({ () -> Void in
                                        
                                        if (success) {
                                            println("success")
                                            self.sendTipActivityViewWrapper.setLabelText(NSLocalizedString("sent", comment: ""))
                                            self.sendTipActivityViewWrapper.stopSpinning()
                                            self.sendTipActivityViewWrapper.setImage(UIImage(named: "OvalCheck")!)
                                            
                                            self.delay(kPasscodeResultVisibleDuration, closure: { () -> () in
                                                print()
                                                self.navigationController?.popToViewController(self.navigationController?.viewControllers[1] as UIViewController, animated: true)
                                            })
                                            
                                        }
                                        else{
                                            println("fail")
                                            
                                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                for var i = 0; i < 4; ++i {
                                                    (self.vNumbers[i] as UIView).backgroundColor = UIColor.clearColor()
                                                }
                                                self.passcode = ""
                                                self.repeatPasscode = ""
                                            })
                                            
                                            self.sendTipActivityViewWrapper.setLabelText(NSLocalizedString("failed", comment: ""))
                                            self.sendTipActivityViewWrapper.stopSpinning()
                                            self.sendTipActivityViewWrapper.setImage(UIImage(named: "BigWarning")!)
                                            
                                            self.delay(kPasscodeResultVisibleDuration, closure: { () -> () in
                                                self.sendTipActivityViewWrapper.removeActivityView(animateOut: true, completionHandler: nil)
                                                self.showError(errors)
                                                
                                            })
                                            
                                        }
                                        
                                    })
                                    
                                }
                                
                            }
                            else {
                                
                                println("no friend")
                                KNTipperTipManager.sharedInstance.tipAnUnknown(self.unknownPersonToTip!, amountInCents: convertedAmount, cardId: self.card!.id, pinCode: self.passcode!, completed: { (success, errors) -> () in
                                    
                                    self.sendTipActivityViewWrapper.minimumVisibleDurationCompletionHandler({ () -> Void in
                                        
                                        if (success) {
                                            println("success")
                                            self.sendTipActivityViewWrapper.setLabelText(NSLocalizedString("sent", comment: ""))
                                            self.sendTipActivityViewWrapper.stopSpinning()
                                            self.sendTipActivityViewWrapper.setImage(UIImage(named: "OvalCheck")!)
                                            
                                            self.delay(kPasscodeResultVisibleDuration, closure: { () -> () in
                                                print()
                                                self.navigationController?.popToViewController(self.navigationController?.viewControllers[1] as UIViewController, animated: true)
                                            })
                                            
                                        }
                                        else{
                                            println("fail")
                                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                for var i = 0; i < 4; ++i {
                                                    (self.vNumbers[i] as UIView).backgroundColor = UIColor.clearColor()
                                                }
                                                self.passcode = ""
                                                self.repeatPasscode = ""
                                            })
                                            
                                            self.sendTipActivityViewWrapper.setLabelText(NSLocalizedString("failed", comment: ""))
                                            self.sendTipActivityViewWrapper.stopSpinning()
                                            self.sendTipActivityViewWrapper.setImage(UIImage(named: "BigWarning")!)
                                            
                                            self.delay(kPasscodeResultVisibleDuration, closure: { () -> () in
                                                self.sendTipActivityViewWrapper.removeActivityView(animateOut: true, completionHandler: nil)
                                                self.showError(errors)
                                                
                                            })
                                            
                                        }
                                        
                                    })
                                    
                                })
                                
                            }
                            
                            //self.navigationController?.popViewControllerAnimated(false)
                                }
                        }//END else
                        
                        //self.knPasscodeDelegate!.didPasscodeSuccess!(self.passcode!)
                    }
                    
                    self.blockButtons = false
                })

            }
        }
    }
    
    func showError(errors: [KNAPIResponse.APIError]?){
        var errorsString: String = ""
        
        if errors != nil {
            for error:KNAPIResponse.APIError in errors!{
                errorsString += (error.errorMessage + "\n")
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                    message: errorsString)
            })
        }
    }
    
    // Added by luokey
    func showWithdrawConfirmation() {
        
        var showConfirmation = NSUserDefaults().boolForKey(kShowWithdrawConfirmation)
        
        if (showConfirmation == false) {
            
            NSUserDefaults().setBool(true, forKey: kShowWithdrawConfirmation)
            
            let alertController : KNStandardAlertController = KNStandardAlertController()
            
            alertController.setSubTitle(NSLocalizedString("withdrawConfirmation", comment: ""))
            alertController.addButton(NSLocalizedString("ok", comment: ""), action: { () -> Void in
                self.backToParent()
            })
            alertController.showOnViewController(self)
        }
        else {
            self.backToParent()
        }
    }
    
    func backToParent() {
        
        self.navigationController?.popToViewController(self.navigationController?.viewControllers[1] as UIViewController, animated: true)
    }
    
    // MARK: IBAction
    
    @IBAction func clickCloseButton(sender: AnyObject) {
        
        if self.blockButtons == true {
            return
        }
        
        if self.registerPasscode == false
        {
            if self.withdrawMode == true{
                self.navigationController?.popViewControllerAnimated(false)
                KNNavigationAnimation.performFadeAnimation(self)
            }
            else{
                self.navigationController?.popViewControllerAnimated(false)
                KNNavigationAnimation.performFadeAnimation(self)
            }
           
        }
        else
        {
            KNNavigationAnimation.performFadeAnimation(self)
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        
    }
    
    // MARK: Private
    
    func closePasscode() {
        if(self.checkRegisterPasscodeInProfile == false) {
            println("closePasscode: true")
            KNNavigationAnimation.performFadeAnimation(self)
            self.dismissViewControllerAnimated(false, completion: nil)
            //let dismissWithAnimation: Selector = "dismissWithAnimation"
            //NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: dismissWithAnimation, userInfo: nil, repeats: false)
        }
        else {
            println("closePasscode: false")
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        
    }
    
    func dismissWithAnimation() {
        println("dismissWithAnimation")
        KNHelperManager.sharedInstance.setAnimationPushViewController(self, push: false)
        self.dismissViewControllerAnimated(false, completion: nil)
    }

    
    func goToSettingsModule(){
        println("goToSettingsModule")
        KNHelperManager.sharedInstance.setAnimationPushViewController(self, push: false)
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            
            NSNotificationCenter.defaultCenter().removeObserver(self, name: kColoseCurrentModuleNotification, object: nil)
            
        })
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}
