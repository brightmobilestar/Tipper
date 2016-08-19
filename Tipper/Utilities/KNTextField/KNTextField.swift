//
//  KNTextField.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/18/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

@objc protocol KNTextFieldDelegate{

    @objc optional func didTouchRightButton(sender:AnyObject?)
    @objc optional func didTouchLeftButton(sender:AnyObject?)
}

class KNTextField: UITextField {
    
    var knDelegate:KNTextFieldDelegate?
    
    let kLeftMargin:CGFloat =        14.0
    var kDefaultBorderWidth:CGFloat = 0.5
    let kDefaultBorderColor:UIColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.8)
    
    var textField:UITextField?
    var keyboardAnimationDisabled = false
    var required:Bool = false
    var toolbar:UIToolbar?
    var scrollView:UIScrollView?
    var isDateField:Bool = false
    var isEmailField:Bool = false
    var isPublicName:Bool = false
    var isNubmerOfCharacter:Bool = false
    
    var keyboardIsShown:Bool = false;
    var keyboardSize:CGSize = CGSize();
    var isKeyboardHeightCalculated:Bool = false;
    
    // setToolbarCommand
    var isToolBarCommand:Bool = false;
    
    // setDoneCommand
    var isDoneCommand:Bool = false;
    
    var previousBarButton:UIBarButtonItem?
    var nextBarButton:UIBarButtonItem?
    var textFields:NSMutableArray?
    
    var bottomBorderView:UIView?
    var topBorderView:UIView?
    
    var tableViewContainer:UITableView?
    
    var placeHolderTemp: NSString? = ""
    var placeHolderColor: UIColor = UIColor.whiteColor()
    
    var initialCenterAlignmentCaretRect: CGRect?
    
    var creditCardNumberSpacing = false
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    required override init() {
        super.init()
        self.setup()

    }
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        self.setup()
        
    }
    
    //MARK initializers to setup
       
    func setDefaultTextFieldWithPlaceHolder(placeholder:String){
        setPlaceholderText(placeholder)
        setDefaultTextField()
    }
    
    func setDefaultTextField(){
    
        // Set font for text
        var textFontColor:UIColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1.0)
//        var textFont:UIFont = UIFont(name: kRegularFontName, size: kMediumFontSize)!
        self.textColor = textFontColor
