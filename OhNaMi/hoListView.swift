//
//  hoListView.swift
//  OhNaMi
//
//  Created by leeyuno on 2017. 7. 26..
//  Copyright © 2017년 Froglab. All rights reserved.
//

import UIKit

class hoListView: UIView {

    @IBOutlet weak var hoImage: UIImageView!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        hoImage.clipsToBounds = true
        hoImage.layer.cornerRadius = self.hoImage.frame.size.height / 2
    }
 

}
