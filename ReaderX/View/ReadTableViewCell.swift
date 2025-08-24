//
//  ReadTableViewCell.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 01/08/2021.
//

import UIKit
import AVFoundation

class ReadTableViewCell: UITableViewCell {
    

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var robotImage: UIImageView!
    
    @IBOutlet weak var vocab: UILabel!
    @IBOutlet weak var zhCN: UILabel!
    @IBOutlet weak var en: UILabel!
    
//    var audioURL = String()
//    var player : AVPlayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