//        self.font = textFont
        
        // Set font for placeholder
        var placeholderFontColor:UIColor = UIColor.whiteColor()
        var placeholderFont:UIFont = self.font //  UIFont(name: kLightFontName, size: kMediumFontSize)!
        let placeholderFontDic:NSDictionary = [NSForegroundColorAttributeName:placeholderFontColor, NSFontAttributeName: placeholderFont];
        
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: placeholderFontDic)
        
        // set color for cursor
        self.tintColor = UIColor.whiteColor()
        
        // clear back color
        self.backgroundColor = UIColor.clearColor()
        
        // set border
        self.layer.borderColor = kDefaultBorderColor.CGColor
        self.layer.borderWidth = kDefaultBorderWidth //0.5
        
        self.placeholder = self.placeHolderTemp? == nil ? " " : self.placeHolderTemp
        self.placeHolderColor = placeholderFontColor
    }
    
    func spinLeftImageView() {
        
        var rotationAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = M_PI
        rotationAnimation.duration = 0.15
        rotationAnimation.cumulative = true
        rotationAnimation.repeatCount = 2
        self.leftView?.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
        
    }
    
    func setup(){
        if IsIphone6Plus {
            self.kDefaultBorderWidth = 1
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldDidBeginEditing:"), name: UITextFieldTextDidBeginEditingNotification, object: self)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldDidEndEditing:"), name:UITextFieldTextDidEndEditingNotification, object: self)
        
        self.toolbar = UIToolbar()
        toolbar!.frame = CGRectMake(0, 0, ScreenWidth, 44)
        
        // set style
        self.toolbar!.barStyle = UIBarStyle.Default
        
        let previousButtonTitle = NSLocalizedString("previous", comment: "")
        self.previousBarButton = UIBarButtonItem(title: previousButtonTitle, style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("previousButtonIsClicked:"))

        let nextButtonTitle = NSLocalizedString("next", comment: "")
        self.nextBarButton = UIBarButtonItem(title: nextButtonTitle, style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("nextButtonIsClicked:"))
        
        let flexBarButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        
        let doneBarButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("doneButtonIsClicked:"))

        
        let barButtonItems:NSArray = [self.previousBarButton!, self.nextBarButton!, flexBarButton, doneBarButton];
        
        self.toolbar!.items = barButtonItems;
        
        self.textFields = NSMutableArray();
        
        if self.superview is UIScrollView && self.scrollView == nil{
            
            self.scrollView = self.superview as? UIScrollView
        }
        
        if let superview = self.superview {
            self.markTextFieldsWithTagInView(superview)
        }
        
        // Add text align for text field
        self.addTextPadding()
        
        self.placeHolderTemp = self.placeholder? == nil ? " " : self.placeholder
        self.attributedPlaceholder = NSAttributedString(string: self.placeHolderTemp!,
            attributes:[NSForegroundColorAttributeName: self.placeHolderColor])
        
        if(self.backgroundColor != UIColor.clearColor()){
            self.placeHolderColor = UIColor(red: 127.0/255.0, green: 127.0/255.0, blue: 127.0/255.0, alpha: 0.8)
        }
 
    }
    
    func setNoBorder(){
    
        self.layer.borderWidth = 0.0
    }
    func setPlaceholderText(placeholderString:String){
        
        self.placeholder = placeholderString
        self.placeHolderTemp = self.placeholder? == nil ? " " : self.placeholder
        
        if(self.backgroundColor != UIColor.clearColor()){
            self.placeHolderColor = UIColor(red: 127.0/255.0, green: 127.0/255.0, blue: 127.0/255.0, alpha: 0.8)
        }
    }
    func setAsWhiteLabel(){
        
        // Set font for text
        var textFontColor:UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        //var textFont:UIFont = UIFont(name: kRegularFontName, size: kMediumFontSize)!
        self.textColor = textFontColor
        //self.font = textFont
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8).CGColor
        self.layer.borderWidth = 0.5
    }
    
    func setAsBigWhiteLabel(){
    
    }
    
    func markTextFieldsWithTagInView(view:UIView){
    
        var index = 0;
        if self.textFields!.count == 0 {
            for subView in view.subviews {
                if subView.isKindOfClass(KNTextField){
                    var textFieldTmp:KNTextField = subView as KNTextField
                    textFieldTmp.tag = index
                    self.textFields!.addObject(textFieldTmp)
                    index++
                }
            }
        }
    }
    
    func doneButtonIsClicked(sender:AnyObject){
    
        self.isDoneCommand = true
        self.resignFirstResponder()
        self.isToolBarCommand = true
    }

    func keyboardDidShow(notification:NSNotification){
        
        if self.textField == nil {
            
            return
        }
        
        if !((self.textField?.isKindOfClass(KNTextField)) != nil){
        
            return
        }
        
        let notificationInfo = notification.userInfo! as Dictionary
        let finalKeyboardFrame = notificationInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        let keyboardAnimationDuration: NSTimeInterval = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as Double
        let keyboardAnimationCurveNumber = notificationInfo[UIKeyboardAnimationCurveUserInfoKey] as UInt
        let animationOptions = UIViewAnimationOptions(keyboardAnimationCurveNumber << 16)
        
        self.keyboardSize = finalKeyboardFrame.size
        
        if self.keyboardAnimationDisabled == false
        {
            if self.getKeyboardIsShown() == false {
                
                if self.superview is UIScrollView {
                    
                    UIView.animateWithDuration(keyboardAnimationDuration, delay: 0, options: animationOptions, animations: { () -> Void in
                        
                        self.calculateKeyboardHeightForScrollViewForStatus(keyboardIsShown: true)
                        self.scrollToField(false)
                        }, completion: nil)
                    
                } else{
                    
                    var contentInsets:UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, self.keyboardSize.height, 0.0);
                    
                    self.tableViewContainer?.contentInset =  contentInsets;
                    
                    if isIOS8OrHigher() == true {
                        
                        self.superview!.layoutMargins = contentInsets
                    }
                }
            }else{
                
                if self.superview is UIScrollView {
                    self.scrollToField(true)
                }
            }
            
            self.setKeyboardStatusTo(hidden: true)
            self.keyboardIsShown = true
        }
        
        
        
    }
    
    func keyboardWillHide(notification:NSNotification){
        
        var info:NSDictionary = notification.userInfo!
        var duration:NSTimeInterval = info.valueForKey(UIKeyboardAnimationDurationUserInfoKey)!.doubleValue
        

        UIView.animateWithDuration(duration, animations: { () -> Void in
            if self.isDoneCommand || true{
                
                if self.superview is UIScrollView {
                    self.scrollView!.setContentOffset(CGPointMake(0, 0), animated: false)
                }
            }
        })
        
        
        // resize frame for scroll view
        if  self.getKeyboardIsShown() == true {
        
            if self.superview is UIScrollView {
                
                calculateKeyboardHeightForScrollViewForStatus(keyboardIsShown: false)
            } else {
            
                var contentInsets:UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
                self.tableViewContainer?.contentInset =  contentInsets
            }
        }
        
        self.setKeyboardStatusTo(hidden: true)
        self.keyboardIsShown = false
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification, object: self)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification , object: self)

    }
    
    func nextButtonIsClicked(sender:AnyObject?){
        
        var tagIndex:NSInteger = self.tag
        var textField:KNTextField = self.textFields!.objectAtIndex(++tagIndex) as KNTextField
        
        while !textField.enabled && tagIndex < self.textFields!.count{
        
            textField = self.textFields!.objectAtIndex(++tagIndex) as KNTextField
        }
        
        self.becomeActive(textField)
    }
    
    func previousButtonIsClicked(sender:AnyObject?){
        
        var tagIndex:NSInteger = self.tag
        var textField:KNTextField = self.textFields!.objectAtIndex(--tagIndex) as KNTextField
        while !textField.enabled && tagIndex < self.textFields!.count{
        
            textField = self.textFields!.objectAtIndex(--tagIndex) as KNTextField
        }
        
        self.becomeActive(textField)
    }
    
    func becomeActive(textField:UITextField){
    
        self.isToolBarCommand = true
        textField.becomeFirstResponder()
    }
    
    func setBarButtonNeedsDisplayAtTag(tag:Int){
    
        var previousBarButtonEnabled:Bool = false
        var nexBarButtonEnabled:Bool = false
        
        for var index = 0; index < self.textFields!.count; index++ {
            
            var textField:UITextField = self.textFields!.objectAtIndex(index) as KNTextField
            if  index < tag {
                
                previousBarButtonEnabled |= textField.enabled
            }else if index > tag {
                
                nexBarButtonEnabled |= textField.enabled
            }
        }
        
        self.previousBarButton!.enabled = previousBarButtonEnabled
        self.nextBarButton!.enabled = nexBarButtonEnabled
    }
    
    func selectInputView(textField:UITextField){
        
        if self.isDateField {
            
            var datePicker:UIDatePicker = UIDatePicker()
            datePicker.datePickerMode = UIDatePickerMode.Date
            datePicker.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
            
            if !textField.text.isEmpty {
                
                var dateFormatter:NSDateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd/YY"
                dateFormatter.timeZone = NSTimeZone.localTimeZone()
                dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
            }
            
            textField.inputView = datePicker
        }
    }
    
    func datePickerValueChanged(sender:AnyObject?){
    
        var datePicker:UIDatePicker = sender as UIDatePicker
        var selectedDate:NSDate = datePicker.date
        var dateFormatter:NSDateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "MM/dd/YY"
        self.textField!.text = dateFormatter.stringFromDate(selectedDate)
        
        self.validate()
    }
    
    func scrollToField(animated:Bool){
    
        if self.textField == nil {
        
            return
        }
        
        var textFieldRect:CGRect = self.textField!.frame
        var aRect:CGRect = MAIN_SCREEN.bounds
        aRect.origin.y = -self.scrollView!.contentOffset.y
        
        var toolbarHeight:CGFloat = self.toolbar!.frame.size.height
        if  self.toolbar?.hidden == true {
        
            toolbarHeight = 0
        }
        
        aRect.size.height -= self.keyboardSize.height + toolbarHeight
        
        var textRectBoundary:CGPoint = CGPointMake(textFieldRect.origin.x, textFieldRect.origin.y + textFieldRect.size.height + 20)
        
        if !CGRectContainsPoint(aRect, textRectBoundary) || self.scrollView!.contentOffset.y > 0 {
        
            var scrollPoint:CGPoint = CGPointMake(0.0, self.superview!.frame.origin.y + self.textField!.frame.origin.y + 20  /*+ self.textField!.frame.size.height*/ - aRect.size.height)
            if  scrollPoint.y < 0 {
                scrollPoint.y = 0
            }
            
            self.scrollView!.setContentOffset(scrollPoint, animated: animated)
        }
    }
    
    func validate() -> Bool{
    
        //self.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.5)
        
        if self.required && self.text.isEmpty {
            
            return false
        }else if self.isEmailField {
        
            return KNHelperManager.sharedInstance.isValidEmail(self.text)
        }else if self.isPublicName {
            
            return KNHelperManager.sharedInstance.isValidPublicName(self.text)
        }else if self.isNubmerOfCharacter {
            return KNHelperManager.sharedInstance.isValidNumberOfCharacter(self.text, minCharacter: 5, maxCharacter: 20)
        }
        
        //self.backgroundColor = UIColor.whiteColor()
        
        return true
    }
    
    func setEnabled(enabled:Bool){
    
        super.enabled = enabled
        if !enabled {
            
            self.backgroundColor = UIColor.lightGrayColor()
        }
    }
    
    // MARK - set image for right view of text field
    func addImageForLeftOrRightViewWithImage(leftImage leftImageName: String, rightImage rightImageName: String){
    
        var scaleSize:CGSize = CGSizeMake(self.frame.size.height, self.frame.size.height)
        
        if !leftImageName.isEmpty {
            
            self.leftViewMode = UITextFieldViewMode.Always
            var leftImage:UIImage? = UIImage(named: leftImageName)
            
            UIGraphicsBeginImageContextWithOptions(scaleSize, false, 0.0)
            leftImage!.drawInRect(CGRectMake(0, 0, scaleSize.width, scaleSize.height))
            var resizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            var leftView:UIView = UIView()
            leftView.frame = CGRectMake(0, 0, scaleSize.width, scaleSize.height)
            var imagev:UIImageView = UIImageView(image: resizedImage)
            
            leftView.addSubview(imagev)
            
            self.leftView = leftView
        }
        
        if  !rightImageName.isEmpty {
        
            self.rightViewMode = UITextFieldViewMode.Always
            var rightImage:UIImage? = UIImage(named: rightImageName)
            
            UIGraphicsBeginImageContextWithOptions(scaleSize, false, 0.0)
            rightImage!.drawInRect(CGRectMake(0, 0, scaleSize.width, scaleSize.height))
            var resizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            var rightView:UIView = UIView()
            rightView.frame = CGRectMake(0, 0, scaleSize.width, scaleSize.height)
            var imagev:UIImageView = UIImageView(image: resizedImage)
            
            rightView.addSubview(imagev)
            
            self.rightView = rightView
        }
    }
    
    func addLeftImage(leftImage lImage:UIImage?, gapNextImage:CGFloat){
        var scaleSize:CGSize = CGSizeMake(self.frame.size.height, self.frame.size.height)
        
        if lImage != nil {
            
            self.leftViewMode = UITextFieldViewMode.Always
            var leftImage:UIImage? = lImage
            
            UIGraphicsBeginImageContextWithOptions(scaleSize, false, 0.0)
            leftImage!.drawInRect(CGRectMake(0, 0, scaleSize.width, scaleSize.height))
            var resizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            var leftView:UIView = UIView()
            leftView.frame = CGRectMake(0, 0, scaleSize.width + gapNextImage, scaleSize.height)
            var imagev:UIImageView = UIImageView(image: resizedImage)
            
            leftView.addSubview(imagev)
            
            self.leftView = leftView
        }
    }
    
    // leftImage: resource name of left image,
    // widthOfLeftImage: width of left image, used to specify width of left image, height will be equal to self frame height
    // rightImage: resource name of right image,
    // widthOfRightImage: width of right image
    func addImageForLeftOrRightViewWithImage(leftImage leftImageName: String, widthOfLeftImage : CGFloat, rightImage rightImageName: String, widthOfRightImage : CGFloat){
        
        var scaleSize:CGSize = CGSizeMake(widthOfLeftImage, widthOfLeftImage)
        
        if !leftImageName.isEmpty {
            
            self.leftViewMode = UITextFieldViewMode.Always
            var leftImage:UIImage? = UIImage(named: leftImageName)
            
            var leftView:UIView = UIView()
            leftView.frame = CGRectMake(0, 0, scaleSize.width, self.frame.size.height)
            var imagev:UIImageView = UIImageView(image: leftImage)
            imagev.frame = leftView.frame
            imagev.contentMode = .Center
            
            leftView.addSubview(imagev)
            
            self.leftView = leftView
        }
        
        if  !rightImageName.isEmpty {
            
            self.rightViewMode = UITextFieldViewMode.Always
            var rightImage:UIImage? = UIImage(named: rightImageName)
            
            UIGraphicsBeginImageContextWithOptions(scaleSize, false, 0.0)
            rightImage!.drawInRect(CGRectMake(0, 0, scaleSize.width, scaleSize.height))
            var resizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            var rightView:UIView = UIView()
            rightView.frame = CGRectMake(0, 0, scaleSize.width, self.frame.size.height)
            var imagev:UIImageView = UIImageView(image: resizedImage)
            imagev.contentMode = .Center
            
            rightView.addSubview(imagev)
            
            self.rightView = rightView
        }
    }
    
    func addImageFor(leftImage lImage:UIImage?, rightImage rImage:UIImage?){
        
        var scaleSize:CGSize = CGSizeMake(self.frame.size.height, self.frame.size.height)
        
        if lImage != nil {
            
            self.leftViewMode = UITextFieldViewMode.Always
            var leftImage:UIImage? = lImage
            
            UIGraphicsBeginImageContextWithOptions(scaleSize, false, 0.0)
            leftImage!.drawInRect(CGRectMake(0, 0, scaleSize.width, scaleSize.height))
            var resizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            var leftView:UIView = UIView()
            leftView.frame = CGRectMake(0, 0, scaleSize.width, scaleSize.height)
            var imagev:UIImageView = UIImageView(image: resizedImage)
            
            leftView.addSubview(imagev)
            
            self.leftView = leftView
        }
        
        if  rImage != nil {
            
            self.rightViewMode = UITextFieldViewMode.Always
            var rightImage:UIImage? = rImage
            
            UIGraphicsBeginImageContextWithOptions(scaleSize, false, 0.0)
            rightImage!.drawInRect(CGRectMake(0, 0, scaleSize.width, scaleSize.height))
            var resizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            var rightView:UIView = UIView()
            rightView.frame = CGRectMake(0, 0, scaleSize.width, scaleSize.height)
            var imagev:UIImageView = UIImageView(image: resizedImage)
            
            rightView.addSubview(imagev)
            
            self.rightView = rightView
        }
    }
    
    // MARK - add button for right view with title and image
    func addButtonForRightView(titleText title:String, imageName image:String){
        
        var scaleSize:CGSize = CGSizeMake(self.frame.size.height, self.frame.size.height)
        let button   = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.frame = CGRectMake(0, 0, scaleSize.width, scaleSize.height)
        
        if image.isEmpty == false {
            
            self.rightViewMode = UITextFieldViewMode.Always
            
            var rightImage:UIImage? = UIImage(named: image)
            
            UIGraphicsBeginImageContextWithOptions(scaleSize, false, 0.0)
            rightImage!.drawInRect(CGRectMake(0, 0, scaleSize.width, scaleSize.height))
            var resizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            button.setImage(resizedImage, forState: .Normal)
            button.addTarget(self, action: Selector("rightButtonPressed:"), forControlEvents:.TouchUpInside)
            
            self.rightView = button
        }else if title.isEmpty == false {
            
            self.rightViewMode = UITextFieldViewMode.Always
            button.setTitle(title, forState: UIControlState.Normal)
            button.addTarget(self, action: Selector("rightButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
            
            self.rightView = button
        }
    }
    
    // MARK - add button for left view with title and image
    func addButtonForLeftView(titleText title:String, imageName image:String){
        
        var scaleSize:CGSize = CGSizeMake(self.frame.size.height, self.frame.size.height)
        let button   = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.frame = CGRectMake(0, 0, scaleSize.width, scaleSize.height)
        
        if image.isEmpty == false {
            
            self.leftViewMode = UITextFieldViewMode.Always
            
            var leftImage:UIImage? = UIImage(named: image)
            
            UIGraphicsBeginImageContextWithOptions(scaleSize, false, 0.0)
            leftImage!.drawInRect(CGRectMake(0, 0, scaleSize.width, scaleSize.height))
            var resizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            button.setImage(resizedImage, forState: .Normal)
            button.addTarget(self, action: Selector("leftButtonPressed:"), forControlEvents:.TouchUpInside)
            
            self.leftView = button
        }else if title.isEmpty == false {
            
            self.leftViewMode = UITextFieldViewMode.Always
            button.setTitle(title, forState: UIControlState.Normal)
            button.addTarget(self, action: Selector("leftButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
            
            self.leftView = button
        }
    }
    
    // MARK - add text for right view
    func addTextForLeftView(titleText title:String, textColor color:UIColor?){
        
        if  !title.isEmpty {
            
            self.leftViewMode = UITextFieldViewMode.Always
            
            // get tilte length in pixel
            var titleFont:UIFont = UIFont(name: kRegularFontName, size: kMediumFontSize)!
            var titleLabel:UILabel = UILabel()
            titleLabel.font = titleFont
            
            if  color == nil {
                
                titleLabel.textColor = kTextColor
            }else{
            
                titleLabel.textColor = color
            }
            
            titleLabel.text = title
            
            // get frame for label
            let fAlignText:CGFloat = kLeftMargin
            let fWidth:CGFloat = self.getTextLengthInPixel(title, font: titleFont)
            var frame:CGRect = CGRectMake(fAlignText, 0, fWidth + fAlignText, CGRectGetHeight(self.frame))
            titleLabel.frame = frame
            
            
            var vContainerView:UIView = UIView(frame: CGRectMake(0, 0, fWidth + 2 * fAlignText,  CGRectGetHeight(self.frame)))
            
            vContainerView.addSubview(titleLabel)
            
            self.leftView = vContainerView
        }
    }
    
    func rightButtonPressed(sender:AnyObject?){
        
        if  self.knDelegate != nil && self.knDelegate!.didTouchRightButton != nil {
            
            self.knDelegate!.didTouchRightButton!(self)
        }
    }
    
    func leftButtonPressed(sender:AnyObject?){
        
        if  self.knDelegate != nil && self.knDelegate!.didTouchLeftButton != nil {
            
            self.knDelegate!.didTouchLeftButton!(self)
        }
    }
    
    func setBottomBorder(lineColor color:UIColor?){
    
        if self.bottomBorderView == nil {
        
            self.bottomBorderView = UIView(frame: CGRectMake(1,
                self.frame.size.height - kDefaultBorderWidth,
                self.frame.size.width-2,
                kDefaultBorderWidth))
            
            if  color != nil {
                
                self.bottomBorderView?.backgroundColor = color
            }else{
            
                self.bottomBorderView?.backgroundColor = kDefaultBorderColor
            }
            
            self.addSubview(self.bottomBorderView!)
        }
    }
    
    func setTopBorder(lineColor color:UIColor?){
    
        if self.topBorderView == nil {
        
            self.topBorderView = UIView(frame: CGRectMake(1, kDefaultBorderWidth, self.frame.size.width-2, kDefaultBorderWidth))
            
            if  color != nil {
                
                self.topBorderView?.backgroundColor = color
            }else{
                
                self.topBorderView?.backgroundColor = kDefaultBorderColor
            }
            
            self.addSubview(self.topBorderView!)
        }
    }
    
    func setCustomTopBorder(lineColor color:UIColor?)
    {
        if self.topBorderView == nil {
            
            self.topBorderView = UIView(frame: CGRectMake(73, kDefaultBorderWidth, self.frame.size.width-2, kDefaultBorderWidth))
            
            if  color != nil {
                
                self.topBorderView?.backgroundColor = color
            }else{
                
                self.topBorderView?.backgroundColor = kDefaultBorderColor
            }
            
            self.addSubview(self.topBorderView!)
        }
    }
    
    // MARK - private methods
    private func getTextLengthInPixel(text:String, font:UIFont) -> CGFloat{
    
        var tempLabel:UILabel = UILabel()
        tempLabel.text = text
        tempLabel.font = font
        tempLabel.numberOfLines = 1
        var maximumLabelSize:CGSize = CGSizeMake(200, 9999)
        
        var expectedSize:CGSize = tempLabel.sizeThatFits(maximumLabelSize)
        
        return expectedSize.width
    }
    
    private func addTextPadding(){
    
        self.rightViewMode = UITextFieldViewMode.Always
        self.leftViewMode = UITextFieldViewMode.Always
        
        let paddingView:UIView = UIView(frame: CGRectMake(0, 0, kLeftMargin, CGRectGetHeight(self.frame)))
        self.leftView = paddingView
        self.rightView = paddingView
    }
    
    private func getKeyboardIsShown() -> Bool{
    
        for var i = 0; i < self.textFields!.count; ++i {
        
            var tf:KNTextField = self.textFields!.objectAtIndex(i) as KNTextField
            if tf.keyboardIsShown {
                return true
            }
        }
        
        return false
    }
    
    private func setKeyboardStatusTo(hidden isHidden:Bool){
        
        for var i = 0; i < self.textFields!.count; ++i {
         
            var tf:KNTextField = self.textFields!.objectAtIndex(i) as KNTextField
            tf.keyboardIsShown = !isHidden
        }
    }
    
    private func calculateKeyboardHeightForScrollViewForStatus(keyboardIsShown isShown:Bool){
    
        if isShown == true {
            
            var bkgndSize:CGSize = self.scrollView!.contentSize;
            bkgndSize.height += self.keyboardSize.height
            self.scrollView!.contentSize = bkgndSize
            
            self.isKeyboardHeightCalculated = true
        }else {
        
            for var i = 0; i < self.textFields!.count; ++i {
                
                var tf:KNTextField = self.textFields!.objectAtIndex(i) as KNTextField
                
                if (tf.isKeyboardHeightCalculated == true) {
                    
                    var bkgndSize:CGSize = self.scrollView!.contentSize;
                    bkgndSize.height -= tf.keyboardSize.height
                    self.scrollView!.contentSize = bkgndSize
                    tf.isKeyboardHeightCalculated = false
                }
            }
        }
    }
    
    //MARK: - Add image with gaps
    
    // Add imageView to left, with gaps
    func addImageForLeft(imageName: String, leftGapOfImage : CGFloat, widthOfImage : CGFloat,  rightGapOfImage : CGFloat){
        
        
        if !imageName.isEmpty {
            
            let leftView = prepareImageViewWithGaps(imageName, leftGapOfImage: leftGapOfImage, widthOfImage: widthOfImage, rightGapOfImage: rightGapOfImage)
            
            self.leftView = leftView
        }
    }
    
    // Add imageView to right with gaps
    func addImageForRight(imageName:String, leftGapOfImage : CGFloat, widthOfImage : CGFloat,  rightGapOfImage : CGFloat){
        if !imageName.isEmpty {
            
            let rightView = prepareImageViewWithGaps(imageName, leftGapOfImage: leftGapOfImage, widthOfImage: widthOfImage, rightGapOfImage: rightGapOfImage)
            
            self.rightView = rightView
        }
    }
    
    // Make image view with gaps
    func prepareImageViewWithGaps(imageName: String, leftGapOfImage : CGFloat, widthOfImage : CGFloat,  rightGapOfImage : CGFloat) -> UIView{
        let view = UIView()
        view.backgroundColor = self.backgroundColor
        
        let leftGapView = UIView()
        leftGapView.frame = CGRectMake(0, 0, leftGapOfImage, self.frame.size.height)
        leftGapView.backgroundColor = self.backgroundColor
        
        let imageView = UIImageView()
        imageView.frame = CGRectMake(leftGapOfImage, 0, widthOfImage, self.frame.size.height)
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .Center
        
        let rightGapView = UIView()
        rightGapView.frame = CGRectMake(leftGapOfImage + widthOfImage, 0, rightGapOfImage, self.frame.size.height)
        rightGapView.backgroundColor = self.backgroundColor
        
        view.addSubview(leftGapView)
        view.addSubview(imageView)
        view.addSubview(rightGapView)
        
        view.frame = CGRectMake(0, 0, leftGapOfImage + widthOfImage + rightGapOfImage, self.frame.size.height)
        
        return view
    }
    
    override func caretRectForPosition(position: UITextPosition!) -> CGRect
    {
        let superReturnPosition = super.caretRectForPosition(position)
        
        if self.textAlignment == NSTextAlignment.Center
        {
            if self.initialCenterAlignmentCaretRect == nil
            {
                self.initialCenterAlignmentCaretRect = superReturnPosition
                return superReturnPosition
            }
            else
            {
                if superReturnPosition.origin.x < self.initialCenterAlignmentCaretRect!.origin.x && self.text == ""
                {
                    return self.initialCenterAlignmentCaretRect!
                }
                else
                {
                    return superReturnPosition
                }
            }
        }
        else
        {
            return superReturnPosition
        }

    }
    
    // MARK: - UITextField notifications
    func textFieldDidBeginEditing(notification:NSNotification){
        
        var textField:UITextField = notification.object as UITextField
        self.textField = textField
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        self.setBarButtonNeedsDisplayAtTag(textField.tag)
        
        if self.superview is UIScrollView && self.scrollView == nil{
            
            self.scrollView = self.superview as? UIScrollView
        }
        
        self.selectInputView(textField)
        self.inputAccessoryView = self.toolbar
        self.isDoneCommand = false
        self.isToolBarCommand = false
        self.attributedPlaceholder = NSAttributedString(string: " ",
            attributes:[NSForegroundColorAttributeName: UIColor.clearColor()])
        
    }
    
    func textFieldDidEndEditing(notification:NSNotification){
        var textField:UITextField = notification.object as UITextField
        
        self.validate()
        
        self.textField = nil
        
        if  self.isDateField && textField.text.isEmpty && self.isDoneCommand {
        
            var dateFormatter:NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd/YY"
            textField.text = dateFormatter.stringFromDate(NSDate())
        }
        var placeholderFontColor:UIColor = self.placeHolderColor
        //var placeholderFont:UIFont = UIFont(name: kLightFontName, size: kMediumFontSize)!
        let placeholderFontDic:NSDictionary = [NSForegroundColorAttributeName:placeholderFontColor];//, NSFontAttributeName: placeholderFont];
        self.attributedPlaceholder = NSAttributedString(string: self.placeHolderTemp!,
            attributes:placeholderFontDic)
        //self.scrollView?.scrollEnabled = false
    }
}
