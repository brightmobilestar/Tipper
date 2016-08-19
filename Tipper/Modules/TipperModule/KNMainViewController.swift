//
//  KNMainViewController.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/18/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit
//KNProfileViewDelegate
class KNMainViewController: KNBaseViewController, KNTextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, KNBaseNavigationControllerPresenter, UIAlertViewDelegate, UICollectionViewDelegateFlowLayout
{
    
    @IBOutlet var showNearbyUsersButton: UIButton!
    @IBOutlet weak var profileImage: UIButton?
    @IBOutlet weak var searchTextField: KNTextField?
    @IBOutlet weak var userCollectionView: UICollectionView?
    @IBOutlet weak var searchView: UIView?
    @IBOutlet weak var labelView: UIView?
    @IBOutlet weak var collectionViewVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var iWantToTipLabel: UILabel?
    
    var searchUsersManager: KNSearchFriendsManager!
    
    var activityViewWrapper: KNActivityViewWrapper!

    var friends:Array<KNFriend>          = Array<KNFriend>()
    var selectedFriend:KNFriend?
    
    var isSearching: Bool = false
    var isSearchingOnline: Bool = false
    
    var searchTimeStamp:NSDate = NSDate()
    var searchTimer:NSTimer?
    var searchedText:String = ""
    
    let TOP_PADDING_SEARCH: CGFloat      = 15.0
    let VERTICAL_PADDING_SEARCH: CGFloat = 10.0
    let TOP_PADDING_MAIN: CGFloat        = 200.0
    let VERTICAL_PADDING_MAIN: CGFloat   = 144.0
    
    let SEARCH_TIME_INTERVAL: Int = 1
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        
        self.showNearbyUsersButton.setTitle(NSLocalizedString("showNearbyUsers", comment: ""), forState: UIControlState.Normal)
        
        self.searchUsersManager = KNSearchFriendsManager.sharedInstance
        
