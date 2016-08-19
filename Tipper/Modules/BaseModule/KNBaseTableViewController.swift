//
//  KNBaseTableViewController.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/18/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

class KNBaseTableViewController: UITableViewController {

    let appDelegate:KNAppDelegate = UIApplication.sharedApplication().delegate as KNAppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set font and style for navigation item title
        let titleDic:NSDictionary = [NSForegroundColorAttributeName:kNavigationTitleTintColor, NSFontAttributeName: kNavigationTitleFont];
        self.navigationController?.navigationBar.titleTextAttributes = titleDic;
        
        // clear background for NavigationBar
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "NavigationBar"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.translucent = true
        
        // Set background color for view
        let backgroundImageView:UIImageView = UIImageView(frame: self.view.frame)
        backgroundImageView.image = UIImage(named: "Background");
        self.view.insertSubview(backgroundImageView, atIndex: 0);
        
        // Set title of Back button to empty
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        
        // Set navigationbaritem color
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Set navigationbaritem font
        let barButton = UIBarButtonItem.appearance()
        barButton.setTitleTextAttributes([NSFontAttributeName: kNavigationItemBarTitleFont], forState: UIControlState.Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
