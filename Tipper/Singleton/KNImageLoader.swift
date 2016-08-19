//
//  KNImageLoader.swift
//  Tipper
//
//  Created by Jianying Shi on 1/14/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation


class KNImageLoader: NSObject {
    
    private var memoryImageView: UIImageView = UIImageView();
    
    class var sharedInstance : KNImageLoader {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNImageLoader? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNImageLoader()
        }
        return Static.instance!
    }
    
    override init() {
        
    }
    
    func loadImageFromURL(URL: NSURL, placeholder: UIImage?, failure fail : ((NSError?) -> ())?, success succeed : ((UIImage) -> ())?, imageSize : CGSize = CGSizeZero ){
        if placeholder != nil {
            var sizePlaceholder : CGSize  = placeholder!.size
            memoryImageView = UIImageView(frame: CGRectMake(0, 0, sizePlaceholder.width, sizePlaceholder.height))
        }
        else{
            assert( imageSize.width != 0 && imageSize.height != 0 , "image size is zero")
            memoryImageView = UIImageView(frame: CGRectMake(0, 0, imageSize.width, imageSize.height))
        }
        
        memoryImageView.loadImageFromURL(URL, placeholder: placeholder, format: nil, failure: fail, success: succeed)
    }
}