        searchTextField?.addImageForLeftOrRightViewWithImage(leftImage: "SearchIcon", rightImage: "")
        searchTextField?.addButtonForRightView(titleText: NSLocalizedString("close", comment: ""), imageName: "")
        (self.searchTextField?.rightView as UIButton).titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 10.0)
        searchTextField?.knDelegate = self
        
        searchTextField?.rightViewMode = UITextFieldViewMode.Never
        
        let recognizer = UITapGestureRecognizer(target: self, action: "didTouchRightButton:")
        recognizer.delegate = self
        //self.view?.addGestureRecognizer(recognizer)
        
        self.searchTextField?.setDefaultTextField()
        
        // set localize
        self.iWantToTipLabel?.text = NSLocalizedString("iWantToTip", comment: "")
        self.searchTextField?.setDefaultTextFieldWithPlaceHolder(NSLocalizedString("mainSearchBoxPlaceholder", comment: ""))
        
        self.searchTextField?.toolbar?.hidden = true
        
        //Peter we need initialize the
        
        
    }
    
    override func viewDidDisappear(animated: Bool) {
         super.viewDidDisappear(animated)
        if (self.searchTimer != nil){
            self.searchTimer?.invalidate()
            self.searchTimer = nil
        }
    }
   
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        
        loadMyFriends()
        
        //Peter Try asking push notifications here
        KNAccessManager.sharedInstance.requestAccessForPushNotifications()
        
        
        isSearching = false
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        appDelegate.unwindSegueForTipperModule = "segueUnwindToMain"
        //User avatar
        
        
        KNAvatarManager.sharedInstance.getAvatarImage(placeholder: "AddPhoto") { (downloadSuccessful, avatarImage, errorDescription) -> Void in
            if downloadSuccessful {
                self.profileImage!.setBackgroundImage(avatarImage, forState: UIControlState.Normal)
            }
        }
        
        if(appDelegate.askForRating() == true) {
            let viewcontroller : UIViewController = KNStoryboardManager.sharedInstance.getViewControllerWithIdentifierFromStoryboard(kReviewControllerName, storyboardName: kReviewStoryboardName) as UIViewController
            self.presentViewController(viewcontroller, animated: true, completion: nil)
        }
    }
    
 
    func loadMyFriends(){
        self.friends = KNSearchFriendsManager.sharedInstance.search("")!
        self.userCollectionView?.reloadData()
    }
    
    // MARK: UICollectionView Delegate & DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.friends.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("usercell", forIndexPath: indexPath) as KNMainUserCollectionViewCell
        cell.backgroundImageView!.image = nil
        
        let friend = self.friends[indexPath.item] as KNFriend
        
        cell.nameLabel?.text = friend.publicName.formatPublicName()
        
        cell.bookmarkedImageView?.hidden = friend.isFavorite.boolValue == true ? false : true // starred if friend, otherwise no starred
        //cell.bookmarkedImageView?.hidden = friend.isFriend?.boolValue == true ? false : true // starred if friend, otherwise no starred
        
        // set friend avatar image
        let avatarImageView = cell.backgroundImageView
        
        // reset friend avatar image to default image and download again
        
        let placeholder: UIImage =  UIImage(named: "avatarPleaceholderSearch")!
        
        avatarImageView?.image = placeholder
        
        if friend.avatar.length > 0 {
            var avatarURL : NSURL? = NSURL(string:friend.avatar)
            if avatarURL != nil {
                avatarImageView?.loadImageWithShowingActivityFromURL(avatarURL!, placeholder: placeholder)
            }
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //var cell = collectionView.cellForItemAtIndexPath(indexPath) as KNMainUserCollectionViewCell
        //UIView.animateWithDuration(0.05, animations: { () -> Void in
            //cell.backgroundImageView!.alpha = 0.5
        //}) { (Bool) -> Void in
            //cell.backgroundImageView?.alpha = 1
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.selectedFriend = self.friends[indexPath.item] as KNFriend
            self.performSegueWithIdentifier("MainToProfile", sender: self)
            collectionView.deselectItemAtIndexPath(indexPath, animated: false)
            self.searchTextField?.resignFirstResponder()

        })
        //}
    }
    
    // MARK: UITextField Delegate
    func textFieldDidBeginEditing(textField: UITextField) {
        
        // Should show Search page here
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    

    // MARK: UITextField Delegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        
        if self.isSearchingOnline == false
        {
            var searchText:String = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
            if searchText != "" || textField.text != ""
            {
               
                self.searchTextField?.spinLeftImageView()
            }
            self.friends = KNSearchFriendsManager.sharedInstance.search(searchText)!
            self.userCollectionView?.reloadData()
            
            return true
        }
        return false

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        
        if self.isSearchingOnline == false && textField.text != ""
        {
            self.activityViewWrapper.setLabelText(NSLocalizedString("searchingForFriends", comment: ""))
            self.isSearchingOnline = true
            self.activityViewWrapper.addActivityView(animateIn: true, completionHandler: nil)
            KNSearchFriendsManager.sharedInstance.searchFriendsOnline(textField.text, forUser: KNMobileUserManager.sharedInstance.currentUser()!) { (foundResults) -> () in
                
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    
                    
                    self.activityViewWrapper.minimumVisibleDurationCompletionHandler({ () -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.activityViewWrapper.removeActivityView(animateOut: true, completionHandler: { (success) -> Void in
                                self.isSearchingOnline = false
                            })
                            self.friends = foundResults
                            self.userCollectionView?.reloadData()
                            if self.friends.count == 0
                            {
                                if KNHelperManager.sharedInstance.isValidPhoneNumber(textField.text, minLength: 9, maxLength: 11) == true
                                {
                                    var createAccountErrorAlert: UIAlertView = UIAlertView()
                                    createAccountErrorAlert.delegate = self
                                    createAccountErrorAlert.title = NSLocalizedString("accountDoesn'tExist", comment: "")
                                    createAccountErrorAlert.message = NSLocalizedString("stillTipPhone", comment: "")
                                    createAccountErrorAlert.addButtonWithTitle(NSLocalizedString("no", comment: ""))
                                    createAccountErrorAlert.addButtonWithTitle(NSLocalizedString("yes", comment: ""))
                                    createAccountErrorAlert.show()
                                }
                                else if KNHelperManager.sharedInstance.isValidEmail(textField.text) == true
                                {
                                    var createAccountErrorAlert: UIAlertView = UIAlertView()
                                    createAccountErrorAlert.delegate = self
                                    createAccountErrorAlert.title = NSLocalizedString("accountDoesn'tExist", comment: "")
                                    createAccountErrorAlert.message = NSLocalizedString("stillTipEmail", comment: "")
                                    createAccountErrorAlert.addButtonWithTitle(NSLocalizedString("no", comment: ""))
                                    createAccountErrorAlert.addButtonWithTitle(NSLocalizedString("yes", comment: ""))
                                    createAccountErrorAlert.show()
                                }
                            }
                        })
                    })
                    
                })
                
            }
            
            return true
        }
        return false

    }
    
    
    
    // MARK: KNTextField Delegate
    func didTouchRightButton(sender: AnyObject?) {
        if self.searchTextField!.isFirstResponder() {
        
            if self.isSearchingOnline == false
            {
                searchTextField?.text = ""
                searchTextField?.resignFirstResponder()
                self.isSearching = false
                loadMyFriends()
            }
            // Back to Main view

        }
        
    }
    
    // MARK: KNProfileViewDelegate
