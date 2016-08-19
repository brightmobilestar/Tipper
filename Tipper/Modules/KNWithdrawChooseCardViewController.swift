//
//  KNWithdrawChooseCardViewController.swift
//  Tipper
//
//  Created by Gregory Walters on 1/14/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit

class KNWithdrawChooseCardViewController: KNBaseViewController, UITableViewDataSource, UITableViewDelegate, KNAddCCViewDelegate, UITextFieldDelegate, KNEditProfileViewControllerDelegate
{
    // TODO, Should import amountTextField to table view cell to implement Add Card feature when there is no card.
    // Add card view has many inputs, so whole screen should be scrollable, 
    // We should judge how to add card here, whether navigate to Add Card VC, or show Add Card view like in KNCCViewController, because it is not described in design
    
    @IBOutlet var tableView: UITableView?
    @IBOutlet var amountTextField: KNTextField!
    
    private var currentCard:PTKCard?
    
    var debitCards:Array<TipperCard> = Array<TipperCard>()
    var selectedCard:TipperCard?
    var carryOverTipAmount: String?
    var activityViewWrapper: KNActivityViewWrapper?
    
    // Added by luokey
    var paypalEmail: String?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        self.tableView?.tableFooterView = UIView(frame: CGRectZero)
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.amountTextField.delegate = self
        
        self.loadCards()
        
        if self.carryOverTipAmount != nil
        {
            self.amountTextField.attributedText = KNHelperManager.sharedInstance.attributedAmountString(self.carryOverTipAmount!)
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
      
        self.navigationController?.popViewControllerAnimated(true)
        return false
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        //while self.amountTextField.gestureRecognizers?.count > 0
        //{
            //self.amountTextField.removeGestureRecognizer(self.amountTextField.gestureRecognizers![0] as UIGestureRecognizer)
        //}
    }
    
    // MARK: Action
    @IBAction func backButtonTouch(sender: UIBarButtonItem)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: UITableViewCell!
        
        // Added by luokey
        if indexPath.row == 0 {
            if self.paypalEmail != nil && self.paypalEmail?.length > 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("CardCell") as UITableViewCell
                
                (cell as KNWithdrawTableViewCell).cardNameLabel.text = self.paypalEmail
            }
            else {
                cell = tableView.dequeueReusableCellWithIdentifier("AddCardCell") as UITableViewCell
            }
        }
        
        return cell
        
        
        // Marked by luokey
        /*
        if indexPath.row < self.debitCards.count
        {
            cell = tableView.dequeueReusableCellWithIdentifier("CardCell") as UITableViewCell
            
            var debitCard: TipperCard = self.debitCards[indexPath.row]
            (cell as KNWithdrawTableViewCell).cardNameLabel.text = "\(debitCard.brand) \(debitCard.last4)"
        }
        else
        {
            cell = tableView.dequeueReusableCellWithIdentifier("AddCardCell") as UITableViewCell
        }

        return cell
        */
        
        
        
        
        /*
        if self.debitCards.count > 0 {
            var cell: KNWithdrawTableViewCell = tableView.dequeueReusableCellWithIdentifier("CardCell") as KNWithdrawTableViewCell
            
            var debitCard: TipperCard = self.debitCards[indexPath.row]
            
            cell.cardNameLabel.text = "\(debitCard.brand) \(debitCard.last4)"
            
            return cell
        }
        else{
            var cell:KNAddCardViewCell = tableView.dequeueReusableCellWithIdentifier("addCCCell") as KNAddCardViewCell
            
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
            
            cell.btnAddCard!.setBackgroundImage(UIImage.imageWithColor(kColorHighlightButton, size: CGSize(width: 1, height: 1)), forState: UIControlState.Highlighted)
            cell.btnAddCard!.setBackgroundImage(UIImage.imageWithColor(kColorDisableButton, size: CGSize(width: 1, height: 1)), forState: UIControlState.Disabled)
            
            return cell
        }
        */
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Marked by luokey
//        return self.debitCards.count + 1
        
        // Added by luokey
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 50
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        // Marked by luokey
//        if indexPath.row < self.debitCards.count
        
        // Added by luokey
        if indexPath.row == 0 && self.paypalEmail != nil && self.paypalEmail?.length > 0 {
            
            // Marked by luokey
            /*
            let storyboard = UIStoryboard(name: kWithdrawModuleStoryboardName, bundle: nil)
            let viewController = storyboard.instantiateViewControllerWithIdentifier(kWithdrawConfirmViewController) as KNWithdrawConfirmViewController
            viewController.carryOverTipAmount = self.amountTextField.text
            viewController.carryOverCard = debitCards[indexPath.row]
            self.navigationController?.pushViewController(viewController, animated: true)
            */
            
            
            let storyboard = UIStoryboard(name: kWithdrawModuleStoryboardName, bundle: nil)
            let viewController = storyboard.instantiateViewControllerWithIdentifier(kWithdrawConfirmViewController) as KNWithdrawConfirmViewController
            viewController.carryOverTipAmount = self.amountTextField.text
            
            // Marked by luokey
//            viewController.carryOverCard = debitCards[indexPath.row]
            
            // Added by luokey
            viewController.carryOverPaypalEmail = self.paypalEmail
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else {
            
            // Marked by luokey
            /*
            let vc:KNAddCCViewController = KNStoryboardManager.sharedInstance.getViewControllerWithIdentifierFromStoryboard(kAddCardViewControllerId, storyboardName: kCardManagementStoryboardName) as KNAddCCViewController
            vc.delegate = self
            vc.isDebitOnly = true
            */
            
            // Added by luokey
            let vc:KNEditProfileViewController = KNStoryboardManager.sharedInstance.getViewControllerWithIdentifierFromStoryboard(kEditProfileStoryboardId, storyboardName: kProfileStoryboardName) as KNEditProfileViewController
            vc.knDelegate = self
                
            self.navigationController!.pushViewController(vc, animated: true)

        }
    }
    
    func cardAdded()
    {
        self.loadCards()
    }
    
    
    // MARK: KNEditProfileViewController delegate
    
    func didEditProfileSuccess(profile: KNMobileUser?) {
        
        self.loadCards()
    }
    
    // MARK: Data
    func loadCards() {
        
        // Added by luokey
        self.paypalEmail = KNMobileUserManager.sharedInstance.currentUser()?.paypalEmail
        
        self.debitCards = KNTipperCardManager.sharedInstance.fetchCards(forUser: KNMobileUserManager.sharedInstance.currentUser()!, cardType: "debit")!

        self.tableView?.reloadData()
    }
    
    func addCardHandler(sender:AnyObject){
        
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        
        let cell = self.tableView?.cellForRowAtIndexPath(indexPath) as KNAddCardViewCell
        self.currentCard = cell.currentCard
        
        self.addCardButtonPressed(sender)
        
    }
    
    func addCardButtonPressed(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        self.activityViewWrapper!.setLabelText(NSLocalizedString("addingCard", comment: ""))
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
                        
                        self.loadCards()
                        
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
    
}
