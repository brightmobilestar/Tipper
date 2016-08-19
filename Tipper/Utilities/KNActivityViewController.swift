//
//  KNActivityViewController.swift
//  Tipper
//
//  Created by Gregory Walters on 1/9/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit

protocol KNActivityViewControllerDelegate
{
    func okButtonPressed()
}

class KNActivityViewController: UIViewController
{
    @IBOutlet var label: UILabel!
    @IBOutlet var spinningImageView: UIImageView!
    @IBOutlet var okButton: UIButton!
    
    // fix # 70 start
    
    var shouldStopSpinning = false
    var delegate: KNActivityViewControllerDelegate!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.runSpinAnimationOnView(self.spinningImageView)
        self.okButton.layer.cornerRadius = 5
        self.okButton.layer.borderWidth = 2
        self.okButton.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        self.stopView()
    }
    
    func spinView()
    {
        self.shouldStopSpinning = false
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveLinear | UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
            self.spinningImageView.transform = CGAffineTransformRotate(self.spinningImageView.transform, CGFloat(M_PI_2))
            
        }) { (finished) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if self.shouldStopSpinning == false
                {
                    self.spinView()
                }
                
            })
            
        }
    }
    
    func stopView()
    {
        self.shouldStopSpinning = true
        self.spinningImageView.layer.removeAllAnimations()
        self.spinningImageView.transform = CGAffineTransformIdentity
    }
    
    // fix # 70 end
    
    func runSpinAnimationOnView(view: UIView)
    {
        var rotationAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(double: M_PI_4)
        rotationAnimation.duration = 0.20
        rotationAnimation.cumulative = true
        rotationAnimation.repeatCount = 1000000000.0
        view.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
        
    }
    
    @IBAction func okButtonTouchUpInside(sender: UIButton)
    {
        self.delegate.okButtonPressed()
    }

}
