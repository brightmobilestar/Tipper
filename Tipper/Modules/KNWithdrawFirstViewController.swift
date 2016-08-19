//
//  KNWithdrawFirstViewController.swift
//  Tipper
//
//  Created by Gregory Walters on 1/14/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit

class KNWithdrawFirstViewController: KNBaseViewController, KNTextFieldDelegate
{
    
    @IBOutlet var amountTextField: KNTextField!
    @IBOutlet var checkButton: UIButton!
    
    @IBOutlet var oneButton: UIButton!
    @IBOutlet var twoButton: UIButton!
    @IBOutlet var threeButton: UIButton!
    @IBOutlet var fourButton: UIButton!
    @IBOutlet var fiveButton: UIButton!
    @IBOutlet var sixButton: UIButton!
    @IBOutlet var sevenButton: UIButton!
    @IBOutlet var eigthButton: UIButton!
    @IBOutlet var nineButton: UIButton!
    @IBOutlet var periodButton: UIButton!
    @IBOutlet var zeroButton: UIButton!
    @IBOutlet var clearButton: UIButton!
    
    
    var maxBalance:Float = 0
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.configureButton(self.oneButton)
        self.configureButton(self.twoButton)
        self.configureButton(self.threeButton)
        self.configureButton(self.fourButton)
        self.configureButton(self.fiveButton)
        self.configureButton(self.sixButton)
        self.configureButton(self.sevenButton)
        self.configureButton(self.eigthButton)
        self.configureButton(self.nineButton)
        self.configureButton(self.periodButton)
        self.configureButton(self.zeroButton)
        self.configureButton(self.clearButton)
        
