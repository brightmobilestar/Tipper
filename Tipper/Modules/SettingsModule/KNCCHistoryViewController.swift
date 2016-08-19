//
//  KNCCHistoryViewController.swift
//  Tipper
//
//  Created by Vu Tiet on 11/27/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit




class KNCCHistoryViewController: KNBaseViewController, UITableViewDelegate, UITableViewDataSource, KNCCHistoryTableBalanceKindDelegate, KNBaseNavigationControllerPresenter
{
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var backButton: UIBarButtonItem?
    @IBOutlet weak var btnWithdraw: UIBarButtonItem?
    @IBOutlet weak var topConstraintOfTableView: NSLayoutConstraint?
    
    
    // View mode, true : sent history, false : recevied history
    var sentSelected: Bool = false
        
    var sentTips : Array<TipperHistory>?
    var receivedTips : Array<TipperHistory>?
    
    var balanceSelector : UIView?
    
    var activityViewWrapper : KNActivityViewWrapper?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // enabling nav bar scrolling like instagram
       // self.followScrollView(self.tableView!, usingTopConstraint: self.topConstraintOfTableView, withDelay: 65)
       // self.setShouldScrollWhenContentFits(true)
        
        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        
        
        self.tableView?.tableFooterView = UIView(frame: CGRectZero)

        // For iOS8 only
        if (isIOS8OrHigher()) {
            self.tableView?.layoutMargins = UIEdgeInsetsZero
            self.tableView?.separatorInset = UIEdgeInsetsZero
        }
        
        self.tableView?.alwaysBounceVertical = false
        
        self.activityViewWrapper!.setLabelText(NSLocalizedString("Loading History...", comment: ""))
        self.activityViewWrapper!.addActivityView(animateIn: true, completionHandler: nil)
        
