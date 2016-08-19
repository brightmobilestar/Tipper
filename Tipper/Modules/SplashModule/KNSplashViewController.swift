//
//  KNSplashViewController.swift
//  CloudBeacon
//
//  Created by Peter van de Put on 24/10/14.
//  Copyright (c) 2014 Knodeit LLC. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
 

public class KNSplashViewController: UIViewController, KNTutorialViewControllerDelegate, UITextFieldDelegate, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate
{
    @IBOutlet weak var srvContent: UIScrollView?
    @IBOutlet weak var imgvLogo:UIImageView?
    @IBOutlet weak var lbTipper:UILabel?
    @IBOutlet weak var lbSendTipsPeriod:UILabel?
    @IBOutlet weak var tfEmail: KNTextField?
    @IBOutlet weak var lcLogoAndEmailMargin: NSLayoutConstraint?
    @IBOutlet weak var lcTopMargin: NSLayoutConstraint?
    @IBOutlet weak var lcLogoWidthHeight: NSLayoutConstraint?
    @IBOutlet var lcInsildeLogo: [NSLayoutConstraint]!
    
    var logoWightHeightTemp: CGFloat = 0
    
    // MARK: - Private properties -
    var timer = NSTimer()

    var activityViewWrapper: KNActivityViewWrapper?
    