/*
    func updateFavoriteFriends(favoriteFriends: [Friend]) {
      //TODO  self.favoriteFriends = favoriteFriends
    }
    */
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if  segue.identifier == "MainToProfile" {

            let vc = segue.destinationViewController as KNProfileViewController
            vc.friend = self.selectedFriend
            
            self.didTouchRightButton(nil)
        }
    }
    
    //MARK geo search
    @IBAction func findUsersNearby(sender:UIButton){
        /*
        self.activityViewWrapper.setLabelText(NSLocalizedString("searchingForNearbyUsers", comment: ""))
        //self.isSearchingOnline = true
        self.activityViewWrapper.addActivityView(animateIn: true, completionHandler: nil)
         KNSearchFriendsManager.sharedInstance.getListOfFiendsNearby { (foundResults) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                
                
                self.activityViewWrapper.minimumVisibleDurationCompletionHandler({ () -> Void in
                    self.activityViewWrapper.removeActivityView(animateOut: true, completionHandler: { (success) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                        })
                    })
                    self.friends = foundResults
                    self.userCollectionView?.reloadData()
                })
                
            })
            
        }
        */
        
        //KNAccessManager.sharedInstance.requestAccessForCoreLocationManager()
        var mainStoryboard = UIStoryboard(name: "KNTipper", bundle: nil)
        var nearbyUserViewController = mainStoryboard.instantiateViewControllerWithIdentifier("KNNearbyUserViewController") as KNNearbyUserViewController
        //KNNavigationAnimation.performFadeAnimation(self)
        //self.presentViewController(nearbyUserViewController, animated: false, completion: nil)
        self.navigationController!.pushViewController(nearbyUserViewController, animated: true)
    }
    
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int)
    {
        if buttonIndex == 1
        {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                var storyboard: UIStoryboard = UIStoryboard(name: "KNTipper", bundle: nil)
                var tipAmountViewController: KNAmountViewController = storyboard.instantiateViewControllerWithIdentifier("KNAmountViewController") as KNAmountViewController
                tipAmountViewController.unknownPersonToTip = self.searchTextField!.text
                self.navigationController?.pushViewController(tipAmountViewController, animated: true)
            })
            //println("yessssssssss")
        }
    }
    
    @IBAction func tipAnUnknownPerson(sender:UIButton){
        //catch the email address or mobile number (including country code) and pass to AmountVC since we cant show profile
        
        //set it to property unknownPersonToTip before performing the segue
        
        
    }
    
    // MARK: Event Handling
    @IBAction func profileImageDidTouch(sender: UIButton) {
        
        // Go to Settings page         
        var mainStoryboard: UIStoryboard!
        mainStoryboard = UIStoryboard(name:kSettingStoryboardName, bundle: nil)
        var settingsViewController = mainStoryboard.instantiateViewControllerWithIdentifier("KNSettingsViewController") as KNSettingsViewController
        self.navigationController?.pushViewController(settingsViewController, animated: true)
        //let navcontroller : KNBaseNavigationController = mainView.instantiateInitialViewController() as KNBaseNavigationController
        //navcontroller.previousViewController = self
        //self.preparePushAnimation(presentedViewController: navcontroller)
        //self.presentViewController(navcontroller, animated: true, completion: nil)
        
    }
    
    func dismissNavigationController()
    {
        self.transitionAnimationType = TransitionAnimationType.DismissPop
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func unwindToMainViewController(unwindSegue:UIStoryboardSegue){
    
    }
    
    @IBAction func searchTextFieldEditingChanged(){
        //self.getListOfFriends()
        //searchFriends(self.searchTextField!.text)
    }
    
    func searchViewDidTouch() {
        self.searchTextField?.resignFirstResponder()
       loadMyFriends()
        
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        if (touch.view.isDescendantOfView(self.userCollectionView!)) {
    
            
            if touch.view == self.userCollectionView {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.didTouchRightButton(touch.view)
                })
            }
            return false
        }
        
        if (touch.view.isDescendantOfView(self.searchTextField!)) {
            return false
        }
        
        return true
    }
    
    func checkToSearch(){
    
        var now:NSDate = NSDate()
        let intervalSeconds = NSDate.getBetweenSeconds(self.searchTimeStamp, endDate: now)
        let currentSearchText = self.searchTextField?.text
        if intervalSeconds >= SEARCH_TIME_INTERVAL
        {
            if ( KNHelperManager.sharedInstance.isValidEmail(currentSearchText!) ||
                KNHelperManager.sharedInstance.isValidPhoneNumber(currentSearchText!)
                ){
                //searchFriends(currentSearchText!)
                self.searchTimeStamp = NSDate();
            }
            else{
                self.searchTimeStamp = NSDate();
                //self.getListOfFriends()
                //searchFriends(currentSearchText!)
            }
        }
    }
    
    func keyboardWillShow(notification:NSNotification){
        
        let notificationInfo = notification.userInfo! as Dictionary
        let finalKeyboardFrame = notificationInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        let keyboardAnimationDuration: NSTimeInterval = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as Double
        let keyboardAnimationCurveNumber = notificationInfo[UIKeyboardAnimationCurveUserInfoKey] as UInt
        let animationOptions = UIViewAnimationOptions(keyboardAnimationCurveNumber << 16)
        
        self.searchViewTopConstraint.constant = TOP_PADDING_SEARCH
        self.collectionViewVerticalConstraint.constant = VERTICAL_PADDING_SEARCH
        
        self.loadMyFriends()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.searchTextField!.rightViewMode = UITextFieldViewMode.Always
        })
            
        UIView.animateWithDuration(keyboardAnimationDuration, delay: 0, options: animationOptions, animations: { () -> Void in
            
            // Adjust frame
            self.view.layoutIfNeeded()
            // Adjust alpha
            self.labelView?.alpha = 0.0
            }) { (Bool) -> Void in
                
        }
        
    }
    
    func keyboardWillHide(notification:NSNotification){
        
        
        var info:NSDictionary = notification.userInfo!
        var duration:NSTimeInterval = info.valueForKey(UIKeyboardAnimationDurationUserInfoKey)!.doubleValue
        
        self.searchViewTopConstraint.constant = TOP_PADDING_MAIN
        self.collectionViewVerticalConstraint.constant = VERTICAL_PADDING_MAIN
        
        self.searchTextField!.rightViewMode = UITextFieldViewMode.Never
        UIView.animateWithDuration(duration, animations: { () -> Void in
            
            // Adjust frame
            self.view.layoutIfNeeded()
            // Adjust alpha
            self.labelView?.alpha = 1.0
            }) { (Bool) -> Void in
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification, object: self)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification , object: self)
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return CGSizeMake((self.userCollectionView!.frame.size.width/3.0) - 10.0, (self.userCollectionView!.frame.size.width/3.0) - 10.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return 15.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSizeMake(0.0, 0.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    {
        return CGSizeMake(0.0, 0.0)
    }
    

    

}
