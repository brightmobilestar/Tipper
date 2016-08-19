//
//  KNActivityView.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 12/31/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import Foundation
import QuartzCore

public class KNActivityView:UIView {

    // The view to contain the activity indicator and label.  The bezel style has a semi-transparent rounded rectangle, others are fully transparent:
    var borderView:UIView?
    
    // The activity indicator view:
    var activityIndicator:UIActivityIndicatorView?
    
    // The activity label:
    var activityLabel:UILabel?
    
    // A fixed width for the label text, or zero to automatically calculate the text size (normally set on creation of the view object):
    var labelWidth:CGFloat?
    
    // Whether to show the network activity indicator in the status bar.  Set to YES if the activity is network-related.  This can be toggled on and off as desired while the activity view is visible (e.g. have it on while fetching data, then disable it while parsing it).  By default it is not shown:
    var showNetworkActivityIndicator:Bool?
    
    
    var originalView:UIView?
//    var borderView:UIView?
//    var activityIndicator:UIActivityIndicatorView?
//    var activityLabel:UILabel?
    
    // Constants
    let kRegularFontName = "HelveticaNeue"
    let FONT_SIZE = CGFloat(20)
    let FONT_COLOR = UIColor.whiteColor()
    
    // Static varibles
    struct StaticVariables {
        
        static var knActivityView : KNActivityView? = nil
    }
    
    /*
    currentActivityView
    Returns the currently displayed activity view, or nil if there isn't one.
    */
    
    public class func currentActivityView() -> KNActivityView{
    
        return StaticVariables.knActivityView!
    }
    
    /*
    activityViewForView:
    
    Creates and adds an activity view centered within the specified view, using the label "Loading...".  Returns the activity view, already added as a subview of the specified view.
    */
    
    public class func activityViewForView(addToView:UIView) -> KNActivityView{
        
        return self.activityViewForView(addToView, withLabel:NSLocalizedString("Loading...", comment:"Default KNActivtyView label text"), width: 0, indicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    }
    
    
    /*
    activityViewForView:withLabel:
    
    Creates and adds an activity view centered within the specified view, using the specified label.  Returns the activity view, already added as a subview of the specified view.
    */
    public class func activityViewForView(addToView:UIView, withLabel labelText:String, indicatorStyle inStyle:UIActivityIndicatorViewStyle) -> KNActivityView {
        
        return self.activityViewForView(addToView, withLabel: labelText, width: 0, indicatorStyle: inStyle)
    }
    
    /*
    activityViewForView:withLabel:width:
    
    Creates and adds an activity view centered within the specified view, using the specified label and a fixed label width.  The fixed width is useful if you want to change the label text while the view is visible.  Returns the activity view, already added as a subview of the specified view.
    */
    public class func activityViewForView(addToView:UIView, withLabel labelText:String, width aLabelWidth:CGFloat, indicatorStyle inStyle:UIActivityIndicatorViewStyle) -> KNActivityView {
    
        // Immediately remove any existing activity view:
        if (StaticVariables.knActivityView != nil) {
        
            self.removeView()
        }
        
        // Remember the new view (so this is a singleton):
        StaticVariables.knActivityView = KNActivityView(forView: addToView, withLabel: labelText, width: aLabelWidth, indicatorStyle: inStyle)
        
        return StaticVariables.knActivityView!
    }
    
