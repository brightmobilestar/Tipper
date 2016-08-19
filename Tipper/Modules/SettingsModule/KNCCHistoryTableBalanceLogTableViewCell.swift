//
//  KNCCHistoryTableBalanceLogTableViewCell.swift
//  Tipper
//
//  Created by Jianying Shi on 1/16/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation

class KNCCHistoryTableBalanceLogTableViewCell : UITableViewCell{
    @IBOutlet weak var labelAmountAndUser : UILabel?
    @IBOutlet weak var labelDateAndTime : UILabel?
    @IBOutlet weak var viewVisibleArea : UIView?
    @IBOutlet weak var heightOfVisibleArea : NSLayoutConstraint?
    
    @IBOutlet weak var topOfLabelAmount : NSLayoutConstraint?
    @IBOutlet weak var topOfLabelDate : NSLayoutConstraint?
    
    
}


