  //
//  KNBaseViewController.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/18/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

class KNBaseViewController: UIViewController, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate
{
    
    var currentScrollView: UIScrollView? = nil
    var creditCardView: KNCreditCardView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set font and style for navigation item title
        let titleDic:NSDictionary = [NSForegroundColorAttributeName:kNavigationTitleTintColor, NSFontAttributeName: kNavigationTitleFont];
        self.navigationController?.navigationBar.titleTextAttributes = titleDic;
        
        // clear background for NavigationBar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "NavigationBar"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        if (self.navigationController?.respondsToSelector(Selector("interactivePopGestureRecognizer")) != nil) {
            self.navigationController?.interactivePopGestureRecognizer.enabled = false;
        }
        
        // Set background color for view
        let backgroundImageView:UIImageView = UIImageView(frame: self.view.frame)
        backgroundImageView.image = UIImage(named: "Background");
        self.view.insertSubview(backgroundImageView, atIndex: 0);
        
        // Set title of Back button to empty
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        
        // Set navigationbaritem color
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Set navigationbaritem font
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: kNavigationItemBarTitleFont], forState: UIControlState.Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "dismissCurrentKeyboard")
        for subView in self.view.subviews {
            if(subView.isKindOfClass(UIScrollView) && !subView.isKindOfClass(UITableView)){
                subView.addGestureRecognizer(tapRecognizer)
                self.currentScrollView = subView as? UIScrollView
            }
            if(subView.isKindOfClass(KNCreditCardView)){
                self.view.addGestureRecognizer(tapRecognizer)
                self.creditCardView = subView as? KNCreditCardView
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func dismissCurrentKeyboard(){
        if(self.currentScrollView != nil){
            for textField in self.currentScrollView!.subviews{
                if(textField.isKindOfClass(KNTextField) && (textField as KNTextField).isFirstResponder() && (textField as KNTextField).userInteractionEnabled == true){
                    (textField as KNTextField).resignFirstResponder()
                }
            }
        }
        
        if(self.creditCardView != nil){
            for textField in self.creditCardView!.subviews{
                if(textField.isKindOfClass(KNTextField) && (textField as KNTextField).isFirstResponder() && (textField as KNTextField).userInteractionEnabled == true){
                    (textField as KNTextField).resignFirstResponder()
                }
            }
        }
    }
    
    // UIViewControllerAnimatedTransitioning
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
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
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval
    {
        return kPushAndPopAnimationDuration
    }
    
    // UIViewControllerTransitioningDelegate
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return self
    }
    
}
