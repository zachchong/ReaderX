//
//  ResultTableViewCell.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 27/07/2021.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var partOfSpeech: UILabel!
    
    @IBOutlet weak var definition: UILabel!
    
    @IBOutlet weak var example: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
