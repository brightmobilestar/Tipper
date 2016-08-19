//
//  KNStandardAlertController.swift
//  Tipper
//
//  Created by Jianying Shi on 1/9/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation
import UIKit

// The Main Class
class KNStandardAlertController: UIViewController {
    let kDefaultShadowOpacity: CGFloat = 0.5
    let kWindowWidth: CGFloat = 260
    var kTextHeight: CGFloat = 90.0
    
    let kAlertBackgroundColor = UIColor(white: 1, alpha: 1)
    
    // Font
    let kDefaultFont = "HelveticaNeue"
    let kButtonFont = "HelveticaNeue-Medium"
    
    // Members declaration
    var labelTitle = UILabel()
    var viewText = UILabel()
    var shadowView = UIView()
    var contentView = UIView()

    var backgroundTopView = UIToolbar()
    
    var rootViewController:UIViewController!
    var durationTimer: NSTimer!
    private var inputs = [UITextField]()
    private var buttons = [KNButton]()
    private var backgroundButtons = [UIToolbar]()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    required override init() {
        super.init()
        // Add Subvies
        view.addSubview(contentView)
        view.backgroundColor = UIColor.clearColor()

        backgroundTopView.backgroundColor = kAlertBackgroundColor
        contentView.addSubview(backgroundTopView)
        
        contentView.addSubview(labelTitle)
        contentView.addSubview(viewText)
        // Content View
        contentView.backgroundColor = UIColor(white: 1, alpha: 0.1)
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 0.5
        
        
        // Title
        labelTitle.numberOfLines = 1
        labelTitle.textAlignment = .Center
        labelTitle.font = UIFont(name: kDefaultFont, size: 20)
        labelTitle.backgroundColor = UIColor.clearColor()
        // View text
        viewText.textAlignment = .Center
        viewText.font = UIFont(name: kDefaultFont, size: 14)
        viewText.backgroundColor = UIColor.clearColor()
        viewText.numberOfLines = 0
        
        // Shadow View
        shadowView = UIView(frame:UIScreen.mainScreen().bounds)
        shadowView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        shadowView.backgroundColor = UIColor.blackColor()
        
        labelTitle.textColor = UIColorFromRGB(0x121212)
        viewText.textColor = UIColorFromRGB(0x121212)
        contentView.layer.borderColor = UIColorFromRGB(0xCCCCCC).CGColor
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var sz = UIScreen.mainScreen().bounds.size
        let sver = UIDevice.currentDevice().systemVersion as NSString
        let ver = sver.floatValue
        if ver < 8.0 {
            // iOS versions before 7.0 did not switch the width and height on device roration
            if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
                let ssz = sz
                sz = CGSize(width:ssz.height, height:ssz.width)
            }
        }
        // Set background frame
        shadowView.frame.size = sz
        // Set frames
        
        var y : CGFloat = 15.0
        if  labelTitle.text?.length > 0 {
            labelTitle.frame = CGRect(x:12, y:y, width: kWindowWidth - 24, height:40)
            y += 40 + 15;
        }
        else{
            labelTitle.frame = CGRectZero
        }
        
        viewText.frame = CGRect(x:12, y:y, width: kWindowWidth - 24, height:kTextHeight)
        // Text fiels
        y = y + kTextHeight + 15.0
        
        for txt in inputs {
            txt.frame = CGRect(x:12, y:y, width:kWindowWidth - 24, height:30)
            txt.layer.cornerRadius = 3
            y += 40
        }
        
        
        var topOfButton : CGFloat  = y;
        // Buttons
        
        if ( buttons.count == 2){
            buttons[0].frame = CGRect(x:12, y:y, width:kWindowWidth/2-24, height:45)
            buttons[0].layer.cornerRadius = 3
            backgroundButtons[0].frame = CGRectMake(0, y+0.5, kWindowWidth/2-0.5, 45)
            
            buttons[1].frame = CGRect(x:kWindowWidth/2+12, y:y, width:kWindowWidth/2-24, height:45)
            buttons[1].layer.cornerRadius = 3
            backgroundButtons[1].frame = CGRectMake(kWindowWidth/2, y+0.5, kWindowWidth/2, 45)
            y += 45.0
            
        }
        else {
            var i : Int = 0;
            for btn in buttons {
                btn.frame = CGRect(x:12, y:y, width:kWindowWidth - 24, height:45)
                btn.layer.cornerRadius = 3

                backgroundButtons[i].frame = CGRectMake(0, y+0.5, kWindowWidth, 45)
                y += 45.0
                i = i + 1
            }
        }
        
        
        var r:CGRect
        if view.superview != nil {
            // View is showing, position at center of screen
            r = CGRect(x:(sz.width-kWindowWidth)/2, y:(sz.height-y)/2, width: kWindowWidth, height: y)
        } else {
            // View is not visible, position outside screen bounds
            r = CGRect(x:(sz.width-kWindowWidth)/2, y:-y, width: kWindowWidth, height: y)
        }
        view.frame = r

