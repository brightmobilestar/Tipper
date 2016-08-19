//
//  KNMobileNumberViewController.swift
//  Tipper
//
//  Created by Jay N on 11/18/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

class KNMobileNumberViewController: KNBaseViewController, KNNumberKeyboardDelegate, UIPickerViewDataSource,UIPickerViewDelegate, UITextFieldDelegate {
    
    //MARK: IBOutlets
    @IBOutlet weak var backButton: UIBarButtonItem?
    @IBOutlet weak var nextButton: UIBarButtonItem?
    
    @IBOutlet weak var enterPhoneNumberTitleLabel: UILabel?
    
    @IBOutlet weak var flagButton: UIButton?
    @IBOutlet weak var countryLabel: UILabel?
    @IBOutlet weak var countryView: UIView?
    @IBOutlet weak var countrySelectionView: UIView?
    @IBOutlet weak var moreButton: UIButton?
    @IBOutlet weak var countryCodeTextField: UITextField?
    @IBOutlet weak var phoneNumberTextField: UITextField?
    @IBOutlet weak var hideTextField: UITextField?
    @IBOutlet weak var firstLineView: UIView?
    @IBOutlet weak var secondLineView: UIView?
    @IBOutlet weak var countryListPickerView: UIPickerView?
    @IBOutlet weak var inputAccessoryToolbar: UIToolbar?
    @IBOutlet weak var doneEditButton: UIBarButtonItem?
    
    //MARK: Contraints
    @IBOutlet weak var guideVerticalSpaceContraint: NSLayoutConstraint?
    @IBOutlet weak var countryViewHeightContraint: NSLayoutConstraint?
    @IBOutlet weak var countryViewVerticalSpaceContraint: NSLayoutConstraint?
    @IBOutlet weak var phoneNumberViewHeightContraint: NSLayoutConstraint?
    
    //MARK: Private
    private var keyboardView:KNNumberKeyboard!
//    private var mobileNumber:String = ""
    private var mobileNumberWithCountryCode: String = ""
    private var countries:[KNCountry]!
    private var checkShowCountries = false
    
    var activityViewWrapper: KNActivityViewWrapper!
    
    let phoneFormatter:KNPhoneFormatter = KNPhoneFormatter()
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityViewWrapper = KNActivityViewWrapper(parentViewController: self)
        self.activityViewWrapper.setLabelText(NSLocalizedString("sendingVerificationCode", comment: ""))
        
        self.updateContraints()
        self.layoutControls()
        
        self.countries = KNDiallingCodes.sharedInstance.getData()
        self.countryListPickerView!.selectRow(0, inComponent: 0, animated: true)
        self.pickerView(self.countryListPickerView!, didSelectRow: 0, inComponent: 0)
        
        self.phoneNumberTextField!.becomeFirstResponder()
        
