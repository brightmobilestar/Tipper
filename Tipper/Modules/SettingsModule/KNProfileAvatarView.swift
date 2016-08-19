//
//  KNProfileAvatarView.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/21/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

@objc protocol KNProfileAvatarViewDelegate {
    
    @objc optional func photoSelectionButtonPressed(theView view:KNProfileAvatarView)
    @objc optional func didSelectedImage(selectedImage image:UIImage)
}


class KNProfileAvatarView: UIView, KNCameraPickerViewControllerDelegate {

    // MARK - private variables
    var imagePicker:KNCameraPickerViewController?
    
    var knDelegate:KNProfileAvatarViewDelegate?
    
    @IBOutlet weak var containerView: UIView?
    
    @IBOutlet weak var profileAvatarImageButton:KNImageButton?
    
    @IBOutlet weak var profileFullNameButton: UIButton?
    
    @IBAction func photoSelectionPressed(sender: AnyObject) {
        //self.alpha = 1.0
        // Set delegate for KNCameraPickerViewController
        imagePicker!.delegate = self
        
        // use Font camera when taking profile picture
        imagePicker!.isFrontCameraUsed = true
        
        //    [imagePicker launchCamera:self];
        if let window = self.window {
            window.endEditing(true)
            imagePicker!.launchCamera(UIViewController.topViewController())
        }
        
        if  self.knDelegate != nil{
        
            self.knDelegate!.photoSelectionButtonPressed?(theView: self)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.setup()
    }
    
    func setup(){
        
        if let containerView = self.containerView {
            containerView.backgroundColor = UIColor.clearColor()
        }
        
        self.backgroundColor = UIColor.clearColor()
        
        // set font for Button
        self.setText(NSLocalizedString("addPhoto", comment: ""))
        
        // add target for UIButton
        self.profileFullNameButton!.addTarget(self, action: Selector("photoSelectionPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.allowTapAvatar()
        
        self.imagePicker = KNCameraPickerViewController()
    }

    func setText(text:String){
    
        var textFontColor:UIColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1.0)
        var textFont:UIFont = UIFont(name: kRegularFontName, size: kMediumFontSize)!
        self.profileFullNameButton!.setAttributedTitle(NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: textFontColor, NSFontAttributeName: textFont]), forState: UIControlState.Normal)
        
        self.profileFullNameButton!.setAttributedTitle(NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: textFontColor, NSFontAttributeName: textFont]), forState: UIControlState.Selected)
    }
    
    func didSelectedImage(image: UIImage!) {
        
        self.profileAvatarImageButton!.setImage(image)
        
        if  self.knDelegate != nil {
           
            self.knDelegate!.didSelectedImage!(selectedImage: image)
        }
        
        self.setText(NSLocalizedString("changePhoto", comment: ""))
    }
    
    func allowTapAvatar() {
        
        self.profileAvatarImageButton?.userInteractionEnabled = true
        self.profileAvatarImageButton?.addTarget(self, action: Selector("photoSelectionPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        
//        let tapRec = UITapGestureRecognizer()
//        tapRec.addTarget(self, action: Selector("photoSelectionPressed:"))
//        self.profileAvatarImageView!.addGestureRecognizer(tapRec)
    }
    
    
}
