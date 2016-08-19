//
//  KNBaseNavigationController.swift
//  Tipper
//
//  Created by Gregory Walters on 1/16/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit

protocol KNBaseNavigationControllerPresenter
{
    func dismissNavigationController()
}

class KNBaseNavigationController: UINavigationController
{
    
    var previousViewController: protocol<KNBaseNavigationControllerPresenter>?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
