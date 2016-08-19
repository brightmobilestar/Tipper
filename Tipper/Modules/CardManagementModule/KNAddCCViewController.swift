//
//  KNAddCCViewController.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/18/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

protocol KNAddCCViewDelegate {
    func cardAdded()
}

class KNAddCCTableViewCell : UITableViewCell {
    
    @IBOutlet weak var vContainer: KNCreditCardView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

class KNAddCCViewController: KNBaseViewController, KNCreditCardViewDelegate, UITableViewDataSource, UITableViewDelegate {

    // MARK: IBOutlets
    
    @IBOutlet weak var btSave: UIBarButtonItem?
    @IBOutlet weak var tableView: UITableView?
    
    var activityViewWrapper: KNActivityViewWrapper?
    
    var isDebitOnly = false
    
    // MARK: Variable
    var delegate:KNAddCCViewDelegate?
    private var currentCard:PTKCard?
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        self.btSave!.enabled = false
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        if self.isDebitOnly == true
        {
            self.title = NSLocalizedString("addDebitCard", comment: "")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBAction
    @IBAction func closeViewPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveCreditCardPressed(sender: AnyObject) {
        self.view.endEditing(true)
        
        var expMonth:String = "\(self.currentCard!.expMonth)"
        if expMonth.length < 2 {
            expMonth = "0\(self.currentCard!.expMonth)"
        }
        
        self.activityViewWrapper!.setLabelText(NSLocalizedString("Adding Cards...", comment: ""))
        self.activityViewWrapper!.addActivityView(animateIn: true, completionHandler: nil)
        

        KNTipperCardManager.sharedInstance.addTipperCard(self.currentCard!.brand, cardNumber: self.currentCard!.number, expMonth: expMonth, expYear: "\(self.currentCard!.expYear)", cvc: self.currentCard!.cvc, user: KNMobileUserManager.sharedInstance.currentUser()!, firstName: self.currentCard!.firstName, lastName: self.currentCard!.lastName, cardType: self.currentCard!.cardType) { (responseObj) -> () in
            
            self.activityViewWrapper!.minimumVisibleDurationCompletionHandler( { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                    
                    
                    if responseObj.status == kAPIStatusOk {
                        
                        self.addCardSuccess()
                        self.closeViewPressed(self)
                        
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
    
    // MARK: - KNCreditCardViewDelegate
    func paymentView(paymentView: KNCreditCardView, withCard card: PTKCard, isValid valid: Bool) {
        self.btSave!.enabled = valid
        if valid {
            self.currentCard = card
        }
    }
    
    func addCardSuccess() {
        println("addCardSuccess")
        self.delegate?.cardAdded()
    }
    
    
    // MARK: - UITableViewDatasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:KNAddCCTableViewCell = tableView.dequeueReusableCellWithIdentifier("addCCTableViewCell") as KNAddCCTableViewCell
        
        cell.vContainer!.setupControls()
        cell.vContainer!.delegate = self
        
        cell.vContainer?.cardNumberField?.tableViewContainer = tableView
        cell.vContainer?.cardExpiryMonthField?.tableViewContainer = tableView
        cell.vContainer?.cardExpiryYearField?.tableViewContainer = tableView
        cell.vContainer?.cardCVCField?.tableViewContainer = tableView
        cell.vContainer?.cardNameField?.tableViewContainer = tableView
        cell.vContainer?.cardSurnameField?.tableViewContainer = tableView
        
        if self.isDebitOnly == true
        {
            cell.vContainer?.debitOnlyTextView?.text = NSLocalizedString("addDebitCardExplaination", comment: "")
            cell.vContainer?.debitOnlyTextView?.selectable = false // set selectable = false after text change
            // as of xcode 6.1, there is a bug where changing UITextView text when .selectable == true will reset the font to default font family, size, color, etc.
            cell.vContainer?.cardSwithCreditOrDebit?.setOn(true, animated: false)
            cell.vContainer?.cardSwithCreditOrDebit?.hidden = true
            cell.vContainer?.creditLabel?.hidden = true
            cell.vContainer?.debitLabel?.hidden = true
            cell.vContainer?.debitOnlyTextView?.hidden = false

        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            cell.vContainer!.cardExpiryYearField?.layer.borderWidth = 0
            cell.vContainer!.cardExpiryYearField?.setCustomTopBorder(lineColor: nil)
            cell.vContainer!.setCardManagementTheme()
            let oldFrame = cell.vContainer!.cardExpiryYearField!.frame
            cell.vContainer!.cardExpiryYearField!.frame = CGRectMake(oldFrame.origin.x - 50, oldFrame.origin.y, oldFrame.size.width + 50, oldFrame.size.height)
            cell.vContainer!.cardExpiryYearField!.textAlignment = NSTextAlignment.Right

        })
        
        return cell
    }
}
