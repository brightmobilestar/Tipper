//
//  KNCardViewCell.swift
//  Tipper
//
//  Created by Jay N. on 11/25/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

class KNCardViewCell: UITableViewCell {

    @IBOutlet weak var tfCarProfile: KNTextField?
    @IBOutlet weak var line: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
