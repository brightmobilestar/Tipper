//
//  KNSettingsTableViewCell.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/21/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

class KNSettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var cellTextField:KNTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cellTextField.setDefaultTextField()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