        // Fetch sent history
        KNTipperHistoryManager.sharedInstance.fetchSentHistoryFromServer(forUser: KNMobileUserManager.sharedInstance.currentUser()!) { (responseObj) -> Void in
            
            // Fetch received history
            KNTipperHistoryManager.sharedInstance.fetchReceivedHistoryFromServer(forUser: KNMobileUserManager.sharedInstance.currentUser()! ) { (responseObj) -> Void in
                
                // Fetch total balance
                KNTipperWithdrawManager.sharedInstance.fetchBalance({ (success, balance, responseObj) -> () in
                    // Hide activity
                    self.activityViewWrapper!.minimumVisibleDurationCompletionHandler({ () -> Void in
                        self.activityViewWrapper!.removeActivityView(animateOut: true, completionHandler: nil)
                        
                        // load history
                        self.sentTips = KNTipperHistoryManager.sharedInstance.fetchTipperHistory(forUser: KNMobileUserManager.sharedInstance.currentUser()!, sent: true)
                        self.receivedTips = KNTipperHistoryManager.sharedInstance.fetchTipperHistory(forUser: KNMobileUserManager.sharedInstance.currentUser()!, sent: false)
                        self.tableView!.reloadData()
                        self.setWithdrawButtonState()
                    })
                })
            }
        }
    }
    //MARK helper
    func setWithdrawButtonState(){
        var balance:Float = KNMobileUserManager.sharedInstance.getBalance()
        
        // Marked by luokey for test withdraw
//        if balance < 1000 {
        if balance < 10 {
            self.btnWithdraw!.enabled  = false
        }
        else{
            self.btnWithdraw!.enabled  = true
        }
       
    }
    
    // MARK - TableView Delegate & Datasource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        //setWithdrawButtonState()
        self.btnWithdraw!.enabled  = false
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            // Current Balance (Total)
            return 1
        }
        else {
            var currentTips : Array<TipperHistory>?
            
            if sentSelected  {
                currentTips = sentTips
            }
            else {
                currentTips = receivedTips
            }
            
            if currentTips == nil {
                return 0
            }
            else {
                return currentTips!.count
            }

        }
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        else {
            var headerView: KNCCHistoryTableSelectBalanceKindTableViewCell = tableView.dequeueReusableCellWithIdentifier("cellBalanceLogHeader") as KNCCHistoryTableSelectBalanceKindTableViewCell
            headerView.delegate = self
            headerView.setBalanceKind(self.sentSelected)
            self.balanceSelector = headerView
            return headerView
        }
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            // Current balance cell
            return 126
        }
        else {
            // Balance log cell
            return 50
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        else {
            return 50
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            var cell:KNCCHistoryTableCurrentBalanceTableViewCell = tableView.dequeueReusableCellWithIdentifier("cellCurrentBallance", forIndexPath: indexPath) as KNCCHistoryTableCurrentBalanceTableViewCell
            
            //var balance : TipperUserBalance = KNCoreDataManager.sharedInstance.findTipperUserBalance(KNMobileUserManager.sharedInstance.currentUser()!.userId)
            var balance = KNMobileUserManager.sharedInstance.getBalance()
//            var amountString : String = KNHelperManager.sharedInstance.centToDollarCurrencyString(balance)    // Marked by luokey
            var amountString : String = KNHelperManager.sharedInstance.dollarCurrencyString(balance)            // Added by luokey
            cell.labelCurrentBalance!.attributedText = KNHelperManager.sharedInstance.attributedAmountString(amountString)
            
            return cell
        }
        else{
            var cell:KNCCHistoryTableBalanceLogTableViewCell = tableView.dequeueReusableCellWithIdentifier("cellBalanceLog") as KNCCHistoryTableBalanceLogTableViewCell
            
            var currentHistories : Array<TipperHistory>?
            
            if ( sentSelected ) {
                currentHistories = sentTips
            }
            else{
                currentHistories = receivedTips
            }
            
           
            var history: TipperHistory = currentHistories![indexPath.row]
            
        
            
            if history.friendFullName.isEmpty {
                // Marked by luokey
//                cell.labelAmountAndUser!.text = KNHelperManager.sharedInstance.centToDollarCurrencyString(history.tipAmount) + " " + "Pending"
                
                // Added by luokey
                cell.labelAmountAndUser!.text = KNHelperManager.sharedInstance.dollarCurrencyString(history.tipAmount) + " " + "Pending"
            }
            else {
                // Marked by luokey
//                cell.labelAmountAndUser!.text = KNHelperManager.sharedInstance.centToDollarCurrencyString(history.tipAmount) + " " + history.friendFullName.formatPublicName()
                
                // Added by luokey
                cell.labelAmountAndUser!.text = KNHelperManager.sharedInstance.dollarCurrencyString(history.tipAmount) + " " + history.friendFullName.formatPublicName()
            }
            
            
            
               //Using from local settings of the user
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .ShortStyle
            dateFormatter.locale = NSLocale.currentLocale()
            if let dateString:String = dateFormatter.stringFromDate(history.tipDate) as String?{
   
                cell.labelDateAndTime!.text = dateString
            }
            cell.viewVisibleArea!.layer.borderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.8).CGColor
            cell.viewVisibleArea!.layer.borderWidth = 0.5
            cell.heightOfVisibleArea!.constant = 50
            cell.topOfLabelAmount!.constant = 0
            cell.topOfLabelDate!.constant = 0
            return cell
        
        }
        
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.hideCellsBehindSectionHeader()
    }
    
    func hideCellsBehindSectionHeader(){
        // Hide cells behind section header ( balance selector)
        var cells : Array<UITableViewCell> = self.tableView?.visibleCells() as Array<UITableViewCell>
        
        if ( cells.count > 0){
            for var i = 0; i < cells.count; i++ {
                var cell : UITableViewCell = cells[i]
                if ( cell.isKindOfClass(KNCCHistoryTableBalanceLogTableViewCell)){
                    let logCell : KNCCHistoryTableBalanceLogTableViewCell = cell as KNCCHistoryTableBalanceLogTableViewCell
                    if ( cell.frame.origin.y < balanceSelector!.frame.origin.y + balanceSelector!.frame.size.height){
                        if ( cell.frame.origin.y + cell.frame.size.height <= balanceSelector!.frame.origin.y + balanceSelector!.frame.size.height ){
                            // all hidden,
                            logCell.heightOfVisibleArea!.constant = 0
                            logCell.topOfLabelDate!.constant = 0
                            logCell.topOfLabelAmount!.constant = 0
                        }
                        else if ( cell.frame.origin.y > balanceSelector!.frame.origin.y){
                            logCell.heightOfVisibleArea!.constant = ( cell.frame.origin.y + cell.frame.size.height - (balanceSelector!.frame.origin.y+balanceSelector!.frame.size.height ))
                            
                            logCell.topOfLabelDate!.constant = logCell.heightOfVisibleArea!.constant - 50
                            logCell.topOfLabelAmount!.constant =  logCell.topOfLabelDate!.constant
                        }
                        else{
                            logCell.heightOfVisibleArea!.constant = 50
                            logCell.topOfLabelDate!.constant = 0
                            logCell.topOfLabelAmount!.constant = 0
                        }

                    }
                    else{
                        logCell.heightOfVisibleArea!.constant = 50
                        logCell.topOfLabelDate!.constant = 0
                        logCell.topOfLabelAmount!.constant = 0
                    }
                }
            }
        }
    }
    
    // MARK - IBAction
    @IBAction func closeViewPressed(sender: AnyObject) {

        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func withdrawPressed(sender: AnyObject) {
        
        let withdrawStoryboard = UIStoryboard(name: "WithdrawStoryboard", bundle: nil)
        let initialWithdrawView = withdrawStoryboard.instantiateViewControllerWithIdentifier("KNWithdrawFirstViewController") as UIViewController
        self.navigationController?.pushViewController(initialWithdrawView, animated: true)
 
    }
    
    func dismissNavigationController()
    {
        self.transitionAnimationType = TransitionAnimationType.DismissPop
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didSelectedBalanceKind(selectedSent: Bool){
        self.sentSelected = selectedSent
        self.tableView?.reloadData()
        self.hideCellsBehindSectionHeader()
    }
    

}
