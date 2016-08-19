//
//  KNWithdrawViewController.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 1/5/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//
/*
import UIKit

class KNWithdrawViewController: KNBaseViewController, UITextFieldDelegate, KNPasscodeViewControllerDeleagate{

    // MARK: IBOutlets
    @IBOutlet weak var lblCurrentBalance: UILabel?
    @IBOutlet weak var tfFirstName: KNTextField?
    @IBOutlet weak var tfLastName: KNTextField?
    @IBOutlet weak var btnWithdrawBalance: UIButton?
    @IBOutlet weak var btnClose: UIBarButtonItem?
    
    var currentBalance:Float?
    let kDefaultBorderWidth:CGFloat = 0.5
    let kDefaultBorderColor:UIColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.8)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // set border
        self.btnWithdrawBalance?.layer.borderColor = kDefaultBorderColor.CGColor
        self.btnWithdrawBalance?.layer.borderWidth = kDefaultBorderWidth
        
        
        self.tfFirstName!.setDefaultTextField()
        self.tfLastName!.setDefaultTextField()
        
        // get current balance
        self.currentBalance = 0
        KNAPIClientManager.sharedInstance.getCurrentBlance(appDelegate.loggedUser!.accessToken!, completed: { (success, balance, errors) -> () in
            
            if success == true {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.currentBalance = balance
                    let amount = String(format: "%.2f", self.currentBalance!/100)
                    self.lblCurrentBalance?.text = "$ \(amount.groupThousandNumber)"
                })
            }
        })
    }
    
    // MARK: - IBAction
    @IBAction func closeViewPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - IBAction
    @IBAction func withdrawBalance(sender: AnyObject) {
        
        let defaultCards = Card.fetchDefaultCards(forUser: appDelegate.loggedUser!)
        if defaultCards != nil && defaultCards!.count > 0 {
        
            self.dismissKeyboards()
            
            let viewController: UIViewController = KNStoryboardManager.sharedInstance.getViewControllerInitial(kPasscodeStoryboardName) as UIViewController
            (viewController as KNPasscodeViewController).registerPasscode = false
            (viewController as KNPasscodeViewController).knPasscodeDelegate = self
            KNHelperManager.sharedInstance.setAnimationPushViewController(self, push: true)
            self.presentViewController(viewController, animated: false, completion: nil)
        }else{
        
            var errorMsg:String = NSLocalizedString("noCardForWithdrawal", comment: "")
            KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                message: errorMsg)
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        textField.text! += string
        if(string == String()) {
            textField.text = textField.text.substringToIndex(textField.text.endIndex.predecessor())
        }
        
        let firstName = self.tfFirstName?.text
        let lastName = self.tfLastName?.text
        let valid = self.checkValidWithdrawBalance(self.currentBalance!, firstName: firstName!, lastName: lastName!)
        self.btnWithdrawBalance?.enabled = valid
        
        if valid {
            
            self.btnWithdrawBalance?.backgroundColor = UIColor(red:36/255, green: 166/255, blue: 240/255, alpha: 1)
        }else{
            
            self.btnWithdrawBalance?.backgroundColor = UIColor.lightGrayColor()
        }
        
        return false
    }
    
    func checkValidWithdrawBalance(balance:Float, firstName first:String, lastName last:String) -> Bool {
        
        var valid:Bool = false
        if balance > 0 && first.isEmpty == false && last.isEmpty == false {
        
            valid = true
        }
    
        return valid
    }
    
    func dismissKeyboards(){
    
        if self.tfFirstName!.isFirstResponder() {
        
            self.tfFirstName?.resignFirstResponder()
        }else if self.tfLastName!.isFirstResponder() {
        
            self.tfLastName?.resignFirstResponder()
        }
    }
    
    func didPasscodeSuccess(passcode: String){
    
        // Withdraw balance
        let defaultCards = Card.fetchDefaultCards(forUser: appDelegate.loggedUser!)
        
        //TODO
        let cardId = defaultCards![0].id! //"54aba6311babe50f560eda97"
        let amount = String(format: "%.0f", self.currentBalance!)

        KNAPIClientManager.sharedInstance.withdrawBalance(cardId, firstName: self.tfFirstName!.text, lastName: self.tfLastName!.text, amount: "\(amount)", pincode: passcode, completed: { (responseObj) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if responseObj.status == kAPIStatusOk {
                    
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    if responseObj.errors.count > 0 {
                        var errorMsg:String = responseObj.errors[0].errorMessage
                        KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                            message: errorMsg)
                    } else {
                        KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                            message: "unknownError")
                    }
                }
            })
            
        })
    }
}

*/
