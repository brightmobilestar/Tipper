//
//  KNPrivacyViewController.swift
//  Tipper
//
//  Created by Gregory Walters on 1/14/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit

class KNCMSPageViewController: KNBaseViewController
{
    
    var pageSlug:String?
    
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.title = NSLocalizedString(pageSlug!, comment: "")
        var cmsPage: KNCMSPage? = KNCMSPageManager.sharedInstance.fetchCMSPage(pageSlug!)
        
        if (cmsPage != nil){
            var basePath:String = NSBundle.mainBundle().bundlePath
            var baseURL:NSURL = NSURL(fileURLWithPath: basePath)!
            if  !cmsPage!.content.isEmpty {
                self.webView.loadHTMLString(cmsPage!.content, baseURL: baseURL)
            }
            else{
                
            }
        }
        

    }
    
    @IBAction func backButtonPres(sender: UIBarButtonItem)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
}


