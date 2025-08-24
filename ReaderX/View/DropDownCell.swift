//
//  MenuCell.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 01/08/2021.
//

import UIKit
import DropDown

class MenuCell: DropDownCell {

    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
