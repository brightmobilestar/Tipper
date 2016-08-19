//
//  KNImageView.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 12/10/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

class KNImageView: UIImageView {

    var activityView:UIActivityIndicatorView?
    var activityIndicatorStyle:UIActivityIndicatorViewStyle?
    
    func setActivityIndicatorStyle(style:UIActivityIndicatorViewStyle)
    {
        self.activityView?.removeFromSuperview()
        self.activityView = nil;
        self.activityIndicatorStyle = style;
    }
    
    override func awakeFromNib(){
        super.awakeFromNib()
        self.setup()
    }

    func setup(){
        self.activityIndicatorStyle = UIActivityIndicatorViewStyle.Gray
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
    
    func loadImageWithShowingActivityFromURL(URL:NSURL, placeholder:UIImage? = nil){
        self.showActivityView()
        self.loadImageFromURL(URL,
            placeholder: placeholder,
            format: nil,
            failure: { (error: NSError?) -> () in
                self.removeActivityView()
            },
            success: { (resultImage:UIImage) -> () in
                self.image = resultImage
                self.removeActivityView()
            }
        )
    }
}
