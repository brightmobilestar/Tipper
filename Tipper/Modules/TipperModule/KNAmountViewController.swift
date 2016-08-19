//
//  KNAmountViewController.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/18/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

class KNAmountViewController: KNBaseViewController, KNNumberKeyboardDelegate, KNTextFieldDelegate, UITextFieldDelegate {
   
    @IBOutlet var tipLabel: UILabel!
    @IBOutlet weak var btnProfile: KNAvatarButton?
    @IBOutlet weak var tfMoneyTip: KNTextField!
    @IBOutlet weak var vKeyboarWrap: UIView?
    private var amount: String = "0"
    
    
    var wtf = true
    
    var friend:KNFriend?

    
    var unknownPersonToTip:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK TODO in case friend is nil and unknownPersonToTip is set you dont have a profile of course
        var friendAvatarImage:UIImage? = UIImage(named: kUserPlaceHolderImageName)
        self.btnProfile!.setImage(friendAvatarImage, forState: .Normal)
        
        
        if (self.friend != nil){
            self.btnProfile!.setTitle(self.friend!.publicName.formatPublicName(), forState: .Normal)
            
            if self.friend!.avatar.length > 0 {
                
                var sizeOfImage: CGSize = friendAvatarImage!.size
                
                var imageView:UIImageView = UIImageView(frame: CGRectMake(0,0,sizeOfImage.width, sizeOfImage.height))
                var url : NSURL = NSURL(string: self.friend!.avatar)!
                
                KNImageLoader.sharedInstance.loadImageFromURL(url,
                    placeholder: friendAvatarImage,
                    failure: nil,
                    success: { (downloadedImage:UIImage) -> () in
                        self.btnProfile!.setImage(downloadedImage, forState: .Normal)
                    }
                )
            }
        }
        else{
            self.btnProfile!.setTitle(unknownPersonToTip!, forState: .Normal)
        }
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        //self.viewWillAppear(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
            
            self.tfMoneyTip!.addImageForLeftOrRightViewWithImage(leftImage: "CurrencyIcon", rightImage: "TextFieldPlaceHolderIcon")
            self.tipLabel.text = self.amount
            self.tfMoneyTip!.font = UIFont(name: kMediumFontName, size: 30)
            
            var keyboardView:KNNumberKeyboard = KNNumberKeyboard.initFromNib()
            keyboardView.delegate = self
            keyboardView.resizeKeyboardFollowFrame(self.vKeyboarWrap!.frame)
            self.view.addSubview(keyboardView)
            
            var currentAmountString  = self.tipLabel.text!.stringByReplacingOccurrencesOfString(",", withString: "", options: .LiteralSearch, range: nil) as NSString
            var amountNumber:Int = Int(currentAmountString.floatValue * 100)
            
            if amountNumber > 0
            {
                self.tfMoneyTip!.addButtonForRightView(titleText: "", imageName: "BlueCheck")
                self.tfMoneyTip!.knDelegate = self
            }
            else {
                self.tfMoneyTip!.addImageForLeftOrRightViewWithImage(leftImage: "CurrencyIcon", rightImage: "TextFieldPlaceHolderIcon")
            }
            
            self.tfMoneyTip?.setBottomBorder(lineColor: UIColor(red: 191.0/255, green: 194.0/255, blue: 196.0/255, alpha: 1.0))
            
            //Set initial when going back
           
            if self.wtf == true
            {
                self.wtf = false
            }
            else
            {
                self.tipLabel.attributedText = KNHelperManager.sharedInstance.attributedAmountString(self.tipLabel.text!)
            }
            
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    // MARK: KNNumberKeyboardDelegate
    
    func keyboardPressDelete()
    {
        if countElements(self.tipLabel.text!) > 0
        {
            self.tipLabel.text = dropLast(self.tipLabel.text!)
            
            let decimalCharacter: Character = "."
            if let decimalIndex = find(self.tipLabel.text!, decimalCharacter) {
                self.tipLabel.attributedText = KNHelperManager.sharedInstance.attributedAmountString(self.tipLabel.text!)
                
            }
            else {
                
                var amountWithoutGroupChar: String = self.tipLabel.text!.stringByReplacingOccurrencesOfString(",", withString: "", options: nil)
                self.tipLabel.text = amountWithoutGroupChar.groupThousandInteger
                self.tipLabel.text = self.tipLabel.text
            }
        }
        
        if (self.tipLabel.text!.stringByReplacingOccurrencesOfString(",", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil) as NSString).floatValue == 0 // removes button if amount is equal to 0
        {
            self.tfMoneyTip!.addImageForLeftOrRightViewWithImage(leftImage: "CurrencyIcon", rightImage: "TextFieldPlaceHolderIcon")
        }
        else
        {
            self.tfMoneyTip!.addButtonForRightView(titleText: "", imageName: "BlueCheck")
            self.tfMoneyTip!.knDelegate = self
        }

    }
    
