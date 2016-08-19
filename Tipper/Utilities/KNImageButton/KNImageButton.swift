//
//  KNImageButton.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 1/7/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit

class KNImageButton: UIButton {

    var activityView:UIActivityIndicatorView?
    var showActivityIndicator:Bool?
    var activityIndicatorStyle:UIActivityIndicatorViewStyle?
    var crossfadeDuration:NSTimeInterval?
    var image:UIImage?
    
    var extendHitbox = false

    func setActivityIndicatorStyle(style:UIActivityIndicatorViewStyle)
    {
        self.activityIndicatorStyle = style;
        self.activityView?.removeFromSuperview()
        self.activityView = nil;

    }
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        self.setup()
    }

    func setup(){
        
        self.showActivityIndicator = true
        self.activityIndicatorStyle = UIActivityIndicatorViewStyle.Gray
        self.crossfadeDuration = 0.0
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        
        if self.extendHitbox == true
        {
            var rect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height + 25)
            return CGRectContainsPoint(rect, point)
        }
        else
        {
            return super.pointInside(point, withEvent: event)
        }
    }
    
    func showActivityView(){
    
        if (self.activityView == nil)
        {
            self.activityView = UIActivityIndicatorView(activityIndicatorStyle: self.activityIndicatorStyle!)
            self.activityView!.hidesWhenStopped = true
            self.activityView!.center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0)
            self.activityView!.autoresizingMask =
                UIViewAutoresizing.FlexibleLeftMargin |
                UIViewAutoresizing.FlexibleTopMargin |
                UIViewAutoresizing.FlexibleRightMargin |
                UIViewAutoresizing.FlexibleBottomMargin
            self.addSubview(self.activityView!)
        }
        
        self.activityView!.startAnimating()
    }
    
    func removeActivityView(){
    
        self.activityView!.stopAnimating()
    }
    
    func setImage(image:UIImage){
    
        var scaleSize:CGSize = CGSizeMake(self.frame.size.height, self.frame.size.width)
        
        if image != self.image {
            
            var rightImage:UIImage? = image
            
            UIGraphicsBeginImageContextWithOptions(scaleSize, false, 0.0)
            rightImage!.drawInRect(CGRectMake(0, 0, scaleSize.width, scaleSize.height))
            var resizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            self.setBackgroundImage(image, forState: UIControlState.Normal)
            self.setBackgroundImage(image, forState: UIControlState.Highlighted)
        }
        
        self.image = image
        if let actView = self.activityView {
            actView.stopAnimating()
        }
    }
}
