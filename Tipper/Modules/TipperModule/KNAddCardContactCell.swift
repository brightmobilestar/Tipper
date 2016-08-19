//
//  KNAddCardContactCell.swift
//  Tipper
//
//  Created by Jianying Shi on 1/13/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation

class KNAddCardContactViewCell: UITableViewCell {
    
    @IBOutlet weak var tfProfile: KNTextField?
    @IBOutlet weak var tfMoneyTip: KNTextField?
    @IBOutlet weak var btnProfile: UIButton?
    @IBOutlet weak var btnMoneyTip: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
