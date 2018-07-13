//
//  LikeTableViewCell.swift
//  OhNaMi
//
//  Created by leeyuno on 2017. 6. 23..
//  Copyright © 2017년 Froglab. All rights reserved.
//

import UIKit

class LikeTableViewCell: UITableViewCell {

    @IBOutlet weak var LikeImage: UIImageView!
    @IBOutlet weak var LikeTextLabel: UILabel!
    @IBOutlet weak var timeTextLabel: UILabel!
    @IBOutlet weak var choiceTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        separatorInset = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsets.zero
        layoutIfNeeded()
        
        choiceTextLabel.layer.cornerRadius = 6
        
        LikeImage.layer.masksToBounds = true
        LikeImage.layer.cornerRadius = LikeImage.frame.size.height / 2
        
        // Set the selection style to None.
        selectionStyle = UITableViewCellSelectionStyle.none
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
