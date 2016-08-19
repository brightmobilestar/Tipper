//
//  KNActivityWrapper.swift
//  Tipper
//
//  Created by Gregory Walters on 1/8/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation

public class KNActivityViewWrapper: NSObject, KNActivityViewControllerDelegate
{
    
    private let parentViewController: UIViewController
    private let activityViewController: KNActivityViewController
    private var timer: NSTimer?
    private var storedCallbacks = Array<(Void) -> Void>()
    
    private var minimumVisibleDuration: Double = 0.5
    private let animationDuration: Double = 0.2
    private var activityViewIsAdded = false
    private var activityViewIsBeingRemoved = false
    private var minimumVisibleDurationElapsed = true
    
    init(parentViewController: UIViewController)
    {
        self.parentViewController = parentViewController
        
        let activityStoryboard = UIStoryboard(name: "KNActivityViewStoryboard", bundle: nil)
        let activityViewController: KNActivityViewController = activityStoryboard.instantiateViewControllerWithIdentifier("KNActivityViewController") as KNActivityViewController
        self.activityViewController = activityViewController
        self.activityViewController.loadView()
        self.activityViewController.label.text = "working..."
        
        super.init()
        
        self.activityViewController.delegate = self
    }
    
    func addActivityView(#animateIn: Bool, completionHandler: ((Bool) -> Void)?)
    {
        
        if NSThread.currentThread().isMainThread == true
        {
            self.privateAddActivityView(animateIn: animateIn, completionHandler: completionHandler)
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), {
                
                self.privateAddActivityView(animateIn: animateIn, completionHandler: completionHandler)
                
            })
        }
        
    }
    
    func minimumVisibleDurationCompletionHandler(completionHandler: (Void) -> Void)
    {
        if NSThread.currentThread().isMainThread == true
        {
            self.privateMinimumVisibleDurationCompletionHandler(completionHandler)
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), {
                
                self.privateMinimumVisibleDurationCompletionHandler(completionHandler)
                
            })
        }
    }
    
    func removeActivityView(#animateOut: Bool, completionHandler: ((Bool) -> Void)?)
    {
        
        if NSThread.currentThread().isMainThread == true
        {
            self.privateRemoveActivityView(animateOut: animateOut, completionHandler: completionHandler)
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), {
                
                self.privateRemoveActivityView(animateOut: animateOut, completionHandler: completionHandler)
                
            })
        }
        
    }
    
    func removeActivityViewSuccess()
    {
        self.activityViewController.stopView()
        self.activityViewController.spinningImageView.image = UIImage(named: "OvalCheck")
        NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: Selector("timerEndRemoveActivityView"), userInfo: nil, repeats: false)
    }
    
    func setLabelText(text: String)
    {
        self.activityViewController.label.text = text
    }
    
    func startSpinning() {
        self.activityViewController.spinView()
    }
    
    func stopSpinning() {
        self.activityViewController.stopView()
    }
    
    func setImage(image: UIImage) {
        self.activityViewController.spinningImageView.image = image
    }
    
    
    
    
    
    
    
    
    func timerEndRemoveActivityView()
    {
        self.removeActivityView(animateOut: true, completionHandler: nil)
    }

    func timerEnd()
    {
        
        if NSThread.currentThread().isMainThread == true
        {
            self.minimumVisibleDurationElapsed = true
            
            for callback in self.storedCallbacks
            {
                callback()
            }
            
            self.storedCallbacks.removeAll(keepCapacity: false)
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), {
                
                self.minimumVisibleDurationElapsed = true
                
                
                for callback in self.storedCallbacks
                {
                    callback()
                }
                
                
                self.storedCallbacks.removeAll(keepCapacity: false)
                
            })
        }
    }
    
    func okButtonPressed()
    {
        self.removeActivityView(animateOut: true, completionHandler: nil)
    }
    
    func setMinimumVisibleDuration(duration: Double)
    {
        self.minimumVisibleDuration = duration
    }
    
    private func privateAddActivityView(#animateIn: Bool, completionHandler: ((Bool) -> Void)?)
    {
        if(self.activityViewIsAdded == false)
        {
            
            self.activityViewIsAdded = true
            
            if animateIn == true
            {
                self.activityViewController.spinningImageView.image = UIImage(named: "OvalIcon")
                self.activityViewController.view.alpha = 0.0
                self.parentViewController.addChildViewController(self.activityViewController)
                self.parentViewController.view.addSubview(self.activityViewController.view)
                
                self.minimumVisibleDurationElapsed = false
                self.timer?.invalidate()
                self.timer = nil
                self.timer = NSTimer.scheduledTimerWithTimeInterval(self.minimumVisibleDuration + self.animationDuration, target: self, selector: Selector("timerEnd"), userInfo: nil, repeats: false)
                
                UIView.animateWithDuration(self.animationDuration, delay: 0, options: nil, animations: { () -> Void in
                    
                    self.activityViewController.view.alpha = 1.0
                    
                    }, completion: { (success: Bool) -> Void in
                        
                        if completionHandler != nil
                        {
                            completionHandler!(true)
                        }
                        
                })
                
            }
            else
            {
                self.activityViewController.view.alpha = 1.0
                self.parentViewController.addChildViewController(self.activityViewController)
                self.parentViewController.view.addSubview(self.activityViewController.view)
                
                self.minimumVisibleDurationElapsed = false
                self.timer?.invalidate()
                self.timer = nil
                self.timer = NSTimer.scheduledTimerWithTimeInterval(self.minimumVisibleDuration, target: self, selector: Selector("timerEnd"), userInfo: nil, repeats: false)
                
                if completionHandler != nil
                {
                    completionHandler!(true)
                }
                
            }
        }
        else
        {
            if completionHandler != nil
            {
                completionHandler!(false)
            }
        }
        
    }
    
    private func privateRemoveActivityView(#animateOut: Bool, completionHandler: ((Bool) -> Void)?)
    {
        
        if self.activityViewIsAdded == true && self.activityViewIsBeingRemoved == false
        {
            
            self.activityViewIsBeingRemoved = true
            
            if animateOut == true
            {
                self.activityViewController.view.alpha = 1.0
                
                UIView.animateWithDuration(self.animationDuration, delay: 0.0, options: nil, animations: { () -> Void in
                    
                    self.activityViewController.view.alpha = 0.0
                    
                    }, completion: { (success: Bool) -> Void in
                        
                        self.activityViewController.view.removeFromSuperview()
                        self.activityViewController.removeFromParentViewController()
                        
                        self.activityViewIsAdded = false
                        self.activityViewIsBeingRemoved = false
                        self.minimumVisibleDurationElapsed = true
                        
                        if(completionHandler != nil)
                        {
                            completionHandler!(true)
                        }
                        
                })
                
            }
            else
            {
                self.activityViewController.view.removeFromSuperview()
                self.activityViewController.removeFromParentViewController()
                
                self.activityViewIsAdded = false
                self.activityViewIsBeingRemoved = false
                self.minimumVisibleDurationElapsed = true
                
                if completionHandler != nil
                {
                    completionHandler!(true)
                }
                
            }
            
        }
        else
        {
            if completionHandler != nil
            {
                completionHandler!(false)
            }
        }
        
    }
    
    private func privateMinimumVisibleDurationCompletionHandler(completionHandler: (Void) -> Void)
    {
        
        if self.minimumVisibleDurationElapsed == true
        {
            completionHandler()
        }
        else
        {
            self.storedCallbacks.append(completionHandler)
        }
        
    }
    
}