    func keyboardPressNumber(character: String)
    {
        let isGreaterThanThreeDecimalPlaces = (self.tipLabel.text!.stringByReplacingOccurrencesOfString(",", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil) as NSString).floatValue >= 100 && self.tipLabel.text!.rangeOfString(".", options: nil, range: nil, locale: nil) == nil
        
        if character != "." && isGreaterThanThreeDecimalPlaces == true
        {
            
        }
        else
        {
            if(self.tipLabel.text == "" && character == ".") {
                self.tipLabel.text = "0"
            }
            
            let decimalCharacter: Character = "."
            if let decimalIndex = find(self.tipLabel.text!, decimalCharacter) {
                
                //only one . is enough :)
                if (character == ".") {
                    return
                }
                let decimalPostion:Int = distance(self.tipLabel.text!.startIndex, decimalIndex)
                //Lets avoid more than two decimals
                if (self.tipLabel.text!.length >  decimalPostion + 2 ){
                    
                }
                else{
                    self.tipLabel.text = self.tipLabel.text! + character
                }
                
                self.tipLabel.attributedText = KNHelperManager.sharedInstance.attributedAmountString(self.tipLabel.text!)
                
            }
            else {
                
                if ( character != ".") {
                    var amountWithoutGroupChar: String = self.tipLabel.text!.stringByReplacingOccurrencesOfString(",", withString: "", options: nil)
                    
                    amountWithoutGroupChar += character
                    self.tipLabel.text = amountWithoutGroupChar.groupThousandInteger
                }
                else{
                    self.tipLabel.text = self.tipLabel.text! + character
                    
                }
                
                //self.tfMoneyTip.text = self.tfMoneyTip.text
                
            }
        }
        
        if (self.tipLabel.text!.stringByReplacingOccurrencesOfString(",", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil) as NSString).floatValue == 0 // removes button if amount is equal to 0
        {
            self.tfMoneyTip!.addImageForLeftOrRightViewWithImage(leftImage: "CurrencyIcon", rightImage: "TextFieldPlaceHolderIcon")
        }
        else
        {
            self.tfMoneyTip!.addButtonForRightView(titleText: "", imageName: "BlueCheck")
            self.tfMoneyTip!.knDelegate = self
        }

   
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return false
    }
    
    // MARK: KNTextFieldDelegate
    func didTouchRightButton(sender: AnyObject?) {
        self.performSegueWithIdentifier("CCSegue", sender: self)
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if  segue.identifier == "CCSegue"
        {

            let decimalCharacter: Character = "."
            if let decimalIndex = find(self.tipLabel.text!, decimalCharacter) {
                let decimalPostion:Int = distance(self.tipLabel.text!.startIndex, decimalIndex)
                //Lets avoid more than two decimals
                if (self.tipLabel.text!.length ==   decimalPostion + 1  )
                {
                    var doubleZero:String = "00"
                    self.tipLabel.text! = self.tipLabel.text! + doubleZero
                }
                if (self.tipLabel.text!.length == decimalPostion + 2)
                {
                    var singleZero:String = "0"
                    self.tipLabel.text! = self.tipLabel.text! + singleZero
                }
            }
            else
            {
                self.tipLabel.text! =  self.tipLabel.text! + ".00"
            }
            
            let vc = segue.destinationViewController as KNCCViewController
            vc.friend = self.friend
            vc.unknownPersonToTip = self.unknownPersonToTip
            
            vc.amount = self.tipLabel.text!
            self.amount = vc.amount
        }
    }
    
    // MARK: IBActions
    @IBAction func profileButtonClick(sender: AnyObject) {
        //if self.friend != nil
        //{
            KNHelperManager.sharedInstance.setAnimationFade(self.navigationController?)
            self.navigationController?.popViewControllerAnimated(false)
        //}
        ///else
        //
          //  self.dismissViewControllerAnimated(true, completion: nil)
       // }

    }
}
