//
//  KNReviewPopupViewController.swift
//  KNSWTemplate
//
//  Created by Gregory Walters on 10/29/14.
//  Copyright (c) 2014 Knodeit LLC. All rights reserved.
//

import UIKit

class KNReviewPopupViewController: KNBaseViewController {
    
    @IBOutlet weak var ofCourseButton: UIButton?
    @IBOutlet weak var maybeButton: UIButton?
    @IBOutlet weak var noThanksButton: UIButton?
    
    required override init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    }
    
    override init() {
        super.init()
        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func yesButtonTap(sender: AnyObject) {
        var url: String = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(kAppstoreAppId)&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8"
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        NSUserDefaults().setBool(true, forKey: kStopAsking)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func maybeButtonTap(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func noButtonTap(sender: AnyObject) {
        NSUserDefaults().setBool(true, forKey: kStopAsking)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
