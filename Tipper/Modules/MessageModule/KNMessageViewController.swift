//
//  KNMessageViewController.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/28/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

@objc protocol KNMessageViewControllerDelegate {
    @objc optional func didFinishLoadingView(success: Bool, storyboardName: String?, viewControllerName: String?)
}

class KNMessageViewController: KNBaseViewController, KNMessageViewControllerDelegate {
    
    //MARK: IBOutlets
    @IBOutlet weak var imgvIcon: UIImageView?
    @IBOutlet weak var lbDescription: UILabel?
    
    //MARK: Variable
    var imageName:String = ""
    var actionDescription:String = ""
    var rotate:CGFloat = 0
    var rotateTimer: NSTimer = NSTimer()
    var knDelegate:KNMessageViewControllerDelegate?
    var storyboardName:String = ""
    var viewControllerName:String = ""
    var shouldPush: Bool = true
    
    
    //MARK: Life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.knDelegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.imgvIcon!.image = UIImage(named:"OvalIcon")
        self.lbDescription!.text = self.actionDescription
        
        self.startSpinningView(self.imgvIcon!)
        ///rotateTimer = NSTimer.scheduledTimerWithTimeInterval(0.125, target: self, selector: Selector("rotateImage"), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func stopSpinningView(view: UIView)
    {
        view.layer.removeAllAnimations()
        view.transform = CGAffineTransformIdentity
    }
    
    func startSpinningView(view: UIView)
    {
        var rotationAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(double: M_PI_4)
        rotationAnimation.duration = 0.20
        rotationAnimation.cumulative = true
        rotationAnimation.repeatCount = 1000000000.0
        view.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
    }
    
    //MARK: Private function
    func rotateImage()
    {
        rotate += 11.25
        self.imgvIcon!.transform = CGAffineTransformMakeRotation((rotate * CGFloat(M_PI)) / 360)
    }
    
    func sendingSuccess()
    {
        //rotateTimer.invalidate()
        self.stopSpinningView(self.imgvIcon!)
        self.imgvIcon!.transform = CGAffineTransformMakeRotation((0 * CGFloat(M_PI)) / 360)
        self.imgvIcon!.image = UIImage(named: self.imageName)
        
        let descriptions = self.actionDescription.componentsSeparatedByString("\n")
        if descriptions.count == 2 {
            let attributes:Dictionary = [NSFontAttributeName : UIFont(name: kMediumFontName, size: 18)!]
            let attributesSmall:Dictionary = [NSFontAttributeName : UIFont(name: kMediumFontName, size: 15)!]
            let notification = NSMutableAttributedString(string: descriptions[0] + "\n", attributes: attributes)
            let tryAgain = NSMutableAttributedString(string: descriptions[1], attributes: attributesSmall)
            notification.appendAttributedString(tryAgain)
            
            self.lbDescription!.attributedText = notification
        } else {
            
            self.lbDescription!.text = self.actionDescription
        }
    }
    
    func closeView() {
        KNHelperManager.sharedInstance.setAnimationPushViewController(self, push: false)
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func gotoView() {
        if(self.storyboardName != "" || self.viewControllerName != "") {
            
            var viewcontroller: UIViewController?
            if(self.viewControllerName == "")
            {
                viewcontroller = KNStoryboardManager.sharedInstance.getViewControllerInitial(self.storyboardName)
            }
            else {
                viewcontroller = KNStoryboardManager.sharedInstance.getViewControllerWithIdentifierFromStoryboard(self.viewControllerName, storyboardName: self.storyboardName)
            }
            KNHelperManager.sharedInstance.setAnimationPushViewController(self, push: self.shouldPush)
            self.presentViewController(viewcontroller!, animated: false, completion: nil)
        }
    }
    
    //MARK: Action
    func didFinishLoadingView(success: Bool, storyboardName: String?, viewControllerName: String?) {
        
        if(success) {
            if(storyboardName != nil) {
                self.storyboardName = storyboardName!
            }
            if(viewControllerName != nil) {
                self.viewControllerName = viewControllerName!
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let sendingSuccess:Selector = "sendingSuccess"
                NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: sendingSuccess, userInfo: nil, repeats: false)
                let gotoView:Selector = "gotoView"
                NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: gotoView, userInfo: nil, repeats: false)
            })
        }
        else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let sendingSuccess:Selector = "sendingSuccess"
                NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: sendingSuccess, userInfo: nil, repeats: false)
                let closeView:Selector = "closeView"
                NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: closeView, userInfo: nil, repeats: false)
            })
        }
    }

}
