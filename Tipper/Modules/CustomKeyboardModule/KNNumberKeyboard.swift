//
//  KNNumberKeyboard.swift
//  Tipper
//
//  Created by Jay N on 11/19/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

protocol KNNumberKeyboardDelegate {
    func keyboardPressNumber(character: String)
    func keyboardPressDelete()
}

class KNNumberKeyboard: UIView, UIInputViewAudioFeedback {
    
    var delegate:KNNumberKeyboardDelegate?
    @IBOutlet var numberButtons: [UIButton]?
    
    //MARK: Helpers
    class func initFromNib() -> KNNumberKeyboard! {
        return UINib(nibName:"KNNumberKeyboard", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as KNNumberKeyboard
    }
    
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle = NSBundle.mainBundle()) -> KNNumberKeyboard! {
        return UINib(nibName: nibNamed, bundle: bundle).instantiateWithOwner(nil, options: nil)[0] as? KNNumberKeyboard
    }
    
    func resizeKeyboardFollowFrame(frame: CGRect) {
        var proportion = CGRectGetWidth(frame)/CGRectGetWidth(self.frame)
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion)
        
        var frameTemp = self.frame
        frameTemp.origin.x = CGRectGetMinX(frame)
        frameTemp.origin.y = CGRectGetMaxY(frame)
        self.frame = frameTemp
        
        self.setHighLightedKeyboard()
    }
    
    func setHighLightedKeyboard() {
        var highLightBackgroundImage:UIImage = self.getImageWithColor(UIColor.lightGrayColor(), size: CGSizeMake(CGRectGetWidth(numberButtons![0].frame), CGRectGetHeight(numberButtons![0].frame)))
        
        for btn in numberButtons! {
            btn.setBackgroundImage(highLightBackgroundImage, forState: UIControlState.Highlighted)
        }
    }
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRectMake(0, 0, 100, 100))
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
  
    //MARK: IBActions
    @IBAction func characterPressed(sender: UIButton) {
        self.delegate?.keyboardPressNumber(String(sender.currentTitle!))
    }
    
    @IBAction func deletePressed(sender: AnyObject) {
        self.delegate?.keyboardPressDelete()
    }

}
