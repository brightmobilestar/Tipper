//
//  KNMainUserCollectionViewCell.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 11/22/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

class KNMainUserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bookmarkedImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var backgroundImageView: KNImageView?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
     override func prepareForReuse() {
        
        super.prepareForReuse()
        self.backgroundImageView?.image = UIImage(named: "UserPlaceholder")
    }

}