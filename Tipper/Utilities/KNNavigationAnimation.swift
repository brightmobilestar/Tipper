//
//  KNNavigationAnimation.swift
//  Tipper
//
//  Created by Gregory Walters on 1/7/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation

class KNNavigationAnimation
{
    class func performPushAnimation(viewController: UIViewController)
    {
        var transition: CATransition = CATransition()
        transition.duration = 0.35
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        viewController.view.window!.layer.addAnimation(transition, forKey: kCATransition)
    }
    
    class func performPopAnimation(viewController: UIViewController)
    {
        var transition: CATransition = CATransition()
        transition.duration = 0.35
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromLeft
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        viewController.view.window!.layer.addAnimation(transition, forKey: kCATransition)
    }
    
    class func performFadeAnimation(viewController: UIViewController)
    {
        var transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        viewController.view.window!.layer.addAnimation(transition, forKey: kCATransition)
    }
    
    class func performSlowFadeAnimation(viewController: UIViewController)
    {
        var transition: CATransition = CATransition()
        transition.duration = 0.6
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        viewController.view.window!.layer.addAnimation(transition, forKey: kCATransition)
    }
}
