//
//  KNTutorialViewController.swift
//  KNSWTemplate
//
//  Created by Peter van de Put on 25/10/14.
//  Copyright (c) 2014 Knodeit LLC. All rights reserved.
//

import Foundation
import UIKit

@objc protocol KNTutorialViewControllerDelegate{
    
    @objc optional func tutorialCloseButtonPressed()
    @objc optional func tutorialNextButtonPressed()
    @objc optional func tutorialPrevButtonPressed()
    @objc optional func tutorialPageDidChange(pageNumber:Int)
    
}


class KNTutorialViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Public properties -
    var delegate:KNTutorialViewControllerDelegate?
    // MARK: - Outlets -
    @IBOutlet var pageControl:UIPageControl?
    @IBOutlet var nextButton:UIButton?
    @IBOutlet var prevButton:UIButton?
    @IBOutlet var closeButton:UIButton?
    
    
    var currentPage:Int{    // The index of the current page (readonly)
        get{
            let page = Int((scrollview.contentOffset.x / view.bounds.size.width))
            return page
        }
    }
    
    
    // MARK: - Private properties -
    private let scrollview:UIScrollView!
    private var controllers:[UIViewController]!
    private var lastViewConstraint:NSArray?
    
    
    // MARK: - Overrides -
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Setup the scrollview
        scrollview = UIScrollView()
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.showsVerticalScrollIndicator = false
        scrollview.pagingEnabled = true
        
        // Controllers as empty array
        controllers = Array()
    }
    
    override init() {
        super.init()
        scrollview = UIScrollView()
        controllers = Array()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize UIScrollView
        
        scrollview.delegate = self
        scrollview.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        view.insertSubview(scrollview, atIndex: 0) //scrollview is inserted as first view of the hierarchy
        
        // Set scrollview related constraints
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[scrollview]-0-|", options:nil, metrics: nil, views: ["scrollview":scrollview]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[scrollview]-0-|", options:nil, metrics: nil, views: ["scrollview":scrollview]))
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        pageControl?.numberOfPages = controllers.count
        pageControl?.currentPage = 0
    }
    
    
    // MARK: - Internal methods -
    
    @IBAction func nextPage(){
        if (currentPage + 1) < controllers.count {
            delegate?.tutorialNextButtonPressed?()
            var frame = scrollview.frame
            frame.origin.x = CGFloat(currentPage + 1) * frame.size.width
            scrollview.scrollRectToVisible(frame, animated: true)
        }
    }
    
    @IBAction func prevPage(){
        
        if currentPage > 0 {
            delegate?.tutorialNextButtonPressed?()
            var frame = scrollview.frame
            frame.origin.x = CGFloat(currentPage - 1) * frame.size.width
            scrollview.scrollRectToVisible(frame, animated: true)
        }
    }
    
    // TODO: If you want to implement a "skip" option
    // connect a button to this IBAction and implement the delegate with the skipWalkthrough
    @IBAction func close(sender: AnyObject){
        delegate?.tutorialCloseButtonPressed?()
    }
    
  // MARK: - addVieqControllers to the array -
    func addViewController(vc:UIViewController)->Void{
        controllers.append(vc)
        // Setup the viewController view
        vc.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        scrollview.addSubview(vc.view)
        // Constraints
        let metricDict = ["w":vc.view.bounds.size.width,"h":vc.view.bounds.size.height]
        // - Generic cnst
        vc.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(h)]", options:nil, metrics: metricDict, views: ["view":vc.view]))
        vc.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[view(w)]", options:nil, metrics: metricDict, views: ["view":vc.view]))
        scrollview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]|", options:nil, metrics: nil, views: ["view":vc.view,]))
        if controllers.count == 1{
            scrollview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]", options:nil, metrics: nil, views: ["view":vc.view,]))
            
        }else{
            
            let previousVC = controllers[controllers.count-2]
            let previousView = previousVC.view;
            
            scrollview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[previousView]-0-[view]", options:nil, metrics: nil, views: ["previousView":previousView,"view":vc.view]))
            
            if let cst = lastViewConstraint{
                scrollview.removeConstraints(cst)
            }
            lastViewConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:[view]-|", options:nil, metrics: nil, views: ["view":vc.view])
            scrollview.addConstraints(lastViewConstraint!)
        }
    }
    
    private func updateUI(){
        pageControl?.currentPage = currentPage
         delegate?.tutorialPageDidChange?(currentPage)
         if currentPage == controllers.count - 1{
            nextButton?.hidden = true
        }else{
            nextButton?.hidden = false
        }
        if currentPage == 0{
            prevButton?.hidden = true
        }else{
            prevButton?.hidden = false
        }
    }
    
    // MARK: - Scrollview Delegate -
    func scrollViewDidScroll(sv: UIScrollView) {
        for var i=0; i < controllers.count; i++ {
            if let vc = controllers[i] as? KNTutorialPage{
                let mx = ((scrollview.contentOffset.x + view.bounds.size.width) - (view.bounds.size.width * CGFloat(i))) / view.bounds.size.width
                if(mx < 2 && mx > -2.0){
                    vc.tutorialDidScroll(scrollview.contentOffset.x, offset: mx)
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updateUI()
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        updateUI()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}