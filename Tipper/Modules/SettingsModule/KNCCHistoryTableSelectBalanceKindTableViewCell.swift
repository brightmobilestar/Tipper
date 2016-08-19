//
//  KNCCHistoryTableSelectBalanceKindTableViewCell.swift
//  Tipper
//
//  Created by Jianying Shi on 1/16/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation


protocol KNCCHistoryTableBalanceKindDelegate {
    func didSelectedBalanceKind( selectedSent: Bool )
}


class KNCCHistoryTableSelectBalanceKindTableViewCell : UITableViewCell{
    
    @IBOutlet weak var btnSent: UIButton?
    @IBOutlet weak var btnReceived: UIButton?
    @IBOutlet weak var selectorSent: UIView?
    @IBOutlet weak var selectorReceived: UIView?
    
    
    var delegate: KNCCHistoryTableBalanceKindDelegate?
    
    required init(coder aDecoder: (NSCoder!)) {
        super.init(coder: aDecoder)
      
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnReceived?.setTitle(NSLocalizedString("received",comment: ""), forState: UIControlState.Normal)
        self.btnSent?.setTitle(NSLocalizedString("sent",comment: ""), forState: UIControlState.Normal)
    }

    func setBalanceKind(balanceSent:Bool){
        if ( balanceSent ){
            selectorSent?.hidden = false
            selectorReceived?.hidden = true
        }
        else{
            selectorSent?.hidden = true
            selectorReceived?.hidden = false
        }
    }
    
    @IBAction func selectSent(sender: AnyObject){
        selectorSent?.hidden = false
        selectorReceived?.hidden = true
        if self.delegate != nil {
            self.delegate!.didSelectedBalanceKind(true)
        }
    }
    
    @IBAction func selectReceived(sender: AnyObject){
        selectorSent?.hidden = true
        selectorReceived?.hidden = false
        if self.delegate != nil {
            self.delegate!.didSelectedBalanceKind(false)
        }
    }
}
