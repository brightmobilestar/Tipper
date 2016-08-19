//
//  KNRootViewController.swift
//  KNSWTemplate
//
//  Created by Peter van de Put on 24/10/14.
//  Copyright (c) 2014 Knodeit LLC. All rights reserved.
//

import UIKit
import Foundation

class KNRootViewController: UIViewController  {
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //if we have configured to use a tutorial, than run it only once
        if(kUseTutorial){
            let userDefaults = NSUserDefaults.standardUserDefaults()
            if !userDefaults.boolForKey(kTutorialAlreadyShown) {
                userDefaults.synchronize()
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool)
    {

    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
     
}