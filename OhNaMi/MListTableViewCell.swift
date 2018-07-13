//
//  MListTableViewCell.swift
//  OhNaMi
//
//  Created by leeyuno on 2017. 6. 21..
//  Copyright © 2017년 Froglab. All rights reserved.
//

import UIKit

class MListTableViewCell: UITableViewCell {

    @IBOutlet weak var Mimage: UIImageView!
    @IBOutlet weak var Mnick: UILabel!
    @IBOutlet weak var Mmessage: UILabel!
    @IBOutlet weak var Mtime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        separatorInset = .zero
        preservesSuperviewLayoutMargins = false
        layoutMargins = .zero
        layoutIfNeeded()
        
        selectionStyle = .none
        
        Mimage.layer.masksToBounds = true
        Mimage.layer.cornerRadius = Mimage.frame.size.height / 2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
