//
//  WordTableViewCell.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 25/07/2021.
//

import UIKit
import AVFoundation

class WordTableViewCell: UITableViewCell {

    @IBOutlet weak var vocab: UILabel!
    
    @IBOutlet weak var zh_CN: UILabel!
    
    @IBOutlet weak var en: UILabel!
    
    var audioURL = String()
    var player : AVPlayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func pronounceButtonClicked(_ sender: UIButton) {
        
        guard let url = URL.init(string: audioURL) else { return }
        let playerItem = AVPlayerItem.init(url: url)
        player = AVPlayer.init(playerItem: playerItem)
        player?.play()
        
    }
    
}