    /*
    initForView:withLabel:width:
    
    Designated initializer.  Configures the activity view using the specified label text and width, and adds as a subview of the specified view.
    
    */
    init(forView addToView:UIView, withLabel labelText:String, width aLabelWidth:CGFloat, indicatorStyle inStyle:UIActivityIndicatorViewStyle){
    
        super.init(frame: CGRectZero)
        
        // Allow subclasses to change the view to which to add the activity view (e.g. to cover the keyboard):
        self.originalView = addToView
        self.originalView = self.viewForView(addToView)
        
        // Configure this view (the background) and its subviews:
        self.setupBackground()
        self.labelWidth = aLabelWidth
        self.borderView = self.makeBorderView()
        self.activityIndicator = self.makeActivityIndicator(inStyle)
        self.activityLabel = self.makeActivityLabelWithText(labelText)
        
        self.activityLabel?.textColor = self.FONT_COLOR
        self.activityLabel?.font = UIFont(name: self.kRegularFontName, size: 17.0)
        
        // Assemble the subviews:
        addToView.addSubview(self)
        self.addSubview(self.borderView!)
        self.borderView?.addSubview(self.activityIndicator!)
        self.borderView?.addSubview(self.activityLabel!)
        
        // Animate the view in, if appropriate:
        self.animateShow()
        
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    removeView
    
    Immediately removes and releases the view without any animation.
    
    */
    public class func removeView(){
    
        if StaticVariables.knActivityView == nil {
        
            return
        }
        
        if StaticVariables.knActivityView?.showNetworkActivityIndicator == true {
        
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        
        StaticVariables.knActivityView?.removeFromSuperview()
        
        // Remove the global reference:
        StaticVariables.knActivityView = nil
        
    }
    
    /*
    viewForView:
    
    Returns the view to which to add the activity view.  By default returns the same view.  Subclasses may override this to change the view.
    */
    public func viewForView(view:UIView) -> UIView{
    
        return view
    }
    
    /*
    enclosingFrame
    
    Returns the frame to use for the activity view.  Defaults to the superview's bounds.  Subclasses may override this to use something different, if desired.
    
    */
    public func enclosingFrame() -> CGRect{
        
        return self.superview!.bounds
    }
    
    /*
    setupBackground
    
    Configure the background of the activity view.

    */
    public func setupBackground(){
    
        self.opaque = false
        self.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
    }
    
    /*
    makeBorderView
    
    Returns a new view to contain the activity indicator and label.  By default this view is transparent.  Subclasses may override this method, optionally calling super, to use a different or customized view.
    */
    public func makeBorderView() -> UIView {
    
        var view:UIView = UIView(frame: CGRectZero)
        
        view.opaque = true
        view.backgroundColor = UIColor.blackColor()
        view.alpha = 0.5
        view.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin
        
        view.layer.cornerRadius = 8
        view.layer.shadowOffset = CGSizeMake(8, 5)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.8
        
        return view
    }
    
    /*
    makeActivityIndicator
    
    Returns a new activity indicator view.  Subclasses may override this method, optionally calling super, to use a different or customized view.
    
    */
    public func makeActivityIndicator(inStyle:UIActivityIndicatorViewStyle) -> UIActivityIndicatorView{
    
        var indicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: inStyle)
        indicator.color = UIColor.whiteColor()
        indicator.startAnimating()

        return indicator
    }
    
    /*
    makeActivityLabelWithText:
    
    Returns a new activity label.  Subclasses may override this method, optionally calling super, to use a different or customized view.
    */
    public func makeActivityLabelWithText(labelText:String) -> UILabel{
    
        var label:UILabel = UILabel(frame: CGRectZero)
        
        label.font = UIFont.systemFontOfSize(self.FONT_SIZE)
        label.textAlignment = NSTextAlignment.Left
        label.textColor = self.FONT_COLOR
        label.backgroundColor = UIColor.clearColor()
        label.shadowColor = UIColor.clearColor()
        label.shadowOffset = CGSizeMake(0.0, 1.0)
        label.text = labelText
        
        return label
    }
    
    /*
    layoutSubviews
    
    Positions and sizes the various views that make up the activity view, including after rotation.
    */
    public override func layoutSubviews(){
    
        self.frame = self.enclosingFrame()
        
        // If we're animating a transform, don't lay out now, as can't use the frame property when transforming:
        if (!CGAffineTransformIsIdentity(self.borderView!.transform)){
        
            return
        }
        
        var textRect:CGRect = (self.activityLabel!.text! as NSString).boundingRectWithSize(CGSizeMake(ScreenWidth, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.boldSystemFontOfSize(self.FONT_SIZE)], context: nil)
        
        var textSize:CGSize = textRect.size
        
        // Use the fixed width if one is specified:
        if self.labelWidth > 10 {
        
            textSize.width = self.labelWidth!
        }
        
        self.activityLabel?.frame = CGRectMake(self.activityLabel!.frame.origin.x, self.activityLabel!.frame.origin.y, textSize.width, textSize.height)
        
        // Calculate the size and position for the border view: with the indicator to the left of the label, and centered in the receiver:
        var borderFrame:CGRect = CGRectZero
        borderFrame.size.width = self.activityIndicator!.frame.size.width + textSize.width + 25.0
        borderFrame.size.height = self.activityIndicator!.frame.size.height + 10.0
        borderFrame.origin.x = floor(0.5 * (self.frame.size.width - borderFrame.size.width))
        borderFrame.origin.y = floor(0.5 * (self.frame.size.height - borderFrame.size.height - 20.0))
        self.borderView!.frame = borderFrame
        
        // Calculate the position of the label: vertically centered and at the right of the border view:
        var indicatorFrame:CGRect = self.activityIndicator!.frame
        indicatorFrame.origin.x = 10.0
        indicatorFrame.origin.y = 0.5 * (borderFrame.size.height - indicatorFrame.size.height)
        self.activityIndicator!.frame = indicatorFrame
        
        // Calculate the position of the label: vertically centered and at the right of the border view:
        var labelFrame:CGRect = self.activityLabel!.frame
        labelFrame.origin.x = borderFrame.size.width - labelFrame.size.width - 10.0;
        labelFrame.origin.y = floor(0.5 * (borderFrame.size.height - labelFrame.size.height));
        self.activityLabel!.frame = labelFrame;
    }
    
    /*
    animateShow
    
    Animates the view into visibility.  Does nothing for the simple activity view.
    */
    public func animateShow(){
    
        // Does nothing by default
    }
    
    /*
    animateRemove
    
    Animates the view out of visibiltiy.  Does nothng for the simple activity view.
    */
    public func animateRemove(){
    
        // Does nothing by default
    }
    
    /*
    setShowNetworkActivityIndicator:
    
    Sets whether or not to show the network activity indicator in the status bar.  Set to YES if the activity is network-related.  This can be toggled on and off as desired while the activity view is visible (e.g. have it on while fetching data, then disable it while parsing it).  By default it is not shown.
    */
    public func setShowNetworkActivityIndicator(show:Bool){
    
        self.showNetworkActivityIndicator = show
        UIApplication.sharedApplication().networkActivityIndicatorVisible = show
    }
}

