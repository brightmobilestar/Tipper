//
//  KNEditImageViewController.swift
//  Tipper
//
//  Created by Jay N on 12/18/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

@objc protocol KNEditImageViewControllerDelegate {
    @objc optional func didUseCroppeAvatar(image: UIImage?)
}

class KNEditImageViewController: UIViewController {
    
    @IBOutlet weak var ImageScrollView: UIScrollView?
    @IBOutlet weak var controlToolbar: UIToolbar?
    @IBOutlet weak var btnRetake: UIButton?
    @IBOutlet weak var btnUse: UIButton?
    @IBOutlet weak var EditImageView: UIImageView?
    
    var EditImageView1: UIImageView?
    var cropAreaButton: UIButton?
    var lastLocation: CGPoint?
    
    var rawImage:UIImage?
    var knDelegate: KNEditImageViewControllerDelegate?
    
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.navigationController?.respondsToSelector(Selector("interactivePopGestureRecognizer")) != nil) {
            self.navigationController?.interactivePopGestureRecognizer.enabled = false;
        }
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        self.layoutScrollView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        println("EditImageView frmae = \(self.EditImageView?.frame) \(self.ImageScrollView?.frame)")
    }
    
    // MARK: IBActions
    @IBAction func retakeAvatarPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func useAvatarPressed(sender: AnyObject) {
        
        dispatch_after(2, dispatch_get_main_queue()) { () -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        self.cropAreaButton!.layer.borderWidth = 0
        self.knDelegate?.didUseCroppeAvatar!(self.captureImageInRect(self.cropAreaButton!.frame))
    }
    
    // MARK: Crop Image
    func captureImageInRect(captureFrame: CGRect) -> UIImage {
        let layer = self.view.layer
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        layer.renderInContext(UIGraphicsGetCurrentContext())
        let viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContext(CGSizeMake(captureFrame.size.width - 1, captureFrame.size.height - 1))
        let context = UIGraphicsGetCurrentContext()
        
        // translated rectangle for drawing sub image
        let drawRect = CGRectMake(-captureFrame.origin.x, -captureFrame.origin.y, viewImage.size.width,viewImage.size.height)
        
        CGContextClipToRect(context,
            CGRectMake(0, 0,
            captureFrame.size.width,
            captureFrame.size.height)
        )
        
        viewImage.drawInRect(drawRect)
        
        // grab image
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return croppedImage
    }
}


// MARK: - Ajust ScrollView
extension KNEditImageViewController: UIScrollViewDelegate {
    
    func layoutScrollView() {
        
        
        // Marked by luokey
        /*
        let rawImage = KNImageProcessor(image: self.rawImage!).resize(CGSize(width: ScreenWidth, height: ScreenHeight - CGRectGetHeight(self.controlToolbar!.frame)), fitMode: KNImageProcessor.Resize.FitMode.Clip).image
        self.EditImageView = UIImageView(image: rawImage)
        
        self.EditImageView!.frame = CGRect(origin: CGPoint(x: 0, y: 0), size:rawImage.size)
        self.ImageScrollView!.addSubview(self.EditImageView!)
        self.ImageScrollView!.contentSize = rawImage.size
        
        // Change image view scale
        let scaleWidth = CGRectGetWidth(self.ImageScrollView!.frame) / self.rawImage!.size.width
        let scaleHeight = CGRectGetHeight(self.ImageScrollView!.frame) / self.rawImage!.size.height
        
        let minScale = min(scaleWidth, scaleHeight);
        self.ImageScrollView!.minimumZoomScale = minScale;
        self.ImageScrollView!.maximumZoomScale = 2.0
        
        self.automaticallyAdjustsScrollViewInsets = false
        centerScrollViewContents()
        */
        
        
        // Added by luokey
        self.EditImageView?.image = self.rawImage
        
        println("EditImageView frmae = \(self.EditImageView?.frame) \(self.ImageScrollView?.frame)")
        
        // Change image view scale
        self.ImageScrollView!.minimumZoomScale = 1.0;
        self.ImageScrollView!.maximumZoomScale = 2.0
        
        
        
        var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        self.ImageScrollView!.addGestureRecognizer(doubleTapRecognizer)
        
        
        // Add crop area button
        self.cropAreaButton = UIButton(frame: CGRectMake(0, 0, ScreenHeight/2.5, ScreenHeight/2.5))
        self.cropAreaButton!.backgroundColor = UIColor.clearColor()
        self.cropAreaButton!.layer.borderColor = UIColor.redColor().CGColor
        self.cropAreaButton!.layer.borderWidth = kEditImageCropButtonBorderWidth
        self.cropAreaButton!.center = self.view.center
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: Selector("detectPan:"))
        self.cropAreaButton!.addGestureRecognizer(dragGesture)
        