        // Set localized text for UI
        self.title = NSLocalizedString("validationRequired", comment: "")
        self.nextButton?.title = NSLocalizedString("next", comment: "")
        self.enterPhoneNumberTitleLabel?.text = NSLocalizedString("enterPhoneNumberTitle", comment: "")
    }
    
    //MARK: Update Contraints
    func updateContraints() {
        var heightRate = ScreenHeight/800
        self.guideVerticalSpaceContraint!.constant *= heightRate
        self.countryViewVerticalSpaceContraint!.constant *= heightRate
        self.countryViewHeightContraint!.constant *= heightRate
        self.phoneNumberViewHeightContraint!.constant *= heightRate
        if IsIphone4 {
            self.guideVerticalSpaceContraint!.constant /= 4
            self.countryViewVerticalSpaceContraint!.constant /= 4
            self.phoneNumberViewHeightContraint!.constant /= 1.1
        }
    }
    
    func layoutControls() {
        dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
            // Layout keyboard
            self.keyboardView = KNNumberKeyboard.initFromNib()
            self.keyboardView.delegate = self
            self.keyboardView.resizeKeyboardFollowFrame(self.countryView!.frame)
            self.view.addSubview(self.keyboardView)
            
            // Change top and bottom line height
            self.firstLineView!.frame.size.height = 0.5
            self.secondLineView!.frame.size.height = 0.5
            
            let tapGesture = UITapGestureRecognizer(target: self, action: "showCountries")
            tapGesture.numberOfTapsRequired = 1
            self.countryLabel!.addGestureRecognizer(tapGesture)
        }
    }
    
    //MARK: KNNumberKeyboard Delegate
    func keyboardPressNumber(character: String) {
        if character == "." {
            return
        }
        
        var range:NSRange = NSMakeRange(self.phoneNumberTextField!.text.length, 0)
        self.textField(self.phoneNumberTextField!, shouldChangeCharactersInRange: range, replacementString: character)
        self.updateNextButtonStatus()
    }
    
    func keyboardPressDelete() {
        if self.phoneNumberTextField!.text.length > 0 {
            
            var range:NSRange = NSMakeRange(self.phoneNumberTextField!.text.length - 1, 1)
            self.textField(self.phoneNumberTextField!, shouldChangeCharactersInRange: range, replacementString: "")
            
            self.updateNextButtonStatus()
        }
    }
    
    func updateNextButtonStatus() {
        if(self.phoneFormatter.isValid()) {
            self.navigationItem.rightBarButtonItem!.enabled = true
        } else {
            self.navigationItem.rightBarButtonItem!.enabled = false
        }
    }
    
    //MARK: UIPicker Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.countries.count
    }
    
    //MARK: UIPicker Delegate
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return ScreenWidth - 50
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {

        let flagImageView:UIImageView = UIImageView(frame: CGRectMake(15, 0, 40, 40))
        flagImageView.image = UIImage(named: self.countries[row].code!)
        
        let pickerLabel = UILabel(frame: CGRectMake(75, 0, ScreenWidth - 75, 40))
        let titleData = self.countries[row].name!
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: kRegularFontName, size: 16.0)!, NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel.attributedText = myTitle
        
        let pickerItemView = UIView(frame: CGRectMake(0, 0, ScreenWidth, 40))
        pickerItemView.insertSubview(flagImageView, atIndex: 0)
        pickerItemView.insertSubview(pickerLabel, atIndex: 1)
        
        return pickerItemView
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedCountry(self.countries[row])
    }
    
    func selectedCountry(country: KNCountry) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.flagButton!.setImage(UIImage(named: country.code!), forState: UIControlState.Normal)
            self.countryLabel!.text = country.name
            if (country.diallingCode != nil) {
                self.countryCodeTextField!.text = "+\(country.diallingCode!)"
            }
            else {
                self.countryCodeTextField!.text = ""
            }
            
            self.phoneFormatter.setCountryCode(country.code!)
            self.phoneNumberTextField?.text = self.phoneFormatter.formattedPhoneNumber
        })
    }
    
    //MARK: IBActions
    @IBAction func showCountries() {
        UIView.animateWithDuration(0.05, animations: { () -> Void in
            self.countrySelectionView!.backgroundColor = UIColor.lightGrayColor()
        }) { (Bool) -> Void in
            self.countrySelectionView!.backgroundColor = UIColor.whiteColor()
        }
        self.hideTextField!.inputAccessoryView = self.inputAccessoryToolbar!
        self.countryListPickerView!.autoresizingMask = UIViewAutoresizing.None
        self.hideTextField!.inputView = self.countryListPickerView!
        if(self.checkShowCountries == false){
            self.hideTextField!.becomeFirstResponder()
            self.checkShowCountries = true
        }
    }
    
    @IBAction func goBack(sender: UIBarButtonItem) {

        KNRegistrationManager.sharedInstance.cancelRegistration(KNMobileUserManager.sharedInstance.currentEmailExistanceResponse.userId) { (success, errors) -> () in
            
        }
        
    
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func goToNext(sender: UIBarButtonItem) {
        if (!self.validatePhoneNumber(self.phoneNumberTextField!.text)) {
            return
        }
        //self.phoneFormatter.unformatNumber(self.phoneFormatter.formattedPhoneNumber)
        var phoneNumber = (self.countryCodeTextField!.text) + " " + (self.phoneFormatter.unformatNumber(self.phoneFormatter.formattedPhoneNumber) as String)
        var mobileOnly = (self.phoneFormatter.unformatNumber(self.phoneFormatter.formattedPhoneNumber) as String)
        self.activityViewWrapper.addActivityView(animateIn: true, completionHandler: nil)
        
        
        KNRegistrationManager.sharedInstance.addMobileNumberAndCountryCode(KNMobileUserManager.sharedInstance.currentEmailExistanceResponse.userId, mobile: mobileOnly  , countryCode: self.countryCodeTextField!.text) { (success, errors) -> () in
            
        
        
        
    //    KNRegistrationManager.sharedInstance.addMobileNumber(KNMobileUserManager.sharedInstance.currentEmailExistanceResponse.userId , mobile: phoneNumber) { (success, errors) -> () in
           
            self.activityViewWrapper.minimumVisibleDurationCompletionHandler({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if (success)
                    {
                        KNMobileUserManager.sharedInstance.currentEmailExistanceResponse.mobileNumber = phoneNumber
                        self.performSegueWithIdentifier("ValidationCodeSegue", sender: self)
                        self.activityViewWrapper.removeActivityView(animateOut: true, completionHandler: nil)
                    }
                    else
                    {
                        
                        self.activityViewWrapper.removeActivityView(animateOut: true, completionHandler: { (success) -> Void in
                            
                            dispatch_async(dispatch_get_main_queue(),{
                                var errorsString: String = ""
                                for error:KNAPIResponse.APIError in errors!{
                                    errorsString += (error.errorMessage + "\n")
                                }
                                KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                                    message: errorsString)
                            })
                        
                        })
                        
                    }
                    
                })
                
            })

        }
        
        /*
        
        KNAPIClientManager.sharedInstance.sendCodeToPhone(appDelegate.loggedUser!.userId!, phoneNumber: phoneNumber) { (responseObj) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                
                if(responseObj.status == kAPIStatusOk) {
                    appDelegate.loggedUser!.phoneNumber = phoneNumber
                    self.performSegueWithIdentifier("ValidationCodeSegue", sender: self)
                } else {
                    if (responseObj.errors.count > 0) {
                        KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                            message: responseObj.errors[0].errorMessage)
                    } else {
                        KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                            message: "unknownError")
                    }
                }
            })
        }
        */
        
        
    }
    
    //MARK: Validation
    func validatePhoneNumber(phoneNumber: String) -> Bool {
        if (countElements(phoneNumber) < 7) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                KNAlertStandard.sharedInstance.showAlert(self, title: "error",
                    message: "phoneNumberInvalid")
            })
            return false
        }
        return true
    }
    
    //MARK: End Editing
    @IBAction func doneEdit(sender: UIBarButtonItem) {
        if(self.checkShowCountries == true) {
            self.hideTextField!.resignFirstResponder()
            self.checkShowCountries = false
            self.phoneNumberTextField!.becomeFirstResponder()
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var touchPoint: UITouch = touches.anyObject() as UITouch
        if(CGRectContainsPoint(self.countrySelectionView!.frame, touchPoint.locationInView(self.view)) == false && self.checkShowCountries == true) {
            self.hideTextField!.resignFirstResponder()
            self.checkShowCountries = false
            self.phoneNumberTextField!.becomeFirstResponder()
        }
    }
    
    //MARK: UITextField Delegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        // Hide keyboard, but show blinking cursor
        if(textField == self.phoneNumberTextField!){
            self.hideTextField!.resignFirstResponder()
            self.checkShowCountries = false
            let dummyView = UIView(frame: CGRectZero)
            self.phoneNumberTextField!.inputView = dummyView
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.phoneNumberTextField {
            
            if self.phoneNumberTextField?.text.length == 0 {
            
                self.phoneFormatter.resetPhoneNumber()
            }
            
            var phoneNumberHasChanged:Bool = self.phoneFormatter.phoneNumberMustChangeInRange(range, replacementString: string)
            
            if  phoneNumberHasChanged == true {
            
                textField.text = self.phoneFormatter.formattedPhoneNumber
            }
            
            return false
        }
        
        return true
    }
}