        contentView.frame = CGRect(x: 0, y: 0, width: kWindowWidth, height: y)
        backgroundTopView.frame = CGRectMake(0, 0, kWindowWidth, topOfButton)
    }
    
    func addTextField(title:String?=nil)->UITextField {
        // Update view height
        // Add text field
        let txt = UITextField()
        txt.borderStyle = UITextBorderStyle.RoundedRect
        txt.font = UIFont(name:kDefaultFont, size: 14)
        txt.autocapitalizationType = UITextAutocapitalizationType.Words
        txt.clearButtonMode = UITextFieldViewMode.WhileEditing
        txt.layer.masksToBounds = true
        txt.layer.borderWidth = 1.0
        if title != nil {
            txt.placeholder = title!
        }
        contentView.addSubview(txt)
        inputs.append(txt)
        return txt
    }
    
    func addButton(title:String, action:()->Void  )->KNButton {
        let btn = addButton(title)
        btn.actionType = KNActionType.Closure
        btn.action = action
        return btn
    }
    
    func addButton(title:String, target:AnyObject, selector:Selector)->KNButton {
        let btn = addButton(title)
        btn.actionType = KNActionType.Selector
        btn.target = target
        btn.selector = selector
        
        return btn
    }
    
    func addButton(title:String)->KNButton {
        // Update view height
        // Add button
        let btn = KNButton()
        btn.layer.masksToBounds = true
        btn.setTitle(title, forState: .Normal)
        btn.titleLabel?.font = UIFont(name:kButtonFont, size: 16)
        contentView.addSubview(btn)
        buttons.append(btn)
        
        let backView = UIToolbar()
        backView.backgroundColor = kAlertBackgroundColor
        contentView.insertSubview(backView, atIndex: 0)
        backgroundButtons.append(backView)
        btn.addTarget(self, action:Selector("buttonTapped:"), forControlEvents:.TouchUpInside)
        return btn
    }
    
    func buttonTapped(btn:KNButton) {
        if btn.actionType == KNActionType.Closure {
            btn.action()
        }
        if btn.actionType == KNActionType.Selector {
            let ctrl = UIControl()
            ctrl.sendAction(btn.selector, to:btn.target, forEvent:nil)
        }
        hideView()
    }
    
    func showAlert(vc:UIViewController, title:String, message:String, closeButtonTitle:String?="" ){
        self.setTitle(title)
        self.setSubTitle(message)
        if ( closeButtonTitle?.length > 0 ){
            self.addButton(closeButtonTitle!)
        }
        self.showOnViewController(vc)
    }
    
    // showTitle(view, title, subTitle, duration, style)
    func showOnViewController(vc:UIViewController) {
        view.alpha = 0
        rootViewController = vc
        // Add subviews
        rootViewController.addChildViewController(self)
        shadowView.frame = vc.view.bounds
        rootViewController.view.addSubview(shadowView)
        rootViewController.view.addSubview(view)
        
        // Subtitle
        if self.viewText.text?.length > 0 {
            // Adjust text view size, if necessary
            let str : NSString = self.viewText.text!
            let attr = [NSFontAttributeName:viewText.font]
            let sz : CGSize = CGSize(width: kWindowWidth - 24, height:90)
            let r = str.boundingRectWithSize(sz, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:attr, context:nil)
            let ht = ceil(r.size.height) + 10
            if ht < kTextHeight {
                kTextHeight = ht
            }
        }
        
        if ( buttons.count == 0 ){
            // Done button
            let txt = "OK"
            addButton(txt, target:self, selector:Selector("hideView"))
        }
        
        let viewColor = UIColor.grayColor()
        
        for txt in inputs {
            txt.layer.borderColor = viewColor.CGColor
        }
        
        for btn in buttons {
            btn.setTitleColor( UIColorFromRGB(0x007AFF) , forState: .Normal)
        }
        
        self.showView()
    }
    
    func setTitle(title: String) {
        labelTitle.text = title
    }
    
    func setSubTitle(subTitle: String) {
        viewText.text = subTitle
    }
    
    func showView(){
        
        self.view.frame.origin.y = self.rootViewController.view.center.y - 100
        self.shadowView.alpha = 0;
        self.view.transform = CGAffineTransformMakeScale(1.2, 1.2)
        // Animate in the alert view
        UIView.animateWithDuration(0.2, animations: {
            self.shadowView.alpha = self.kDefaultShadowOpacity
            //self.view.frame.origin.y = self.rootViewController.view.center.y - 100
            self.view.alpha = 1
            self.view.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: { finished in
                UIView.animateWithDuration(0.2, animations: {
                    self.view.center = self.rootViewController.view.center
                })
        })
    }
    
    // Close KNAlertView
    func hideView() {
        UIView.animateWithDuration(0.2, animations: {
            self.shadowView.alpha = 0
            self.view.alpha = 0
            }, completion: { finished in
                self.shadowView.removeFromSuperview()
                self.view.removeFromSuperview()
        })
    }
    
    // Helper function to convert from RGB to UIColor
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