        self.cropAreaButton!.addTarget(self, action: Selector("cropAreaDidTouch:"), forControlEvents: UIControlEvents.TouchDown)
        
        self.view.addSubview(self.cropAreaButton!)
        self.lastLocation = self.cropAreaButton!.center
    }
    
    // MARK: UIScrollViewDelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.EditImageView
    }
    
    func centerScrollViewContents() {
//        let boundsSize = self.navigationController!.navigationBar.bounds.size
        var contentsFrame = self.EditImageView!.frame
        
        
        // Added by luokey
        var scrollViewContentOffset:CGPoint = CGPointZero
        var scrollViewSize:CGSize = CGSize(width: ScreenWidth, height: ScreenHeight - CGRectGetHeight(self.controlToolbar!.frame))
        
        
        if contentsFrame.size.width < scrollViewSize.width {
            contentsFrame.origin.x = (scrollViewSize.width - contentsFrame.size.width) / 2.0
            
            scrollViewContentOffset.x = 0.0                                                         // Added by luokey
        } else {
            contentsFrame.origin.x = 0.0
            
            scrollViewContentOffset.x = (contentsFrame.size.width - scrollViewSize.width) / 2.0         // Added by luokey
        }
        
        if contentsFrame.size.height < scrollViewSize.height {
            contentsFrame.origin.y = (scrollViewSize.height - contentsFrame.size.height) / 2.0
            
            scrollViewContentOffset.y = 0.0                                                         // Added by luokey
        } else {
            contentsFrame.origin.y = 0.0
            
            scrollViewContentOffset.y = (contentsFrame.size.height - scrollViewSize.height) / 2.0       // Added by luokey
        }
        
        self.EditImageView!.frame = contentsFrame
        
        self.ImageScrollView?.contentOffset = scrollViewContentOffset                               // Added by luokey
    }
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        
        let pointInView = recognizer.locationInView(self.EditImageView)
        
        var newZoomScale = self.ImageScrollView!.zoomScale * 1.5
        newZoomScale = min(newZoomScale, self.ImageScrollView!.maximumZoomScale)
        
        let scrollViewSize = self.ImageScrollView!.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        
        self.ImageScrollView!.zoomToRect(rectToZoomTo, animated: true)
    }
    
}


// MARK: - Handle drag & drop
extension KNEditImageViewController {
    
    func cropAreaDidTouch(recognizer: UITapGestureRecognizer) {
        self.lastLocation = self.cropAreaButton!.center
    }
    
    func detectPan(panGesture: UIPanGestureRecognizer) {
        var translation = panGesture.translationInView(self.cropAreaButton!.superview!) as CGPoint
        var newPos = CGPointMake(self.lastLocation!.x + translation.x, self.lastLocation!.y + translation.y)
        
        // Limit x
        if (newPos.x < CGRectGetWidth(self.cropAreaButton!.frame)/2) {
            newPos.x = CGRectGetWidth(self.cropAreaButton!.frame)/2
        }
        if (newPos.x > ScreenWidth - (CGRectGetWidth(self.cropAreaButton!.frame)/2)) {
            newPos.x = ScreenWidth - (CGRectGetWidth(self.cropAreaButton!.frame)/2)
        }
        
        // Limit y
        if (newPos.y < CGRectGetHeight(self.cropAreaButton!.frame)/2) {
            newPos.y = CGRectGetHeight(self.cropAreaButton!.frame)/2
        }
        if (newPos.y > ScreenHeight - CGRectGetHeight(self.controlToolbar!.frame) - (CGRectGetHeight(self.cropAreaButton!.frame)/2)) {
            newPos.y = ScreenHeight - CGRectGetHeight(self.controlToolbar!.frame) - (CGRectGetHeight(self.cropAreaButton!.frame)/2)
        }
        
        self.cropAreaButton!.center = newPos
    }

}