        //self.amountTextField.addImageForLeftOrRightViewWithImage(leftImage: "TextFieldPlaceHolderIcon", rightImage: "TextFieldPlaceHolderIcon")
        //self.amountTextField.text = "0"
        self.checkButton.hidden = true
    
    }

    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        
        var balance:Float = KNMobileUserManager.sharedInstance.getBalance()
        maxBalance = balance
        var amountString : String = KNHelperManager.sharedInstance.amountToString(balance)
        self.amountTextField.text = amountString
        self.amountTextField.attributedText = KNHelperManager.sharedInstance.attributedAmountString(self.amountTextField.text)
       
        
        self.checkButton.hidden = false
    }
    
    @IBAction func backButtonTouch(sender: UIBarButtonItem){
        self.navigationController?.popViewControllerAnimated(true)
        //self.dismissViewControllerAnimated(true, completion: nil)
        /*
        let viewcontroller : UIViewController = KNStoryboardManager.sharedInstance.getViewControllerWithIdentifierFromStoryboard("KNSplashViewController", storyboardName: "Main") as UIViewController
        self.preparePopAnimation(presentedViewController: viewcontroller)
        self.presentViewController(viewcontroller, animated: true, completion: nil)
        */
    }
    
    @IBAction func checkButtonTouch(sender: UIButton){
        
        let decimalCharacter: Character = "."
        if let decimalIndex = find(self.amountTextField.text, decimalCharacter) {
            let decimalPostion:Int = distance(self.amountTextField.text.startIndex, decimalIndex)
            //Lets avoid more than two decimals
            if (self.amountTextField.text.length ==   decimalPostion + 1  )
            {
                var doubleZero:String = "00"
                self.amountTextField.text = self.amountTextField.text + doubleZero
            }
            if (self.amountTextField.text.length ==   decimalPostion + 2)
            {
                var singleZero:String = "0"
                self.amountTextField.text = self.amountTextField.text + singleZero
            }
            
        }
        else
        {
            self.amountTextField.text =  self.amountTextField.text + ".00"

        }

        let storyboard = UIStoryboard(name: kWithdrawModuleStoryboardName, bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier(kWithdrawChooseCardViewControllerID) as KNWithdrawChooseCardViewController
        viewController.carryOverTipAmount = self.amountTextField.text
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func numPadButtonTouchUpInside(sender: UIButton)
    {
        if sender.tag <= 9 // 0-9 number buttons
        {
            //check on max amount to withdraw as well
            
           
            if (self.amountTextField.text.stringByReplacingOccurrencesOfString(",", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil) as NSString).floatValue
 >= maxBalance  && self.amountTextField.text.rangeOfString(".", options: nil, range: nil, locale: nil) == nil
            {
                
            }
            else
            {
                self.keyboardPressNumber("\(sender.tag)")
            }
            
            /*
            if sender.tag == 0
            {
                if self.amountTextField.text != "0" // prevents multiple leading zeros
                {
                    self.amountTextField.text = self.amountTextField.text + "\(sender.tag)"
                }
            }
            else
            {
                self.amountTextField.text = self.amountTextField.text + "\(sender.tag)" // adds number
                if self.amountTextField.text[0] == "0" && self.amountTextField.text.rangeOfString(".", options: nil, range: nil, locale: nil) == nil // checks whether to replace leading zero
                {
                    self.amountTextField.text = (self.amountTextField.text as NSString).substringFromIndex(1) // removes leading zero
                }
            }
            */
        }
        else if sender.tag == 10 // period button
        {
            self.keyboardPressNumber(".")
            /*
            if self.amountTextField.text.rangeOfString(".", options: nil, range: nil, locale: nil) == nil // checks to see if string already has "."
            {
                self.amountTextField.text = self.amountTextField.text + "." // adds "."
            }
            */
        }
        else if sender.tag == 20 // clear button
        {
            self.keyboardPressDelete()
            /*
            if self.amountTextField.text.length > 0 // prevents crash in case string length is ever equal to 0
            {
                self.amountTextField.text = (self.amountTextField.text as NSString).substringToIndex(self.amountTextField.text.length - 1) // removes trailing character from string
                if self.amountTextField.text.length == 0 // checks to see if string is empty
                {
                    self.amountTextField.text = "0" // replaces string with "0"
                }
            }
            */
        }
        
        var currentState:Bool = self.checkButton.hidden
        
       
        
        var currentAmountString  = self.amountTextField.text.stringByReplacingOccurrencesOfString(",", withString: "", options: .LiteralSearch, range: nil) as NSString
        
       
        
//        var amountToWithdraw:Float = currentAmountString.floatValue * 100     // Marked by luokey
        var amountToWithdraw:Float = currentAmountString.floatValue             // Added by luokey
        
//        if (amountToWithdraw < 999) {     // Marked by luokey
        if (amountToWithdraw < 10) {      // Added by luokey
            //check for minimum
            self.checkButton.hidden = true
        }
        else {
            if (amountToWithdraw > maxBalance) {
                self.checkButton.hidden = true
            }
            else {
                self.checkButton.hidden = false
            }
        }

        self.amountTextField.attributedText = KNHelperManager.sharedInstance.attributedAmountString(self.amountTextField.text)
        
    }
    
    func keyboardPressDelete() {
        if countElements(self.amountTextField.text) > 0
        {
            self.amountTextField.text = dropLast(self.amountTextField.text)
            
            let decimalCharacter: Character = "."
            if let decimalIndex = find(self.amountTextField.text, decimalCharacter) {
                self.amountTextField.attributedText = KNHelperManager.sharedInstance.attributedAmountString(self.amountTextField.text)
                
            }
            else {
                
                var amountWithoutGroupChar: String = self.amountTextField.text.stringByReplacingOccurrencesOfString(",", withString: "", options: nil)
                self.amountTextField.text = amountWithoutGroupChar.groupThousandInteger
                self.amountTextField.text = self.amountTextField.text
            }
            
 
        }
        
        
    }
    
    func keyboardPressNumber(character: String) {
        
        if(self.amountTextField.text == "" && character == ".") {
            self.amountTextField.text = "0"
        }
        
        let decimalCharacter: Character = "."
        if let decimalIndex = find(self.amountTextField.text, decimalCharacter) {
            
            //only one . is enough :)
            if (character == ".") {
                return
            }
            let decimalPostion:Int = distance(self.amountTextField.text.startIndex, decimalIndex)
            //Lets avoid more than two decimals
            if (self.amountTextField.text.length >  decimalPostion + 2 ){
                
            }
            else{
                self.amountTextField.text = self.amountTextField.text + character
            }
            
            self.amountTextField.attributedText = KNHelperManager.sharedInstance.attributedAmountString(self.amountTextField.text)
            
        }
        else {
            
            if ( character != ".") {
                var amountWithoutGroupChar: String = self.amountTextField.text.stringByReplacingOccurrencesOfString(",", withString: "", options: nil)
                
                amountWithoutGroupChar += character
                self.amountTextField.text = amountWithoutGroupChar.groupThousandInteger
            }
            else{
                self.amountTextField.text = self.amountTextField.text + character

            }
            
            self.amountTextField.text = self.amountTextField.text
        }
        
        /*
        if(countElements(self.amountTextField.text) > 0)
        {
            self.amountTextField.addButtonForRightView(titleText: "", imageName: "BlueCheck")
            self.amountTextField.knDelegate = self
        }
        else {
            self.amountTextField.addImageForLeftOrRightViewWithImage(leftImage: "CurrencyIcon", rightImage: "TextFieldPlaceHolderIcon")
        }
        */
        
        
    }

    
    func configureButton(button: UIButton)
    {
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        button.setBackgroundImage(self.imageWithColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)), forState: UIControlState.Highlighted)
        button.setBackgroundImage(self.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        button.contentMode = UIViewContentMode.ScaleToFill
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
    
    

}
