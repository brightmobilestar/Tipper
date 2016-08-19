//
//  KNSettingsViewController.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/21/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

class KNSettingsViewController: KNBaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, KNTextFieldDelegate, KNDeleteCCViewDelegate, KNAddCCViewDelegate, KNEditProfileViewControllerDelegate {
    
    @IBOutlet weak var backButton: UIBarButtonItem?
    
    // MARK: - Public properties
    var profileAvatarView:KNProfileAvatarView!
    var activityViewWrapper: KNActivityViewWrapper?
    var creditCards:[TipperCard] = Array<TipperCard>()
    var selectedCard:TipperCard?
    var loggingOutActivityViewWrapper: KNActivityViewWrapper!
    
    // MARK: - IBOutlets
    @IBOutlet weak var settingsTableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)

        self.loggingOutActivityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        self.loggingOutActivityViewWrapper.setLabelText(NSLocalizedString("loggingOut", comment: ""))
        
        // Clear background color of tableview
        
        self.settingsTableView!.backgroundColor = UIColor.clearColor()
        self.title = NSLocalizedString("settings", comment: "")
        
        self.loadCards()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func closeViewPressed(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
        //(self.navigationController as KNBaseNavigationController).previousViewController?.dismissNavigationController()
        
    }
    
    // MARK: - TableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  section == 2 {
            return self.creditCards.count + 1
        }
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    // MAKR: - tableViewDelegate
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 176.0
        }
        return 14.0;
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == KNCellTypeIndex.Logout.rawValue {
            
            return 15.0
        }
        
        return 1.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if  section == 0 {
            return self.getProfileAvatarView()
        }
        return nil
    }
    
    // MAKR: - tableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : KNSettingsTableViewCell? = tableView.dequeueReusableCellWithIdentifier("settingsCell") as? KNSettingsTableViewCell
        
        if(cell == nil) {
            cell = KNSettingsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "settingsCell")
        }
        
        cell!.backgroundColor = UIColor.clearColor()
        cell!.cellTextField.userInteractionEnabled = false
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        
        let cellTypeIndex:KNCellTypeIndex = KNCellTypeIndex(rawValue: indexPath.section)!
        switch cellTypeIndex{
            
        case KNCellTypeIndex.EditProfile:
            
            cell!.cellTextField.text = NSLocalizedString("editProfile", comment: "")
            dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
                cell!.cellTextField.addImageForLeftOrRightViewWithImage(leftImage: "ProfileIcon", rightImage: "Accessory") // call your method.
            }
            
        case KNCellTypeIndex.Passcode:
            
            cell!.cellTextField.text = NSLocalizedString("passcode", comment: "")
            dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
                cell!.cellTextField.addImageForLeftOrRightViewWithImage(leftImage: "PasscodeIcon", rightImage: "")
            }
            
        case KNCellTypeIndex.CreditCard:
            
            if indexPath.row == self.creditCards.count {
                cell!.cellTextField.text = NSLocalizedString("addCard", comment: "")
                dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
                    cell!.cellTextField.addImageForLeftOrRightViewWithImage(leftImage: "TextFieldPlaceHolderIcon", rightImage: "Accessory")
                }
            } else {
                
                cell!.cellTextField.text = "\(self.creditCards[indexPath.row].brand) \(self.creditCards[indexPath.row].last4)"
                cell!.cellTextField.tag = indexPath.row
                cell!.cellTextField.knDelegate = self
                cell!.cellTextField.delegate = self
                cell!.cellTextField.userInteractionEnabled = true
                dispatch_after(0, dispatch_get_main_queue()) { () -> Void in

                    cell!.cellTextField.addButtonForLeftView(titleText: "", imageName: "CreditCard")
                    cell!.cellTextField.addButtonForRightView(titleText: "", imageName: "DeleteIcon")
                }
            }
            
        case KNCellTypeIndex.BalanceAndHistory:
            cell!.cellTextField.text = NSLocalizedString("balanceAndHistory", comment: "")
            dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
                cell!.cellTextField.addImageForLeftOrRightViewWithImage(leftImage: "HistoryIcon", rightImage: "Accessory")
            }

            //
            
        case KNCellTypeIndex.Terms:
            
            cell!.cellTextField.text = NSLocalizedString("terms", comment: "")
            dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
                cell!.cellTextField.addImageForLeftOrRightViewWithImage(leftImage: "TermsIcon", rightImage: "")
            }
            
        case KNCellTypeIndex.Faq:
            
            cell!.cellTextField.text = NSLocalizedString("faq", comment: "")
            dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
               cell!.cellTextField.addImageForLeftOrRightViewWithImage(leftImage: "PrivacyIcon", rightImage: "")
            }
            
        default:
            cell!.cellTextField.text = NSLocalizedString("logout", comment: "")
            dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
                cell!.cellTextField.addImageForLeftOrRightViewWithImage(leftImage: "LogoutIcon", rightImage: "")
            }
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cellTypeIndex:KNCellTypeIndex = KNCellTypeIndex(rawValue: indexPath.section)!
        switch cellTypeIndex{
            
        case KNCellTypeIndex.EditProfile:
            
            let viewcontroller : UIViewController = KNStoryboardManager.sharedInstance.getViewControllerWithIdentifierFromStoryboard(kEditProfileStoryboardId, storyboardName: kProfileStoryboardName)
            (viewcontroller as KNEditProfileViewController).knDelegate = self
            self.navigationController?.pushViewController(viewcontroller, animated: true)
            
            break
            
        case KNCellTypeIndex.Passcode:
            
            let viewcontroller : KNPasscodeViewController = KNStoryboardManager.sharedInstance.getViewControllerWithIdentifierFromStoryboard(kPasscodeStoryboardId, storyboardName: kPasscodeStoryboardName) as KNPasscodeViewController
            viewcontroller.registerPasscode = true
            

            
            dispatch_after(0, dispatch_get_main_queue(), { () -> Void in
                KNNavigationAnimation.performFadeAnimation(self)
                self.presentViewController(viewcontroller, animated: false, completion: nil)
            })

           
            break
            
        case KNCellTypeIndex.CreditCard:
            
            if indexPath.row == self.creditCards.count {
                
                let vc:KNAddCCViewController = KNStoryboardManager.sharedInstance.getViewControllerWithIdentifierFromStoryboard(kAddCardViewControllerId, storyboardName: kCardManagementStoryboardName) as KNAddCCViewController
                vc.delegate = self
                
                self.navigationController!.pushViewController(vc, animated: true)
                
            }
            
            break
        case KNCellTypeIndex.BalanceAndHistory:
            self.performSegueWithIdentifier("SettingHistoryView", sender: self)
           /*
        case KNCellTypeIndex.Balance:
            
            let vc:KNWithdrawViewController = KNStoryboardManager.sharedInstance.getViewControllerWithIdentifierFromStoryboard(kWithdrawBalanceViewControllerId, storyboardName: kCardManagementStoryboardName) as KNWithdrawViewController
            
            self.navigationController!.pushViewController(vc, animated: true)
            */
            
            
        case KNCellTypeIndex.Terms:
            self.performSegueWithIdentifier("Terms", sender: self)
                
        case KNCellTypeIndex.Faq:
            self.performSegueWithIdentifier("Faq", sender: self)
            
        default:
            
            self.loggingOutActivityViewWrapper.addActivityView(animateIn: true, completionHandler: nil)
            
            KNLoginManager.sharedInstance.logoutUser({ (success) -> () in
                
                self.loggingOutActivityViewWrapper.minimumVisibleDurationCompletionHandler({ () -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.backSplashScreen()
                    })
                    
                })

            })
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  
        if  segue.identifier == "Faq" {
            let vc = segue.destinationViewController as KNCMSPageViewController
            vc.pageSlug = "faq"
        }

          else if  segue.identifier == "Terms" {
            let vc = segue.destinationViewController as KNCMSPageViewController
            vc.pageSlug = "termsAndPrivacy"
        }
    }
    
    
    
    
    // MARK: - Private methods
    func backSplashScreen() {
    
        let viewcontroller : UIViewController = KNStoryboardManager.sharedInstance.getViewControllerWithIdentifierFromStoryboard("KNSplashViewController", storyboardName: "Main") as UIViewController
        self.preparePopAnimation(presentedViewController: viewcontroller)
        self.presentViewController(viewcontroller, animated: true, completion: nil)
        
    }

    func getProfileAvatarView() -> UIView{
        
        let topProfileAvatarOffset:CGFloat = 31.0
        var containerView:UIView = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(self.settingsTableView!.frame), self.tableView(self.settingsTableView!, heightForHeaderInSection: 0)))
        
        if (self.profileAvatarView == nil) {
            
            var nibArray:Array = NSBundle.mainBundle().loadNibNamed("KNProfileAvatarView", owner: self, options: nil)
            
            self.profileAvatarView = nibArray[0] as KNProfileAvatarView
            self.profileAvatarView.frame = CGRectMake(0, topProfileAvatarOffset, CGRectGetWidth(self.settingsTableView!.frame), CGRectGetHeight(self.profileAvatarView.frame))
            
            self.profileAvatarView.profileFullNameButton!.userInteractionEnabled = false
            //self.profileAvatarView.setText(appDelegate.loggedUser!.publicName!)
            self.profileAvatarView.setText(KNMobileUserManager.sharedInstance.currentUser()!.publicName.formatPublicName())
            


            // get profile avatar image
            if  !KNMobileUserManager.sharedInstance.currentUser()!.avatar.isEmpty{
                self.profileAvatarView!.profileAvatarImageButton!.showActivityView()
                KNAvatarManager.sharedInstance.getAvatarImage(placeholder: "AddPhoto") { (downloadSuccessful, avatarImage, errorDescription) -> Void in
                    self.profileAvatarView!.profileAvatarImageButton!.setImage(avatarImage!)
                }
            }
            
           
            

        }
        
        self.profileAvatarView.userInteractionEnabled = false
        
        containerView.addSubview(self.profileAvatarView)
        
        return self.profileAvatarView.superview ?? UIView()
        
    }
    //MARK load data
    
    //TODO New loading screen
    func loadCards() {

        
        self.creditCards = KNTipperCardManager.sharedInstance.fetchCards(forUser: KNMobileUserManager.sharedInstance.currentUser()!, cardType: "all")!
        
        self.settingsTableView!.reloadData()
        
        /*
        self.activityViewWrapper!.setLabelText(NSLocalizedString("loading", comment: ""))
        self.activityViewWrapper!.addActivityView(animateIn: true, completionHandler: nil)
        
        
        self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () in
            
            self.creditCards = KNTipperCardManager.sharedInstance.fetchCards(forUser: KNMobileUserManager.sharedInstance.currentUser()!, cardType: "all")!
            
            self.settingsTableView!.reloadData()
            
            self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
            
        })
        */
        
    }

    // MARK: - UITextField delegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        var indexPath:NSIndexPath = NSIndexPath(forRow: textField.tag, inSection: KNCellTypeIndex.CreditCard.rawValue)
        
        self.tableView(self.settingsTableView!, didSelectRowAtIndexPath: indexPath)
        
        return false
    }
    
    // MARK: - KNTextFieldDelegate
    func didTouchLeftButton(sender: AnyObject?) {
        
        var indexPath:NSIndexPath = NSIndexPath(forRow: (sender as KNTextField).tag, inSection: KNCellTypeIndex.CreditCard.rawValue)
        
        self.tableView(self.settingsTableView!, didSelectRowAtIndexPath: indexPath)
    }
    
    // MARK: - Delete card
    func didTouchRightButton(sender: AnyObject?) {
        var indexPath:NSIndexPath = NSIndexPath(forRow: (sender as KNTextField).tag, inSection: KNCellTypeIndex.CreditCard.rawValue)
        
        let vc:KNDeleteCCViewController = KNStoryboardManager.sharedInstance.getViewControllerWithIdentifierFromStoryboard(kDeleteCardViewControllerId, storyboardName: kCardManagementStoryboardName) as KNDeleteCCViewController
        vc.card = self.creditCards[indexPath.row]
        vc.delegate = self
        
        dispatch_after(0, dispatch_get_main_queue(), { () -> Void in
            self.navigationController!.presentViewController(vc, animated: true, completion: {})
        })
    }
    
    // MARK: - Update card delegate
    func cardIsDeleted() {
        self.loadCards()
    }
    
    func cardAdded() {
        self.loadCards()
    }
    
    func didEditProfileSuccess(profile: KNMobileUser?) {
        
            //self.profileAvatarView.setText(profile!.publicName)
        
        self.profileAvatarView.setText(KNMobileUserManager.sharedInstance.currentUser()!.publicName.formatPublicName())
            
            // get profile avatar image
            self.profileAvatarView!.profileAvatarImageButton!.showActivityView()
        
            KNAvatarManager.sharedInstance.getAvatarImage(placeholder: "AddPhoto") { (downloadSuccessful, avatarImage, errorDescription) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                   self.profileAvatarView!.profileAvatarImageButton!.setImage(avatarImage!)
                })
                
                
            }

    }

}
