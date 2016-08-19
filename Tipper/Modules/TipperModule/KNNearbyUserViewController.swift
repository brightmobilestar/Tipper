//
//  KNNearbyUserViewController.swift
//  Tipper
//
//  Created by Gregory Walters on 1/29/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit
import CoreBluetooth


class KNNearbyUserViewController: KNBaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, KNBLEReceiverDelegate, KNBLETransmitterDelegate{
    
    // MARK: UI Outlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var noResultsLabel: UILabel!
    
    // MARK: Variables
    var activityViewWrapper: KNActivityViewWrapper!
 
     var nearbyUsers:Array<KNFriend>          = Array<KNFriend>()
    var firstTime = true

    private var timer: NSTimer?
    
    var arrayUserStringData: Array<String> = Array<String>()
    var arrayUserDictionaryData: [Dictionary<String,String>] = [Dictionary<String,String>] ()
    
    
    
    // MARK: View Events
    override func viewDidLoad(){
        
        super.viewDidLoad()
        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        self.noResultsLabel.text = NSLocalizedString("noNearbyUsers", comment: "")
        
        
        //KNBLEReceiver.sharedInstance
        KNBLEReceiver.sharedInstance.delegate = self
        KNBLEReceiver.sharedInstance.startScanning()
        
    }
    
 
    override func viewWillAppear(animated: Bool){
        
        super.viewWillAppear(animated)
        
        self.navigationController!.setNavigationBarHidden(false, animated: true)
         if self.firstTime == true
        {
            self.activityViewWrapper.setLabelText(NSLocalizedString("searchingForNearbyUsers", comment: ""))
            self.activityViewWrapper.setMinimumVisibleDuration(0.8)
            self.activityViewWrapper.addActivityView(animateIn: false, completionHandler: nil)
             
           
            self.timer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: Selector("timerEnd"), userInfo: nil, repeats: false)
                
            self.activityViewWrapper.minimumVisibleDurationCompletionHandler { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in

                    
                    //  self.activityViewWrapper.removeActivityView(animateOut: true, completionHandler: nil)
                })
            }
           
            self.firstTime = false
            
        }

        else

        {
            self.collectionView.reloadData()
        }

    }
    
    func timerEnd(){
        
          dispatch_async(dispatch_get_main_queue(), {
                self.activityViewWrapper.removeActivityView(animateOut: true, completionHandler: nil)
            self.timer?.invalidate()
            self.timer = nil
        })
        
    }

    
    
    override func viewDidDisappear(animated: Bool) {
        //TODO if you stop scanning and return it fails
        //KNBLEReceiver.sharedInstance.stopScanning()
    }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: Utils
    func dictionaryToString(dict: Dictionary<String, String> ) -> String{
        
        var stringDict : String = ""
        for key in dict{
            stringDict = stringDict + "\(key)" + "-"
        }
        return stringDict
    }
    
    //MARK: KNBLEReceiverDelegate
    func receiver(receiver: KNBLEReceiver, didFailError error: NSError?) {
         println("receiver didFailError  \(error?.description)")
    }
    
    func receiver(receiver: KNBLEReceiver, powerStateChanged on: Bool) {
        if ( on == false ){
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                println("[X] STOP SCANNING")
                KNBLEReceiver.sharedInstance.stopScanning()
            })
            
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
               //
                 println("[X] START SCANNING")
                KNBLEReceiver.sharedInstance.startScanning()
            })
        }
    }
    
    func receiver(receiver: KNBLEReceiver, didFindUserStringData userString: String) {

    }
    
    func receiver(receiver: KNBLEReceiver, didFindUserDictionaryData dictionaryData: Dictionary<String,String>){
        
        if  let friendId:String = dictionaryData["friendId"]{
        
            if !arrayUserStringData.contains(friendId){
                arrayUserStringData.append(friendId);
                KNFriendManager.sharedInstance.discoverFriendProfile(friendId, completed: { (success, foundFriend) -> () in
                    if (success){
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.timer?.invalidate()
                            self.timer = nil
                            
                            
                            self.activityViewWrapper.removeActivityView(animateOut: true, completionHandler: nil)
                            self.nearbyUsers.append(foundFriend!)
                            self.collectionView.reloadData()
                            self.noResultsLabel.hidden = true
                            
                        });
                    }
                    else{
                        
                    }
                })
            }
        }
    }
    
  
    // MARK: UI Actions
    
    @IBAction func backBarButtonTouch(sender: UIBarButtonItem) {
        self.navigationController!.popViewControllerAnimated(true)
    }

    func cellTap(gestureRecognizer: UIGestureRecognizer){
        
       // println("cell tap: \(gestureRecognizer.view!.tag)")
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            if self.navigationController!.visibleViewController == self
            {
                //println("cell segue: \(gestureRecognizer.view!.tag)")
                var tipperStoryboard = UIStoryboard(name: "KNTipper", bundle: nil)
                var profileViewController = tipperStoryboard.instantiateViewControllerWithIdentifier("KNProfileViewController") as KNProfileViewController
                profileViewController.friend = self.nearbyUsers[gestureRecognizer.view!.tag]
                self.navigationController!.pushViewController(profileViewController, animated: false)
                KNNavigationAnimation.performFadeAnimation(self)
            }
            
        })

    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.nearbyUsers.count

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("nearbyusercell", forIndexPath: indexPath) as KNNearbyUserCollectionViewCell
        
        if cell.gestureRecognizers != nil
        {
            for gestureRecognizer in cell.gestureRecognizers!
            {
                cell.removeGestureRecognizer(gestureRecognizer as UIGestureRecognizer)
            }
        }
        
        cell.tag = indexPath.row
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "cellTap:")
        cell.addGestureRecognizer(tapRecognizer)
        
        cell.nameLabel.text = self.nearbyUsers[indexPath.row].publicName.formatPublicName()
        cell.favoriteStatusImageView.hidden = !self.nearbyUsers[indexPath.row].isFavorite.boolValue
        cell.userPhotoImageView.loadImageWithShowingActivityFromURL(NSURL(string: self.nearbyUsers[indexPath.row].avatar)!, placeholder: UIImage(named: "avatarPleaceholderSearch")!)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool{
        
        
        return false
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        
        return CGSizeMake((self.collectionView.frame.size.width/3.0) - 10.0, (self.collectionView.frame.size.width/3.0) - 10.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets{
        
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        
        return 15.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        
        return CGSizeMake(0.0, 15.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize{
        
        return CGSizeMake(0.0, 15.0)
    }
}
