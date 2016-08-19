//
//  KNCreditCardView.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/25/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

protocol KNCreditCardViewDelegate {

    func paymentView(paymentView:KNCreditCardView, withCard card:PTKCard, isValid valid:Bool)
}

class KNCreditCardView: UIView, UITextFieldDelegate {
    
    // MARK - private variables
    var _isValidState:Bool = false;
    
    var originMonth:String?
    
    @IBOutlet weak var cardNumberField:KNTextField?
    
    @IBOutlet weak var cardExpiryMonthField:KNTextField?
    @IBOutlet weak var cardExpiryYearField:KNTextField?
    
    @IBOutlet weak var cardCVCField:KNTextField?
    
    @IBOutlet weak var cardNameField: KNTextField?
    @IBOutlet weak var cardSurnameField: KNTextField?
    @IBOutlet weak var cardSwithCreditOrDebit: UISwitch?
    
    @IBOutlet weak var cardBorderView: UIView?
    
    @IBOutlet weak var debitOnlyTextView: UITextView?
    
    @IBOutlet weak var creditLabel: UILabel?
    
    @IBOutlet weak var debitLabel: UILabel?
    
    var delegate:KNCreditCardViewDelegate?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
            
            self.setupControls()
        }
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "textFieldTextChanged:", name:UITextFieldTextDidChangeNotification, object: nil)
        
        self.cardSwithCreditOrDebit!.addTarget(self, action: "switchStateChanged:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func switchStateChanged(sender: AnyObject)
    {
        self.checkValid()
    }
    
    func setup(){
        
        _isValidState = false
    }
    
    func setupControls(){
        
        self.setup()
        
        self.cardNumberField!.setup()
        self.cardExpiryMonthField!.setup()
        self.cardExpiryYearField!.setup()
        self.cardCVCField!.setup()
        self.cardNameField!.setup()
        self.cardSurnameField!.setup()
    }
    
    func setTitileText(textColor color:UIColor?){
    
        // set no border for first & last text field
        self.cardNumberField!.setNoBorder()
        self.cardCVCField!.setNoBorder()
        self.cardExpiryMonthField!.setNoBorder()
        self.cardExpiryYearField!.setNoBorder()
        
        // set title for text field
        self.cardNumberField!.addTextForLeftView(titleText: NSLocalizedString("cardNumber", comment: ""), textColor: color)
        
        self.cardExpiryMonthField!.addTextForLeftView(titleText: NSLocalizedString("expirationDate", comment: ""), textColor: color)
        
        self.cardCVCField!.addTextForLeftView(titleText: NSLocalizedString("cvc", comment: ""), textColor: color)
        self.cardNameField!.addImageForLeft("ContactImage", leftGapOfImage: 14, widthOfImage: 20, rightGapOfImage: 20)
        self.cardSurnameField!.addImageForRight("TextFieldPlaceHolderIcon", leftGapOfImage: 0, widthOfImage: 50, rightGapOfImage: 0)
        //self.cardSwithCreditOrDebit?.on = true
    }
    
    func setCardManagementTheme() {
        
        self.cardNumberField?.setDefaultTextField()
        self.cardExpiryMonthField?.setDefaultTextField()
        self.cardExpiryYearField?.setDefaultTextField()
        self.cardCVCField?.setDefaultTextField()
        self.cardNameField?.setDefaultTextField()
        self.cardSurnameField?.setDefaultTextField()

        self.cardNumberField?.layer.borderWidth = 0
        self.cardNumberField?.setTopBorder(lineColor: nil)
        
        self.cardExpiryMonthField?.layer.borderWidth = 0
        self.cardExpiryMonthField?.setTopBorder(lineColor: nil)
        
        self.cardExpiryYearField?.layer.borderWidth = 0
        self.cardExpiryYearField?.setTopBorder(lineColor: nil)
        
        self.cardCVCField?.layer.borderWidth = 0
        self.cardCVCField?.setTopBorder(lineColor: nil)
        
        self.cardSurnameField?.layer.borderWidth = 0
        self.cardSurnameField?.setTopBorder(lineColor: nil)
        self.cardSurnameField?.autocapitalizationType = UITextAutocapitalizationType.Words      // Added by luokey
        
        self.cardNameField?.layer.borderWidth = 0
        
        self.cardBorderView?.layer.borderColor = UIColor(white:1, alpha:0.8).CGColor
        self.cardBorderView?.layer.borderWidth = 0.5
        
        self.cardNumberField?.addTextForLeftView(titleText: NSLocalizedString("cardNumber", comment: ""), textColor: nil)
        self.cardExpiryMonthField?.addTextForLeftView(titleText: NSLocalizedString("expirationDate", comment: ""), textColor: nil)
        self.cardCVCField?.addTextForLeftView(titleText: NSLocalizedString("cvc", comment: ""), textColor: nil)
        self.cardNameField?.addTextForLeftView(titleText: NSLocalizedString("Name", comment: ""), textColor: nil)
//        self.cardSurnameField?.addTextForLeftView(titleText: NSLocalizedString("Surname", comment: ""), textColor: nil)   // Marked by luokey
        self.cardSurnameField?.addTextForLeftView(titleText: NSLocalizedString("lastname", comment: ""), textColor: nil)     // Added by luokey
    }
    
    // MARK - Accessors
    
    func cardNumber() -> PTKCardNumber
    {

        return  PTKCardNumber(string:self.cardNumberField!.text)
    }
    
    func cardExpiry() -> PTKCardExpiry{
        
        var text:String = self.getMonthYear(Month: self.cardExpiryMonthField!.text, Year: self.cardExpiryYearField!.text)
        return PTKCardExpiry(string:text)
    }
    
    func cardCVC() -> PTKCardCVC {
    
        return PTKCardCVC(string:self.cardCVCField!.text)
    }
    
    func card() -> PTKCard {
    
        var card:PTKCard = PTKCard()
        card.number = self.cardNumber().string()
        card.cvc = self.cardCVC().string()
        card.expMonth = self.cardExpiry().month
        card.expYear = self.cardExpiry().year
        card.brand = self.getCardBrand()
        card.firstName = self.cardNameField?.text
        card.lastName = self.cardSurnameField?.text
        card.cardType = self.getCardType()
        return card
    }
    
    func textFieldTextChanged(sender : AnyObject) {
        /*
        THIS CAUSED THE BUG DONT KNOW WHO ADDED IT AND WHY
        var textField = (sender.object as UITextField)
        if textField == self.cardNumberField
        {
            textField.text = textField.text + " "
        }
        textField.replaceRange(UITextRange(), withText: " ")
        
        */
        self.checkValid()
    }
    
    // MARK - Delegates
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if  textField.isEqual(self.cardNumberField){
        
            return self.cardNumberFieldShouldChangeCharactersInTextField(textField, range: range, replacementString: string)
        }
        
        // Month expiry field
        if textField.isEqual(self.cardExpiryMonthField) {
            
            return self.cardExpiryMonthShouldChangeCharactersInRange(range, replacementString:string)
        }
        
        // Year expiry field
        if textField.isEqual(self.cardExpiryYearField) {
            
            // Added by luokey
            return self.cardExpiryYearShouldChangeCharactersInRange(range, replacementString:string)
            
            // Marked by luokey
            /*
            if string == ""
            {
                return true
            }
            else
            {
                if self.cardExpiryYearField!.text.length < 4
                {
                    return true
                }
                else
                {
                    return false
                }
            }
            */
        }
        
        if  textField.isEqual(self.cardCVCField){
        
            return self.cardCVCShouldChangeCharactersInTextField(textField, range: range, replacementString:string)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        // Month expiry field
        if textField.isEqual(self.cardExpiryMonthField) && self.originMonth != textField.text {
            
            textField.text = self.getFormattedMonth(Month: textField.text)
            
            var resultString:NSString = self.getMonthYear(Month: textField.text, Year: self.cardExpiryYearField!.text)
            var cardExpiry:PTKCardExpiry = PTKCardExpiry(string: resultString)
            
            
            if cardExpiry.isValid(){
            
                self.textFieldIsValid(textField)
            }else if cardExpiry.isValidLength() && !cardExpiry.isValidDate() {
                
                self.textFieldIsInvalid(textField, withErrors: true)
            }else if !cardExpiry.isValidLength() {
                
                self.textFieldIsInvalid(textField, withErrors: false)
            }
        }
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        // Month expiry field
        if textField.isEqual(self.cardExpiryMonthField) {
            self.originMonth = textField.text
        }
    }
    
    // MARK - Validations
    
    private func checkValid(){
        
        
        if self.isValid()
        {
            
            self._isValidState = true
            
            if (self.delegate != nil)
            {
                self.delegate!.paymentView(self, withCard: self.card(), isValid: true)
            }
        }
        else if !self.isValid() && self._isValidState
        {
           
           self._isValidState = false
        
            if  self.delegate != nil
            {
                self.delegate!.paymentView(self, withCard: self.card(), isValid: false)
            }
        }
        else
        {
           
        }
    }
    
    private func textFieldIsValid(textField:UITextField){
    
        self.checkValid()
    }
    
    private func textFieldIsInvalid(textField:UITextField, withErrors errors:Bool){
        
        self.checkValid()
    }
    
    // MARK - private methods
    
    private func isValid() -> Bool{
        
        return self.cardNumber().isValid() &&
            self.cardExpiry().isValid() &&
            self.cardCVC().isValidWithType(self.cardNumber().cardType) &&
            ((self.getCardType() == "debit" && self.cardNameField?.text.length>0 && self.cardSurnameField?.text.length>0) || (self.getCardType() == "credit"))
    }
    
    func cardNumberFieldShouldChangeCharactersInTextField(textField: UITextField, range: NSRange, replacementString string: NSString) -> Bool {
        
        var resultString:NSString = (self.cardNumberField!.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        resultString = PTKTextField.textByRemovingUselessSpacesFromString(resultString)
        var cardNumber:PTKCardNumber = PTKCardNumber(string: resultString)
        
        if !cardNumber.isPartiallyValid(){
            return false
        }
        
        if  string.length > 0 {
            
            self.cardNumberField!.text = cardNumber.formattedStringWithTrail()
        }else {
        
            self.cardNumberField!.text = cardNumber.formattedString()
        }
        
        if cardNumber.isValid() {
            
            self.textFieldIsValid(self.cardNumberField!)
            
            self.stateCardExpiredMonth()
        }else if cardNumber.validLength && !cardNumber.validLuhn{
            
            self.textFieldIsInvalid(self.cardNumberField!, withErrors: true)
        }else if !cardNumber.validLength{
        
            self.textFieldIsInvalid(self.cardNumberField!, withErrors: false)
        }
        
        self.checkValid()
        
        return false
        
        
    }
    
    private func cardExpiryMonthShouldChangeCharactersInRange(range:NSRange, replacementString string:NSString) -> Bool {
        
        var resultString:NSString = (self.cardExpiryMonthField!.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        resultString = self.getMonthYear(Month: resultString, Year: self.cardExpiryYearField!.text)
        
        resultString = PTKTextField.textByRemovingUselessSpacesFromString(resultString)
        var cardExpiry:PTKCardExpiry = PTKCardExpiry(string: resultString)
        
        if  !cardExpiry.isPartiallyValid(){
            
            return false
        }
        
        if countElements(cardExpiry.formattedString()) > 7 {
            return false
        }
        
        if  string.length > 0 {
            
            self.cardExpiryMonthField!.text = getMonthFromDateString(DateString: cardExpiry.formattedStringWithTrail())
        }else{
            
            self.cardExpiryMonthField!.text = getMonthFromDateString(DateString: cardExpiry.formattedString())
        }
        
        if cardExpiry.isValid(){
            
            self.textFieldIsValid(self.cardExpiryMonthField!)
        }else if cardExpiry.isValidLength() && !cardExpiry.isValidDate() {
            
            self.textFieldIsInvalid(self.cardExpiryMonthField!, withErrors: true)
        }else if !cardExpiry.isValidLength() {
            
            self.textFieldIsInvalid(self.cardExpiryMonthField!, withErrors: false)
        }
        
        if  countElements(self.cardExpiryMonthField!.text) == 2{
            
            self.stateCardExpiredYear()
        }
        
        self.checkValid()
        
        return false
    }
    
    private func cardExpiryYearShouldChangeCharactersInRange(range:NSRange, replacementString string:NSString) -> Bool {
        
        let newRange:NSRange = NSMakeRange(range.location + 3, range.length)
        
        var resultString:NSString = (self.getMonthYearForYearField() as NSString).stringByReplacingCharactersInRange(newRange, withString: string)
        
        resultString = PTKTextField.textByRemovingUselessSpacesFromString(resultString)
        var cardExpiry:PTKCardExpiry = PTKCardExpiry(string: resultString)
        
        if  !cardExpiry.isPartiallyValid(){
            
            return false
        }
        
        if countElements(cardExpiry.formattedString()) > 7 {
            return false
        }
        
        if  string.length > 0 {
            
            self.cardExpiryYearField!.text = self.getYearFromDateString(DateString: cardExpiry.formattedStringWithTrail())
        }else{
            
            self.cardExpiryYearField!.text = self.getYearFromDateString(DateString:cardExpiry.formattedString())
        }
        
        if  cardExpiry.isValid(){
            
            self.textFieldIsValid(self.cardExpiryYearField!)
        }else if cardExpiry.isValidLength() && !cardExpiry.isValidDate() {
            
            self.textFieldIsInvalid(self.cardExpiryYearField!, withErrors: true)
        }else if !cardExpiry.isValidLength() {
            
            self.textFieldIsInvalid(self.cardExpiryYearField!, withErrors: false)
        }
        
        if countElements(self.cardExpiryYearField!.text) == 4 {
            
            self.stateCardCVC()
        }
        
        self.checkValid()
        
        return false
    }
    
    private func cardCVCShouldChangeCharactersInTextField(textField: UITextField, range:NSRange, replacementString string:NSString) -> Bool{
    
        var futureText = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if futureText.length > 4
        {
            return false
        }
        else
        {
            return true
        }
        
        /*
        var resultString:NSString = (self.cardCVCField!.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        resultString = PTKTextField.textByRemovingUselessSpacesFromString(resultString)
        var cardCVC:PTKCardCVC = PTKCardCVC(string: resultString)
        var cardType:PTKCardType = PTKCardNumber(string: self.cardNumberField!.text).cardType
        
        // Restrict length
        if !cardCVC.isPartiallyValidWithType(cardType){
        
            return false
        }
        
        // Strip non-digits
        self.cardCVCField!.text = cardCVC.string()
        
        if cardCVC.isValidWithType(cardType) {
        
            self.textFieldIsValid(self.cardCVCField!)
        }else{
        
            self.textFieldIsInvalid(self.cardCVCField!, withErrors: false)
        }
        
        self.checkValid()
        
        return false
        */
    }
    
    private func getMonthYear(Month month:String, Year year:String) -> String {
    
        var text:String = month
        
        if countElements(text) == 2 {
            text = text + "/" + year
        }
        
        return text
    }
    
    private func getFormattedMonth(Month month:String) -> String{
    
        var text:String = month
        if (countElements(text) == 1) {
            
            if text == "0" || text == "1" {
                
                text = "0" + text
            }
        }
        
        return text
    }
    
    private func getMonthYearForYearField() -> String {
        
        var text:String = self.cardExpiryMonthField!.text
        
        if countElements(text) == 0 {
            
            text = NSDate().toString("MM")!
        }else if countElements(text) == 1 {
            
            text = NSDate().toString("MM")!
        }
        
        if countElements(text) == 2 {
            
            text = text + "/" + self.cardExpiryYearField!.text
        }
        
        return text
    }
    
    private func getMonthFromDateString(DateString date:String) -> String {
    
        if countElements(date) <= 2 {
            
            return date
        }else{
        
            return date.substringWithRange(Range<String.Index>(start: date.startIndex, end: advance(date.startIndex, 2)))
        }
    }
    
    private func getYearFromDateString(DateString date:String) -> String {
        
        if countElements(date) <= 3 {
            
            return ""
        }else{
            
            return date.substringWithRange(Range<String.Index>(start: advance(date.startIndex, 3), end: date.endIndex))
        }
    }
    
    func stateCardExpiredMonth() {
        
        self.cardExpiryMonthField?.becomeFirstResponder()
    }
    
    func stateCardExpiredYear() {
    
        self.cardExpiryYearField?.becomeFirstResponder()
    }
    
    func stateCardCVC() {
        
        self.cardCVCField?.becomeFirstResponder()
    }
    
    // MARK - public methods
    func getCardBrand() -> String {
        
        let cardType:PTKCardType = self.cardNumber().cardType
        var cardTypeName:String = ""
        
        switch cardType {
        
        case .Amex:
            cardTypeName = "AmEx"
            
        case .DinersClub:
            cardTypeName = "Diners"
            
        case .Discover:
            cardTypeName = "Discover"
            
        case .JCB:
            cardTypeName = "JCB"
            
        case .MasterCard:
            cardTypeName = "MasterCard"
            
        case .Visa:
            cardTypeName = "VISA"
            
        default:
            cardTypeName = ""
        }
    
        return cardTypeName
    }
    
    func getCardType()->String{
        if self.cardSwithCreditOrDebit?.on == true {
            return "debit"
        }
        else {
            return "credit"
        }
    }
}