    var currentTextFieldTextIsPlaceholder = true
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "textFieldTextChanged:", name:UITextFieldTextDidChangeNotification, object: nil)
        
        let backgroundImageView:UIImageView = UIImageView(frame: self.view.frame)
        backgroundImageView.image = UIImage(named: "Background");
        self.view.insertSubview(backgroundImageView, atIndex: 0);

        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapRecognizer)
        
        // Do any additional setup after loading the view, typically from a nib.
        //Animate the controls fading invalidate
        let aSelector : Selector = "timerFired"
        timer = NSTimer.scheduledTimerWithTimeInterval(kSecondToDisplaySplash, target: self, selector: aSelector, userInfo: nil, repeats: true)
        
        self.srvContent!.alpha = 0.0
        UIView.animateWithDuration(kSecondToDisplaySplash, animations: { () -> Void in
            self.srvContent!.alpha = 1.0
        })
        
        self.tfEmail!.setDefaultTextFieldWithPlaceHolder(NSLocalizedString("enterYourEmail", comment: ""))
        self.lbTipper!.text = NSLocalizedString("tipperTitle", comment: "")
        self.lbSendTipsPeriod!.text = NSLocalizedString("sendTipsPeriod", comment: "")
        self.tfEmail!.toolbar!.hidden = true

    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override public func viewWillAppear(animated: Bool) {
        
        
        
        // Start - Fix crashed on iOS 7.0
        self.lcTopMargin?.constant = ScreenHeight*splashScreenWithEmailRatio
        self.lcLogoAndEmailMargin?.constant = ScreenHeight*splashScreenWithLogoAndEmailRatio
        // End
        
        self.logoWightHeightTemp = self.lcLogoWidthHeight!.constant
        
        dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
            //self.tfEmail!.text = ""
            self.tfEmail!.addImageForLeftOrRightViewWithImage(leftImage: "EmailIcon", rightImage: "TextFieldPlaceHolderIcon")
        }        
       
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(0.5, animations: {
            self.imgvLogo!.alpha = 1.0
            self.lbTipper!.alpha = 1.0
            self.lbSendTipsPeriod!.alpha = 1.0
        })
        //check if we are already logged in
        if (KNMobileUserManager.sharedInstance.hasSavedUser()){
                       //We are already logged in so no need to do that again
            self.activityViewWrapper!.setLabelText(NSLocalizedString("connecting", comment: ""))
            self.activityViewWrapper!.addActivityView(animateIn: true, completionHandler: nil)
            self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
                //self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                //run the processmanager to do what it needs to do on return to the app
                KNProcessManager.sharedInstance.runProcessesOnReturningToTheApp()
                KNFriendManager.sharedInstance.fetchFriendsFromServer({ (success, errors) -> () in
                    self.goToMainScreen(animated: true)
                })
                
             
                
            })
        }
        else{
            dispatch_after(0, dispatch_get_main_queue(), { () -> Void in
               
            })
        }
    }
    
    func textFieldTextChanged(sender : AnyObject)
    {
        self.tfEmail!.isEmailField = true
        
        if(self.tfEmail!.validate())
        {
            self.tfEmail!.addImageForLeftOrRightViewWithImage(leftImage: "EmailIcon", rightImage: "Check")
        }
        else
        {
            if strlen(self.tfEmail!.text.stringByReplacingOccurrencesOfString(" ", withString: "", options: nil, range: nil)) == 0
            {
                self.tfEmail!.addImageForLeftOrRightViewWithImage(leftImage: "EmailIcon", rightImage: "TextFieldPlaceHolderIcon")
            }
            else
            {
                self.tfEmail!.addImageForLeftOrRightViewWithImage(leftImage: "EmailIcon", rightImage: "Warning")
            }
        }
    }
    
    //fired by timer
    func timerFired() {
        timer.invalidate()
        gotoNextSegue()
    }
    
    
    //navigate to the next segue
    func gotoNextSegue(){
        executeFirstTimeProcesses()
    }
 
    
    @IBAction func createAccount(sender: AnyObject)
    {
        let vc :UIViewController =  KNStoryboardManager.sharedInstance.getViewControllerWithIdentifierFromStoryboard(kAccountCreateStoryboardId,storyboardName:kAccountStoryboardName)
        self.preparePushAnimation(presentedViewController: vc)
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func launchLandingProcess() {
    }
    
    func executeFirstTimeProcesses()
    {
        if(kUseTutorial)  && (NSUserDefaults().boolForKey(kTutorialAlreadyShown) == false)
        {
            let stb = UIStoryboard(name: kTutorialStoryboardName, bundle: nil)
            let tutorial = stb.instantiateViewControllerWithIdentifier(kTutorialMasterPage) as KNTutorialViewController
            //Add pages
            let page_one = stb.instantiateViewControllerWithIdentifier("KNTutorialPageOne") as UIViewController
            let page_two = stb.instantiateViewControllerWithIdentifier("KNTutorialPageTwo") as UIViewController
            let page_three = stb.instantiateViewControllerWithIdentifier("KNTutorialPageThree") as UIViewController
            let page_four = stb.instantiateViewControllerWithIdentifier("KNTutorialPageFour") as UIViewController
            tutorial.addViewController(page_one)
            tutorial.addViewController(page_two)
            tutorial.addViewController(page_three)
            tutorial.addViewController(page_four)
            //set yourself as delegate
            
            tutorial.delegate=self
            self.preparePushAnimation(presentedViewController: tutorial)
            self.presentViewController(tutorial, animated: true, completion: nil)
        }
        else
        {
            launchLandingProcess()
        }
    }

   
    // MARK: - Tutorial delegates -
    func tutorialCloseButtonPressed()
    {
        //dismiss tutorial
        self.dismissViewControllerAnimated(true, completion: nil)
        NSUserDefaults().setBool(true, forKey: kTutorialAlreadyShown)
        //move one
        launchLandingProcess()
    }

    // Authentication delegate
    func authenticationLoggedIn()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
      
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {

        return true
    }
    
    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {

        if textField.text == " "
        {
            textField.text = ""
        }
        return true
    }

    
    public func textFieldDidEndEditing(textField: UITextField) {
        self.actionAfterEnterEmail(textField)
    }
    

    
    
    //email has been entered so let's see what we got
    func actionAfterEnterEmail(textField: UITextField)
    {
        
        //let viewcontroller : UINavigationController = KNStoryboardManager.sharedInstance.getViewControllerInitial(kWithdrawModuleStoryboardName) as UINavigationController
        //self.preparePushAnimation(presentedViewController: viewcontroller)
        //self.presentViewController(viewcontroller, animated: true, completion: nil)
        
        self.tfEmail!.isEmailField = true
        if(self.tfEmail!.validate()) {
            // Hide keyboard
            self.dismissKeyboard()
            
            self.activityViewWrapper!.setLabelText(NSLocalizedString("checkingEmail", comment: ""))
            self.activityViewWrapper!.addActivityView(animateIn: true, completionHandler: nil)
          
            var cleanEmail = textField.text.lowercaseString
            
            KNMobileUserManager.sharedInstance.checkIfUserExistByEmail(emailAddress: cleanEmail, completed: { (success, found, emailExistResponse, apiResponse) -> () in
                
                self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
                
                    
                    if(success) {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            if (found && emailExistResponse != nil){
                                //the email address exists
                                dispatch_after(0, dispatch_get_main_queue(), { () -> Void in
                                    let goToLoginScreen:Selector = "goToLoginScreen"
                                    NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: goToLoginScreen, userInfo: nil, repeats: false)
                                })
                            }
                            else{
                                //it's new so we can create a new account
                                dispatch_after(0, dispatch_get_main_queue(), { () -> Void in
                                    let goToCreateAccountScreen:Selector = "goToCreateAccountScreen"
                                    NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: goToCreateAccountScreen, userInfo: nil, repeats: false)
                                })
                            }
                            
                        })
                    }
                    else {
                        
                        self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                        
                        for error:KNAPIResponse.APIError in apiResponse.errors {
                            if(error.errorCode == "1002") {
                                dispatch_after(0, dispatch_get_main_queue(), { () -> Void in
                                    let goToCreateAccountScreen:Selector = "goToCreateAccountScreen"
                                    NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: goToCreateAccountScreen, userInfo: nil, repeats: false)
                                })
                                return
                            }
                        }
                        var errorsString: String = ""
                        for error:KNAPIResponse.APIError in apiResponse.errors{
                            errorsString += (error.errorMessage + "\n")
                        }
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                                message: errorsString)
                        })
                    }
                    
                })
                
            })
            
            
            
        }
    }
    
    func goToLoginScreen()
    {
        let viewcontroller : UINavigationController = KNStoryboardManager.sharedInstance.getViewControllerInitial(kLoginStoryboardName) as UINavigationController
        self.preparePushAnimation(presentedViewController: viewcontroller)
        self.presentViewController(viewcontroller, animated: true, completion: nil)
    }
    
    func goToCreateAccountScreen()
    {
        let viewcontroller : UIViewController = KNStoryboardManager.sharedInstance.getViewControllerInitial(kAccountStoryboardName) as UINavigationController
        self.preparePushAnimation(presentedViewController: viewcontroller)
        self.presentViewController(viewcontroller, animated: true, completion: nil)
    }
    
    func goToMainScreen(#animated: Bool)
    {
        let vc:UIViewController = KNStoryboardManager.sharedInstance.getViewControllerInitial(kTipperStoryboardName)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.preparePushAnimation(presentedViewController: vc)
            self.presentViewController(vc, animated: animated, completion: nil)
        })
    }
    
    // MARK - private methods
    // Mark  - dismiss keyboard
    func dismissKeyboard(){
        
        if self.tfEmail!.isFirstResponder() {
        
            self.tfEmail!.resignFirstResponder()
        }
    }
    
    enum TransitionAnimationType
    {
        case Push, Pop, DismissPop, None
    }
    
    var transitionAnimationType: TransitionAnimationType = TransitionAnimationType.None
    
    func preparePushAnimation(#presentedViewController: UIViewController)
    {
        self.transitionAnimationType = TransitionAnimationType.Push
        presentedViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
        presentedViewController.transitioningDelegate = self;
    }
    
    func preparePopAnimation(#presentedViewController: UIViewController)
    {
        self.transitionAnimationType = TransitionAnimationType.Pop
        presentedViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
        presentedViewController.transitioningDelegate = self;
    }
    
    // UIViewControllerAnimatedTransitioning
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        
        var toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        var fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        transitionContext.containerView().addSubview(toViewController!.view)
        transitionContext.containerView().addSubview(fromViewController!.view)
        
        switch self.transitionAnimationType
        {
            
        case TransitionAnimationType.Push:
            
            transitionContext.containerView().bringSubviewToFront(toViewController!.view)
            
            toViewController!.view.transform = CGAffineTransformMakeTranslation(toViewController!.view.frame.size.width, 0.0)
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                
                toViewController!.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0)
                fromViewController!.view.transform = CGAffineTransformMakeTranslation(-((3.0)*fromViewController!.view.frame.width)/10.0, 0.0)
                
                }) { (success) -> Void in
                    
                    transitionContext.completeTransition(true)
                    
            }
            
            break;
            
        case TransitionAnimationType.Pop:
            
            transitionContext.containerView().bringSubviewToFront(fromViewController!.view)
            
            toViewController!.view.transform = CGAffineTransformMakeTranslation(-((3.0)*fromViewController!.view.frame.width)/10.0, 0.0)
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                
                toViewController!.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0)
                fromViewController!.view.transform = CGAffineTransformMakeTranslation(fromViewController!.view.frame.width, 0.0)
                
                }) { (success) -> Void in
                    
                    transitionContext.completeTransition(true)
                    
            }
            
            break;
            
        case TransitionAnimationType.DismissPop:
            
            transitionContext.containerView().bringSubviewToFront(fromViewController!.view)
            
            toViewController!.view.transform = CGAffineTransformMakeTranslation(-((3.0)*fromViewController!.view.frame.width)/10.0, 0.0)
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                
                toViewController!.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0)
                fromViewController!.view.transform = CGAffineTransformMakeTranslation(fromViewController!.view.frame.width, 0.0)
                
                }) { (success) -> Void in
                    
                    UIApplication.sharedApplication().keyWindow!.addSubview(toViewController!.view)
                    transitionContext.completeTransition(true)
                    
            }
            
            break;
            
        case TransitionAnimationType.None:
            
            transitionContext.completeTransition(true)
            
            break;
            
        default:
            
            transitionContext.completeTransition(true)
            
            break
            
        }
    }
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval
    {
        return kPushAndPopAnimationDuration
    }
    
    // UIViewControllerTransitioningDelegate
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return self
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return self
    }

}