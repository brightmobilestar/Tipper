//
//  KNCCViewController.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/18/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

class KNCCViewController: KNBaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, KNAddCCViewDelegate {
   
    @IBOutlet weak var tbvCardList: UITableView?

    private var currentCard:PTKCard?
    
    var friend:KNFriend?
    var amount: String = ""
    var cards = Array<TipperCard>()
    var selectedCard:TipperCard?
    var isLoadedData:Bool?
    
    
    var unknownPersonToTip:String?
    
    var activityViewWrapper: KNActivityViewWrapper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        
        self.isLoadedData = false
        self.getListCreditCards()
        
        self.tbvCardList?.alwaysBounceVertical = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if self.tbvCardList!.indexPathForSelectedRow() != nil {
            self.tbvCardList!.deselectRowAtIndexPath(self.tbvCardList!.indexPathForSelectedRow()!, animated: false)
        }

    }
    
    func addCardButtonPressed(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        self.activityViewWrapper!.setLabelText(NSLocalizedString("Adding Cards...", comment: ""))
        self.activityViewWrapper!.addActivityView(animateIn: true, completionHandler: nil)
        
        
        var expMonth:String = "\(self.currentCard!.expMonth)"
        if expMonth.length < 2 {
            expMonth = "0\(self.currentCard!.expMonth)"
        }
        
        KNTipperCardManager.sharedInstance.addTipperCard(self.currentCard!.brand, cardNumber: self.currentCard!.number, expMonth: expMonth, expYear: "\(self.currentCard!.expYear)", cvc: self.currentCard!.cvc, user: KNMobileUserManager.sharedInstance.currentUser()!, firstName: self.currentCard!.firstName, lastName: self.currentCard!.lastName, cardType: self.currentCard!.cardType) { (responseObj) -> () in
            
            self.activityViewWrapper!.minimumVisibleDurationCompletionHandler( { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)

                    
                    if responseObj.status == kAPIStatusOk {
                        
                        self.getListCreditCards()
                        
                    } else {
                        if responseObj.errors.count > 0 {
                            var errorMsg:String = responseObj.errors[0].errorMessage
                            
                            let alert:KNStandardAlertController = KNStandardAlertController()
                            alert.showAlert(self, title: NSLocalizedString("Error", comment: ""), message: errorMsg)
                        } else {
                            let alert:KNStandardAlertController = KNStandardAlertController()
                            alert.showAlert(self, title: NSLocalizedString("Error", comment: ""), message:  NSLocalizedString("unknownError", comment: ""))
                        }
                    }
                })
            })
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return false;
    }
    
    // MARK: Private methods
    func getListCreditCards() {
    
        var cardType : String = "all"
        self.cards = KNTipperCardManager.sharedInstance.fetchCards(forUser: KNMobileUserManager.sharedInstance.currentUser()!, cardType: "credit")!
        self.isLoadedData = true
        self.tbvCardList!.reloadData()
        
    }
    
    // MARK: UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if section == 1 {
            var headerView = UIView(frame: CGRectMake(0.0, 0.0, tableView.frame.width, 30.0))
            headerView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
            var headerLabel = UILabel(frame: CGRectMake(8.0, 5.0, tableView.frame.width - 5.0, 20.0))
            headerLabel.text = NSLocalizedString("selectCardToTipFrom", comment: "")
            headerView.addSubview(headerLabel)
            return headerView
        }
        else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1 {
            return 30.0
        }
        else {
            return 0.0
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
            if section == 0
            {
                return 1
            }
            else
            {
                return self.cards.count + 1
            }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if ( indexPath.section == 1 ){
            
            if indexPath.row == self.cards.count
            {
                let vc:KNAddCCViewController = KNStoryboardManager.sharedInstance.getViewControllerWithIdentifierFromStoryboard(kAddCardViewControllerId, storyboardName: kCardManagementStoryboardName) as KNAddCCViewController
                vc.delegate = self
                vc.isDebitOnly = false
                
                self.navigationController!.pushViewController(vc, animated: true)
            }
            else
            {
                self.selectedCard = self.cards[indexPath.row]
                dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
                    self.performSegueWithIdentifier("ConfirmSegue", sender: AnyObject?())
                }
            }
        }
    }
    
    func cardAdded() {
        self.getListCreditCards()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            var cell:KNAddCardContactViewCell = tableView.dequeueReusableCellWithIdentifier("cellContact") as KNAddCardContactViewCell
            
            var friendAvatarImage:UIImage? = UIImage(named: kUserPlaceHolderImageName)
            cell.tfProfile!.addLeftImage(leftImage: friendAvatarImage, gapNextImage: 10)
            
            if (self.friend != nil){
                if self.friend?.avatar.length > 0 {
                    
                    var sizeOfImage: CGSize = friendAvatarImage!.size
                    var imageView:UIImageView = UIImageView(frame: CGRectMake(0,0,sizeOfImage.width, sizeOfImage.height))
                    var url : NSURL = NSURL(string: self.friend!.avatar)!
                    
                    KNImageLoader.sharedInstance.loadImageFromURL(url,
                        placeholder: friendAvatarImage,
                        failure: nil,
                        success: { (downloadedImage:UIImage) -> () in
                            cell.tfProfile!.addImageFor(leftImage: downloadedImage, rightImage: nil)
                        }
                    )
                }
                cell.tfProfile!.text = " \(self.friend!.publicName.formatPublicName())"
                
            }
            else{
                
                cell.tfProfile!.text = " \(self.unknownPersonToTip!)"
                
            }
            
            cell.tfProfile!.resignFirstResponder()
            cell.tfProfile!.endEditing(true)
            //cell.tfProfile!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("goProfile")))
            
            cell.tfMoneyTip!.addImageForLeft("CurrencyIcon", leftGapOfImage: 15, widthOfImage: 30, rightGapOfImage: 5)
            cell.tfMoneyTip!.addImageForRight("TextFieldPlaceHolderIcon", leftGapOfImage: 0, widthOfImage: 50, rightGapOfImage: 0)
            
            cell.tfMoneyTip!.resignFirstResponder()
            cell.tfMoneyTip!.endEditing(true)
            
            cell.tfMoneyTip!.attributedText = KNHelperManager.sharedInstance.attributedAmountString(self.amount)
            
            return cell
        }
        else {
            
            if indexPath.row == self.cards.count
            {
                var cell = tableView.dequeueReusableCellWithIdentifier("AddCardCell") as UITableViewCell
                var addCardLabel = cell.viewWithTag(1)! as UILabel
                addCardLabel.text = NSLocalizedString("addCard", comment: "")
                return cell
            }
            else
            {
                var cell:KNCardViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as KNCardViewCell
                cell.tfCarProfile!.addImageForLeftOrRightViewWithImage(leftImage: "CreditCardIcon", rightImage: "")
                
                let card = self.cards[indexPath.row]
                
                cell.tfCarProfile!.backgroundColor = UIColor.whiteColor()
                cell.tfCarProfile!.textColor = UIColor.blackColor()
                cell.tfCarProfile!.text = "\(card.brand) \(card.last4)"
                cell.tfCarProfile!.userInteractionEnabled = false
                
                if card == self.cards.last {
                    
                    cell.line?.backgroundColor = UIColor.clearColor()
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyle.Default
                
                return cell
            }
            
            
            /*
            if self.cards.count > 0 {
                
                var cell:KNCardViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as KNCardViewCell
                cell.tfCarProfile!.addImageForLeftOrRightViewWithImage(leftImage: "CreditCardIcon", rightImage: "")
                
                let card = self.cards[indexPath.row]
                
                cell.tfCarProfile!.backgroundColor = UIColor.whiteColor()
                cell.tfCarProfile!.textColor = UIColor.blackColor()
                cell.tfCarProfile!.text = "\(card.brand) \(card.last4)"
                cell.tfCarProfile!.userInteractionEnabled = false
                
                if card == self.cards.last {
                    
                    cell.line?.backgroundColor = UIColor.clearColor()
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyle.Default
                
                return cell
            }else{
                
                
                /*
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.creditCard!.setTitileText(textColor: UIColor.blackColor())
                })
                
                // Add bottom border for card number field
                //cell.creditCard?.cardNumberField?.setBottomBorder(lineColor: UIColor(red: 191.0/255.0, green: 194.0/255.0, blue: 196.0/255.0, alpha: 1.0))
                
                // Add top border for CVC field
                //cell.creditCard?.cardCVCField?.setTopBorder(lineColor: UIColor(red: 191.0/255.0, green: 194.0/255.0, blue: 196.0/255.0, alpha: 1.0))
                
                cell.creditCard?.cardNumberField?.tableViewContainer = tableView
                cell.creditCard?.cardExpiryMonthField?.tableViewContainer = tableView
                cell.creditCard?.cardExpiryYearField?.tableViewContainer = tableView
                cell.creditCard?.cardCVCField?.tableViewContainer = tableView
                cell.creditCard?.cardNameField?.tableViewContainer = tableView
                cell.creditCard?.cardSurnameField?.tableViewContainer = tableView
                
                
                cell.btnAddCard?.addTarget(self, action: Selector("addCardHandler:"), forControlEvents: UIControlEvents.TouchUpInside)
                
                cell.btnAddCard!.setBackgroundImage(UIImage.imageWithColor(kTipButtonBackgroundNormal, size: CGSize(width: 1, height: 1)), forState: UIControlState.Highlighted)
                cell.btnAddCard!.setBackgroundImage(UIImage.imageWithColor(kColorDisableButton, size: CGSize(width: 1, height: 1)), forState: UIControlState.Disabled)
                */
                return cell
                
            }
            */
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if ( indexPath.section > 0 ){
            if  self.cards.count > 0 {
                return 50.0
            }else {
                return 50.0
            }
        }
        else {
            return 180
        }
        
    }
    
    func addCardHandler(sender:AnyObject){
    
        let indexPath = NSIndexPath(forRow: 0, inSection: 1)
        
        let cell = self.tbvCardList?.cellForRowAtIndexPath(indexPath) as KNAddCardViewCell
        self.currentCard = cell.currentCard
        
        self.addCardButtonPressed(sender)
        
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if  segue.identifier == "ConfirmSegue" {
            
            let vc = segue.destinationViewController as KNConfirmViewController
            vc.friend = self.friend
            vc.unknownPersonToTip = self.unknownPersonToTip
            vc.amount = self.amount
            vc.card = self.selectedCard
        }
    }
    
    @IBAction func goProfile(sender:AnyObject) {
        KNHelperManager.sharedInstance.setAnimationFade(self.navigationController?)
        self.navigationController?.popToViewController(self.navigationController?.viewControllers[2] as UIViewController, animated: false)
    }
    
    @IBAction  func goBack(sender:AnyObject) {
        KNHelperManager.sharedInstance.setAnimationFade(self.navigationController?)
        self.navigationController?.popViewControllerAnimated(false)
    }
}
