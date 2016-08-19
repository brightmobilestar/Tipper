//
//  KNAddCardViewCell.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 12/16/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import UIKit

class KNAddCardViewCell: UITableViewCell, KNCreditCardViewDelegate {

    @IBOutlet weak var creditCard: KNCreditCardView?
    
    @IBOutlet weak var btnAddCard: UIButton?
    
    var currentCard:PTKCard?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.creditCard?.delegate = self
        
        self.btnAddCard?.enabled = false
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // MARK: - KNCreditCardViewDelegate
    func paymentView(paymentView: KNCreditCardView, withCard card: PTKCard, isValid valid: Bool) {
        
        self.btnAddCard?.enabled = valid
//        if valid {
//        
//            self.btnAddCard?.backgroundColor = UIColor(red:36/255, green: 166/255, blue: 240/255, alpha: 1)
//        }else{
//        
//            self.btnAddCard?.backgroundColor = UIColor.lightGrayColor()
//        }
        
        if valid {
            self.currentCard = card
        }
    }
}
