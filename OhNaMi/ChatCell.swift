//
//  ChatCell.swift
//  SocketChat
//
//  Created by Gabriel Theodoropoulos on 1/31/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class ChatCell: BaseCell {

    @IBOutlet weak var lblChatMessage: UILabel!
    
    @IBOutlet weak var lblMessageDetails: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        layoutMargins = UIEdgeInsetsMake(8, 0, 8, 0)
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 20

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
