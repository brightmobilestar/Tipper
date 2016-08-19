//
//  KNHelperManager.swift
//  CloudBeacon
//
//  Created by PETRUS VAN DE PUT on 10/11/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation
import UIKit



class KNHelperManager {
    
    class var sharedInstance : KNHelperManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNHelperManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNHelperManager()
        }
        return Static.instance!
    }
    
    init() {
        
    }
    
    
    // ----- Added by Luokey ----- //
    //MARK cent to dollar string
    func dollarCurrencyString(dollar:NSNumber) -> String{
        
        var numberFormat:NSNumberFormatter = NSNumberFormatter()
        numberFormat.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        numberFormat.usesGroupingSeparator = true
        numberFormat.alwaysShowsDecimalSeparator = true
        numberFormat.groupingSeparator = ","
        numberFormat.groupingSize = 3
        
        var dollar : NSNumber = NSNumber(float: dollar.floatValue)
        return numberFormat.stringFromNumber(dollar)!
    }
    // ----- Added by Luokey ----- //
    
    
    //MARK cent to dollar string
    func centToDollarCurrencyString(cent:NSNumber) -> String{
        
        var numberFormat:NSNumberFormatter = NSNumberFormatter()
        numberFormat.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        numberFormat.usesGroupingSeparator = true
        numberFormat.alwaysShowsDecimalSeparator = true
        numberFormat.groupingSeparator = ","
        numberFormat.groupingSize = 3
        
        var dollar : NSNumber = NSNumber(float: cent.floatValue/100.0)
        return numberFormat.stringFromNumber(dollar)!
    }
    
    func amountToString(cent:NSNumber) -> String{
        
        var numberFormat:NSNumberFormatter = NSNumberFormatter()
        numberFormat.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormat.usesGroupingSeparator = true
        numberFormat.alwaysShowsDecimalSeparator = true
        numberFormat.groupingSeparator = ","
        numberFormat.groupingSize = 3
        numberFormat.minimumFractionDigits = 2
        
        // Marked by luokey
//        var dollar : NSNumber = NSNumber(float: cent.floatValue/100.0)
        
        // Added by luokey
        var dollar : NSNumber = NSNumber(float: cent.floatValue)
        
        return numberFormat.stringFromNumber(dollar)!
    }
    
    func isValidNumberOfCharacter(testStr: String, minCharacter: Int, maxCharacter: Int) -> Bool {
        let result = (testStr.length >= minCharacter && testStr.length <= maxCharacter)
        return result
    }
    
    func isValidPublicName(testStr: String) -> Bool {
        let publicNameRegEx = "[A-Za-z0-9\\s]*"
        
        var publicNameTest = NSPredicate(format:"SELF MATCHES %@", publicNameRegEx)
        let checkTrimFirstAndLast = (testStr[0] != " " && testStr[testStr.length - 1] != " ")
        let checkUpFromTwoCharacter = (testStr.length > 1)
        let result = publicNameTest!.evaluateWithObject(testStr) && checkTrimFirstAndLast && checkUpFromTwoCharacter
        return result
    }
    
    //MARK - validation
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        var emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest!.evaluateWithObject(testStr)
        return result
    }
    
    func isValidPhoneNumber(testStr:String, minLength:Int = 10, maxLength: Int = 10) -> Bool{
        
        if testStr.length < minLength || testStr.length > maxLength {
            return false
        }
        let phoneNumberRegEx = "[0-9]*"
        
        var phoneNumberTest = NSPredicate(format:"SELF MATCHES %@", phoneNumberRegEx)
        let result = phoneNumberTest!.evaluateWithObject(testStr)
        return result
    }
    
    // MARK - base64
    func imageURLToBase64String(imageURLString:String) ->String{
        var baseUrl: String = imageURLString
        var imgURL: NSURL = NSURL(string: baseUrl)!
        var imgData: NSData = NSData(contentsOfURL: imgURL)!
        let base64String = imgData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithCarriageReturn)
        return base64String
    }
    
    func dataToBase64String(imageData:NSData) ->String{
        let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithCarriageReturn)
        return base64String
    }
    
    func decodeBase64ToImage(strEncodeData: String) -> UIImage? {
        var data:NSData? = NSData (base64EncodedString: strEncodeData, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        
        if  let imageData = data {
            
            return UIImage(data: imageData)
        }
        
        return nil
        
    }
    //MARK -- easy functions
    func getAppVersion() ->String{
        let appVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as String
        return appVersion
    }
    
    func setAnimationPushViewController(viewController: UIViewController, push: Bool)
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var transition:CATransition = CATransition()
            transition.duration = 0.35
            transition.type = kCATransitionPush
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            if(push) {
                transition.subtype = kCATransitionFromRight
            }
            else {
                transition.subtype = kCATransitionFromLeft
            }
            viewController.view.window?.layer.addAnimation(transition, forKey: kCATransition)
        })
    }
    
    func setAnimationPushViewControllerNonAsync(viewController: UIViewController, push: Bool)
    {
        var transition:CATransition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        if(push) {
            transition.subtype = kCATransitionFromRight
        }
        else {
            transition.subtype = kCATransitionFromLeft
        }
        viewController.view.window!.layer.addAnimation(transition, forKey: kCATransition)
    }
    
    func setAnimationFade(viewController: UINavigationController?)
    {
        var transition:CATransition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        viewController?.view.layer.addAnimation(transition, forKey: kCATransition)
    }

    func  attributedAmountString(amount:String) -> NSMutableAttributedString {
        var attributedAmountString : NSMutableAttributedString = NSMutableAttributedString(string: amount)
        
        let decimalCharacter: Character = "."
        
        if let decimalIndex = find(amount, decimalCharacter) {
            
            let decimalPostion:Int = distance(amount.startIndex, decimalIndex)
            attributedAmountString.addAttribute(NSFontAttributeName, value: kCCViewMoneyTextLargeFont, range: NSMakeRange(0, decimalPostion))
            attributedAmountString.addAttribute(NSFontAttributeName, value: kCCViewMoneyTextSmallFont, range: NSMakeRange(decimalPostion, amount.length-decimalPostion))
        }
        else {
            
            attributedAmountString.addAttribute(NSFontAttributeName, value: kCCViewMoneyTextLargeFont, range: NSMakeRange(0, amount.length))
        }
        return attributedAmountString
    }

    
    

}

