//
//  KNSearchViewController.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/18/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

class KNSearchViewController: KNBaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, KNTextFieldDelegate {
   
    @IBOutlet weak var searchTextField: KNTextField?
    @IBOutlet weak var userCollectionView: UICollectionView?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField?.addImageForLeftOrRightViewWithImage(leftImage: "SearchIcon", rightImage: "")
        searchTextField?.addButtonForRightView(titleText: "Close", imageName: "")
        searchTextField?.knDelegate = self
        
        let appDelegate:KNAppDelegate = UIApplication.sharedApplication().delegate as KNAppDelegate
        appDelegate.unwindSegueForTipperModule = "segueUnwindToSearch"
    }
    
    override func viewDidAppear(animated: Bool) {
        searchTextField?.becomeFirstResponder()
    }
    
    // MARK: UICollectionView Delegate & DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numOfCell = Int(arc4random_uniform(20))
        return numOfCell
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("usercell", forIndexPath: indexPath) as KNMainUserCollectionViewCell
        cell.nameLabel.text = "Username"
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("SearchToProfile", sender: self)
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
    }
    
    // MARK: UITextField Delegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        println("textField text \(textField.text)")
        userCollectionView?.reloadData()
        return true
    }
    
    // MARK: KNTextField Delegate
    func didTouchRightButton(sender: AnyObject?) {
        // Back to Main view
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    @IBAction func unwindToSearchViewController(unwindSegue:UIStoryboardSegue){
        
    }
}
