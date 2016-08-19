//
//  KNProfileViewController.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/18/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit


/* obsolete
protocol KNProfileViewDelegate {
    func updateFavoriteFriends(favoriteFriends: [Friend])
}
*/
class KNProfileViewController: KNBaseViewController, KNPasscodeViewControllerDeleagate {
    // MARK: IBOutlets
    @IBOutlet weak var profileImageView: KNImageView?
    @IBOutlet weak var btnTipToFriend: KNLeftImageCenterTextButton?
    @IBOutlet weak var btnAddToFavorite: KNLeftImageCenterTextButton?
    @IBOutlet weak var btnClose: UIButton?
    
    @IBOutlet var newTipButton: UIButton!
    var tipButtonImageView: UIImageView?
    @IBOutlet var newFavoriteButton: UIButton!
    var favoriteButtonImageView: UIImageView?
    var favoriteButtonIsHighlighted = false
    var contactIsFavorited: Bool!
    
    
   //obsolete var delegate:KNProfileViewDelegate?
    var friend:KNFriend?
     
    var activityViewWrapper: KNActivityViewWrapper?
    
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        
        self.tipButtonImageView = UIImageView(frame: CGRectMake(25.0, 25.0, 0.0, 0.0))
        self.tipButtonImageView!.image = UIImage(named: "TipIconWhite")
        self.tipButtonImageView?.contentMode = UIViewContentMode.Center
        self.tipButtonImageView?.clipsToBounds = false
        
