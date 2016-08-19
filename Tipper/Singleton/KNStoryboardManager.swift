//
//  KNStoryboardManager.swift
//  Tipper
//
//  Created by Peter van de Put on 24/10/14.
//  Copyright (c) 2014 Knodeit LLC. All rights reserved.
//

import Foundation
import UIKit


class KNStoryboardManager: NSObject {
    
    class var sharedInstance : KNStoryboardManager {
    struct Static {
        static var onceToken : dispatch_once_t = 0
        static var instance : KNStoryboardManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNStoryboardManager()
        }
        return Static.instance!
    }
    
    override init() {
        
    }
    
    func getViewControllerWithIdentifierFromStoryboard(viewControllerIdentifier: String,storyboardName:String) ->UIViewController{
        let stb = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = stb.instantiateViewControllerWithIdentifier(viewControllerIdentifier) as UIViewController
        return vc
    }
    
    func getViewControllerInitial(storyboardName:String) ->UIViewController {
        let mainView: UIStoryboard! = UIStoryboard(name:storyboardName, bundle: nil)
        let viewcontroller : UIViewController = mainView.instantiateInitialViewController() as UIViewController
        return viewcontroller
    }
}


 