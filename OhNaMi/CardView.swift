//
//  CardView.swift
//  OhNaMi
//
//  Created by leeyuno on 24/05/2017.
//  Copyright © 2017 Froglab. All rights reserved.
//

import UIKit
import CoreData

protocol CardViewDelegate: class {
    func sendHeart(caller : String, receiver : String)
    func showDetailView()
    func showReplyView(caller: String, receiver: String)
}

class CardView: UIView {

    @IBOutlet weak var nick: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var age_part: UILabel!
    @IBOutlet weak var hobby: UILabel!
    @IBOutlet weak var job: UILabel!
    @IBOutlet weak var spot: UILabel!
    @IBOutlet weak var pers: UILabel!
    @IBOutlet weak var spec: UILabel!
    
    @IBOutlet weak var Cimage: UIImageView!
    
    var caller: String?
    var receiver : String = ""
    
    weak var CardViewDelegate: CardViewDelegate?
    
    override func draw(_ rect: CGRect) {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(showDetailView))
        
        Cimage.isUserInteractionEnabled = true
        Cimage.addGestureRecognizer(tap)
        
        nick.layer.cornerRadius = 50
        age.layer.cornerRadius = 50
        job.layer.cornerRadius = 50
    }
    
    func showDetailView() {
        CardViewDelegate?.showDetailView()
        
    }
    
    @IBAction func SendButton(_ sender: Any) {
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        
        let Corerequest = NSFetchRequest<NSFetchRequestResult>()
        Corerequest.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(Corerequest)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                caller = match.value(forKey: "nick") as? String
                print(match)
            } else {
                print("nothing founded")
            }
        } catch {
            print("error")
        }
        
        receiver = nick.text!
        
        print("caller : \(caller!), receiver : \(receiver)")
        
        CardViewDelegate?.showReplyView(caller: caller!, receiver: receiver)
        //CardViewDelegate?.sendHeart(caller: caller!, receiver: receiver)
        
    }

}