        self.newTipButton.setTitle("Tip \(self.friend!.publicName.formatPublicName())", forState: UIControlState.Normal)
        self.newTipButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 50.0, 0.0, 50.0)
        self.newTipButton.addSubview(self.tipButtonImageView!)

        self.newTipButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.newTipButton.setBackgroundImage(self.imageWithColor(kTipButtonBackgroundNormal), forState: UIControlState.Normal)
        self.newTipButton.setTitleColor(kTipButtonForegroundHighlighted, forState: UIControlState.Highlighted)
        self.newTipButton.setBackgroundImage(self.imageWithColor(kTipButtonBackgroundHighlighted), forState: UIControlState.Highlighted)
        
        
        self.favoriteButtonImageView = UIImageView(frame: CGRectMake(25.0, 25.0, 0.0, 0.0))
        self.favoriteButtonImageView!.image = UIImage(named: "BookmarkIconBlack")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.favoriteButtonImageView?.contentMode = UIViewContentMode.Center
        self.favoriteButtonImageView?.clipsToBounds = false
        self.favoriteButtonImageView!.tintColor = UIColor.blackColor()
        
        self.newFavoriteButton.setTitle("Favorite", forState: UIControlState.Normal)
        self.newFavoriteButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        self.newFavoriteButton.setBackgroundImage(self.imageWithColor(kFavoriteButtonBackgroundHighlighted), forState: UIControlState.Highlighted)
        self.newFavoriteButton.addSubview(self.favoriteButtonImageView!)
        

        
        
        

        
        // set title for Tip to Friend button
        //self.btnTipToFriend!.setTitle("Tip \(self.friend!.publicName)", forState: UIControlState.Normal)
        self.btnTipToFriend!.titleLabel!.text = "Tip \(self.friend!.publicName)"
        self.btnTipToFriend!.setBackgroundImage(UIImage.imageWithColor(kTipButtonBackgroundNormal, size: CGSize(width: 1, height: 1)), forState: .Highlighted)
        
        self.btnAddToFavorite!.setBackgroundImage(UIImage.imageWithColor(kTipButtonBackgroundNormal, size: CGSize(width: 1, height: 1)), forState: .Highlighted)
        self.btnAddToFavorite!.setBackgroundImage(UIImage.imageWithColor(kColorDisableButton, size: CGSize(width: 1, height: 1)), forState: .Disabled)
        
        //CHECK if friend is already in your favourite, disable the Add button
        var isFavorite:Bool = friend!.isFavorite.boolValue
        self.contactIsFavorited = isFavorite
        
        if self.contactIsFavorited == true
        {
            self.newFavoriteButton.setBackgroundImage(self.getFavoriteBackgroundImage(false, contactIsFavorited: true), forState: UIControlState.Normal)
            self.newFavoriteButton.setBackgroundImage(self.getFavoriteBackgroundImage(true, contactIsFavorited: true), forState: UIControlState.Highlighted)
            self.newFavoriteButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.newFavoriteButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        }
        else
        {
            self.newFavoriteButton.setBackgroundImage(self.getFavoriteBackgroundImage(false, contactIsFavorited: false), forState: UIControlState.Normal)
            self.newFavoriteButton.setBackgroundImage(self.getFavoriteBackgroundImage(true, contactIsFavorited: false), forState: UIControlState.Highlighted)
            self.newFavoriteButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            self.newFavoriteButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        }
        
        self.newFavoriteButton.setTitle(self.getFavoriteButtonTitle(self.contactIsFavorited), forState: UIControlState.Normal)
        self.favoriteButtonImageView!.image = self.getFavoriteButtonImage(self.favoriteButtonIsHighlighted, contactIsFavorited: self.contactIsFavorited)
        
        
        if self.friend!.avatar.length > 0 {
            let avatarURL = NSURL(string:self.friend!.avatar)!
            var placeholder:UIImage = UIImage(named: kUserPlaceHolderImageName)!
            self.profileImageView!.loadImageWithShowingActivityFromURL(avatarURL, placeholder : placeholder)
        }
        else {
            self.profileImageView!.image = UIImage(named: kUserPlaceHolderImageName)!
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        var isFavorite:Bool = friend!.isFavorite.boolValue
        if (isFavorite == true ){
            self.btnAddToFavorite?.titleLabel?.text = NSLocalizedString("removeFromFavorites", comment: "")
        }
        else{
            self.btnAddToFavorite?.titleLabel?.text = NSLocalizedString("addToFavorites", comment: "")
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.tipButtonImageView!.tintColor = UIColor.whiteColor()
    }
    
    func imageWithColor(color: UIColor) -> UIImage
    {
        let rect: CGRect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    @IBAction func newTipButtonTouchUpInside(sender: UIButton)
    {
        self.tipButtonImageView!.tintColor = UIColor.blackColor()
        
        if !KNMobileUserManager.sharedInstance.hasPinCode(){
            
        // start activity
        self.activityViewWrapper!.addActivityView(animateIn: true, completionHandler: nil)
        self.activityViewWrapper!.setLabelText(NSLocalizedString("Checking Pincode...", comment:""))
        //check to see if we have a pincode set
        KNMobileUserManager.sharedInstance.checkPincode { (success, changed, errors) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                // remove activity view, ensure minimal visible duration
                self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
                    
                    self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                    
                    if (success){
                        //its set
                        
                        if (changed == false ){
                            // should set pin code description, show alert for it.
                            
                            let alertController : KNStandardAlertController = KNStandardAlertController()
                            
                            alertController.setSubTitle(NSLocalizedString("setPinCodeDescription", comment: ""))
                            alertController.addButton(NSLocalizedString("no", comment: ""))
                            alertController.addButton(NSLocalizedString("yes", comment: ""), action: { () -> Void in
                                self.showPasscodeScreen()
                            })
                            alertController.showOnViewController(self)
                        }
                        else{
                            // go to Amount view
                            self.goToAmount()
                        }
                    }
                    else{
                        
                        // show error
                        var errorsString: String = ""
                        for error:KNAPIResponse.APIError in errors!{
                            errorsString += (error.errorMessage + "\n")
                        }
                        let alertController : KNStandardAlertController = KNStandardAlertController()
                        alertController.showAlert(self, title: NSLocalizedString("Error", comment:""), message:errorsString)
                    }
                })
            })
            
        }
        }
        else{
            // go to Amount view
            self.goToAmount()
        }

    }
    
    @IBAction func newTipButtonTouchUpOutside(sender: UIButton)
    {
        self.tipButtonImageView!.tintColor = UIColor.whiteColor()
    }
    
    @IBAction func newTipButtonTouchDown(sender: UIButton)
    {
        self.tipButtonImageView!.tintColor = kTipButtonForegroundHighlighted
    }
    
    @IBAction func newTipButtonTouchCancel(sender: UIButton)
    {
        self.tipButtonImageView!.tintColor = UIColor.whiteColor()
    }

    @IBAction func newTipButtonTouchDragOutside(sender: UIButton)
    {
        self.tipButtonImageView!.tintColor = UIColor.whiteColor()
    }

    @IBAction func newTipButtonTouchDragInside(sender: UIButton)
    {
        self.tipButtonImageView!.tintColor = kTipButtonForegroundHighlighted
    }
    
    
    
    
    
    
    @IBAction func newFavoriteButtonTouchUpInside(sender: UIButton)
    {
        self.contactIsFavorited = !self.contactIsFavorited
        self.favoriteButtonIsHighlighted = false
        self.favoriteButtonImageView!.image = self.getFavoriteButtonImage(self.favoriteButtonIsHighlighted, contactIsFavorited: self.contactIsFavorited)
        self.newFavoriteButton.setTitle(self.getFavoriteButtonTitle(self.contactIsFavorited), forState: UIControlState.Normal)

        if self.contactIsFavorited == true
        {
            self.newFavoriteButton.setBackgroundImage(self.getFavoriteBackgroundImage(false, contactIsFavorited: true), forState: UIControlState.Normal)
            self.newFavoriteButton.setBackgroundImage(self.getFavoriteBackgroundImage(true, contactIsFavorited: true), forState: UIControlState.Highlighted)
            self.newFavoriteButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.newFavoriteButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        }
        else
        {
            self.newFavoriteButton.setBackgroundImage(self.getFavoriteBackgroundImage(false, contactIsFavorited: false), forState: UIControlState.Normal)
            self.newFavoriteButton.setBackgroundImage(self.getFavoriteBackgroundImage(true, contactIsFavorited: false), forState: UIControlState.Highlighted)
            self.newFavoriteButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            self.newFavoriteButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        }
        
        self.friend?.isFavorite = self.contactIsFavorited
        KNCoreDataManager.sharedInstance.saveContext()
         KNFriendManager.sharedInstance.markAsFavorite(friend!, isFavorite: self.contactIsFavorited) { (success) -> () in
            
            if(success)
            {
                
            }
            else
            {

            }
            
        }


    }
    
    @IBAction func newFavoriteButtonTouchDragOutside(sender: UIButton)
    {
        self.favoriteButtonIsHighlighted = false
        self.favoriteButtonImageView!.image = self.getFavoriteButtonImage(self.favoriteButtonIsHighlighted, contactIsFavorited: self.contactIsFavorited)
    }
    
    @IBAction func newFavoriteButtonTouchDown(sender: UIButton)
    {
        self.favoriteButtonIsHighlighted = true
        self.favoriteButtonImageView!.image = self.getFavoriteButtonImage(self.favoriteButtonIsHighlighted, contactIsFavorited: self.contactIsFavorited)
    }
    
    @IBAction func newFavoriteButtonTouchCancel(sender: UIButton)
    {
        self.favoriteButtonIsHighlighted = false
        self.favoriteButtonImageView!.image = self.getFavoriteButtonImage(self.favoriteButtonIsHighlighted, contactIsFavorited: self.contactIsFavorited)
    }
    
    @IBAction func newFavoriteButtonTouchUpOutside(sender: UIButton)
    {
        self.favoriteButtonIsHighlighted = false
        self.favoriteButtonImageView!.image = self.getFavoriteButtonImage(self.favoriteButtonIsHighlighted, contactIsFavorited: self.contactIsFavorited)
    }
    
    func getFavoriteButtonImage(buttonIsHighlighted: Bool, contactIsFavorited: Bool) -> UIImage
    {
        if buttonIsHighlighted == true
        {
            if contactIsFavorited == true
            {
                return UIImage(named: "BookmarkIconWhiteFilled")!
            }
            else
            {
                return UIImage(named: "BookmarkIconBlackFilled")!
            }
        }
        else
        {
            if contactIsFavorited == true
            {
                return UIImage(named: "BookmarkIconWhiteFilled")!
            }
            else
            {
                return UIImage(named: "BookmarkIconBlack")!
            }
        }
    }
    
    func getFavoriteBackgroundImage(buttonIsHighlighted: Bool, contactIsFavorited: Bool) -> UIImage
    {
        if buttonIsHighlighted == true
        {
            if contactIsFavorited == true
            {
                return self.imageWithColor(UIColor(red: 0.35, green: 0.35, blue: 0.35, alpha: 1.0))
            }
            else
            {
                return self.imageWithColor(UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0))
            }
        }
        else
        {
            if contactIsFavorited == true
            {
                return self.imageWithColor(UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0))
            }
            else
            {
                return self.imageWithColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
            }
        }
    }
    
    func getFavoriteForegroundColor(buttonIsHighlighted: Bool, contactIsFavorited: Bool) -> UIColor
    {
        if buttonIsHighlighted == true
        {
            if contactIsFavorited == true
            {
                return UIColor()
            }
            else
            {
                return UIColor()
            }
        }
        else
        {
            if contactIsFavorited == true
            {
                return UIColor()
            }
            else
            {
                return UIColor()
            }
        }
    }
    
    func getFavoriteButtonTitle(contactIsFavorited: Bool) -> String
    {
        if contactIsFavorited == true
        {
            return NSLocalizedString("removeFromFavorites", comment: "")
        }
        else
        {
            return NSLocalizedString("addToFavorites", comment: "")
        }
    }
   
    // MARK: Event Handling
    @IBAction func tipButtonDidTouch(sender: UIButton!) {
        
        
    }
    @IBAction func bookmarkButtonDidTouch(sender: UIButton) {
        
        self.activityViewWrapper!.addActivityView(animateIn: true, completionHandler: nil)
        var currentIsFavorite:Bool = friend!.isFavorite.boolValue
        
        var newIsFavorite:Bool = false
        if (currentIsFavorite == true){
            newIsFavorite = false
        }
        else{
            newIsFavorite = true
        }
    
        //if friend is a temporary friend it will be added as a real friend in this call
        
        KNFriendManager.sharedInstance.markAsFavorite(friend!, isFavorite: newIsFavorite) { (success) -> () in
            
        
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                // remove activity view, ensure minimal visible duration
                self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
                    self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                    
                    //next action based on api status
                    if(success) {
                        //Our call returns updated friend object for which the manageed object context has changed
                        self.friend?.isFavorite = newIsFavorite
                        KNCoreDataManager.sharedInstance.saveContext()
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            
                            if (newIsFavorite == true){
                                self.btnAddToFavorite?.titleLabel?.text = NSLocalizedString("removeFromFavorites", comment: "")
                            }
                            else{
                                self.btnAddToFavorite?.titleLabel?.text = NSLocalizedString("addToFavorites", comment: "")
                            }
                            
                            
                        })
                        var msg : String = ""
                        if (newIsFavorite == true){
                             msg = String(format: NSLocalizedString("addFriendSuccess", comment: ""), self.friend!.publicName)
                        }
                        else{
                             msg = String(format: NSLocalizedString("removeFriendSuccess", comment: ""), self.friend!.publicName)
                        }
                        
                        
                        
                        
                        
                        let alertController : KNStandardAlertController = KNStandardAlertController()
                        
                        alertController.showAlert(self, title: "", message: msg, closeButtonTitle: nil)
                        
                    } else {
                        let alertController : KNStandardAlertController = KNStandardAlertController()
                        
                        alertController.showAlert(self, title:NSLocalizedString("error", comment:""), message: "OEPS    ", closeButtonTitle: nil)
                    }
                })
            })
            
        }
        
    }
    

    @IBAction func closeButtonDidTouch(sender: UIButton) {
        KNHelperManager.sharedInstance.setAnimationFade(self.navigationController?)
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if  segue.identifier == "AmountSegue" {
            //TODO
            let vc = segue.destinationViewController as KNAmountViewController
            vc.friend = self.friend
        }
    }
    
    func showPasscodeScreen() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let goToPasscode: Selector = "goToPasscode"
            NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: goToPasscode, userInfo: nil, repeats: false)
        })
    }
    
    func goToPasscode() {
        let viewcontroller : KNPasscodeViewController = KNStoryboardManager.sharedInstance.getViewControllerWithIdentifierFromStoryboard(kPasscodeStoryboardId, storyboardName: kPasscodeStoryboardName) as KNPasscodeViewController
        viewcontroller.registerPasscode = true
        viewcontroller.checkRegisterPasscodeInProfile = true
        viewcontroller.knPasscodeDelegate = self
        KNHelperManager.sharedInstance.setAnimationPushViewController(self, push: true)
        self.presentViewController(viewcontroller, animated: false, completion: nil)
    }
    
    func didRegisterPasscodeSuccess() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let goToAmount: Selector = "goToAmount"
            NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: goToAmount, userInfo: nil, repeats: false)
        })
    }
    
    func goToAmount() {
        self.performSegueWithIdentifier("AmountSegue", sender: AnyObject?())
    }
  
}
