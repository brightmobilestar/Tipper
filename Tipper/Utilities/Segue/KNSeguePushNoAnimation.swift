//
//  KNSeguePushNoAnimation.swift
//  Tipper
//
//  Created by Jay N. on 12/31/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import Foundation

class KNSeguePushNoAnimation: UIStoryboardSegue {
    override func perform() {
        var transition:CATransition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        
        var sourceViewController = self.sourceViewController as UIViewController
        var destinationViewController = self.destinationViewController as UIViewController
        sourceViewController.navigationController?.pushViewController(destinationViewController, animated: false)
        sourceViewController.navigationController?.view.layer.addAnimation(transition, forKey: kCATransition)
    }
}