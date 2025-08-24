//
//  DocumentTableViewCell.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 25/07/2021.
//

import UIKit

protocol GoToFlashCardDelegate {
    func goToFlashCard(indexPath:Int)
}

class DocumentTableViewCell: UITableViewCell {
    
    var delegate : GoToFlashCardDelegate?
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var numberOfWord: UILabel!
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var view2B: UIView!
    @IBOutlet weak var V3C: UIView!
    
    @IBOutlet weak var flashCardButton: UIButton!
    
    var index : Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func flashCardButtonClicked(_ sender: UIButton) {
        delegate?.goToFlashCard(indexPath: index!)
    }
    
}
