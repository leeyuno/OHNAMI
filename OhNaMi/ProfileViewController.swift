//
//  ProfileViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 24/05/2017.
//  Copyright © 2017 Froglab. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var hobby: UIButton!
    @IBOutlet weak var job: UIButton!
    @IBOutlet weak var personality: UIButton!
    
    var array = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.hidesBackButton = true
        
    }
    @IBAction func Submit(_ sender: Any) {
        if hobby.isSelected == true {
            array.append((hobby.titleLabel?.text)!)
        }
        
        if job.isEnabled == true {
            array.append((job.titleLabel?.text)!)
        }
        
        if personality.isEnabled == true {
            array.append((personality.titleLabel?.text)!)
        }
        
        print(array)
        
        selectProfileSegue()
    }
    @IBAction func hobbyButton(_ sender: UIButton) {
        if hobby.isSelected == false {
            hobby.isSelected = true
        }
        
        else {
            hobby.backgroundColor = UIColor.white
            hobby.isSelected = false
        }
    }
    @IBAction func jobButton(_ sender: UIButton) {
        if job.isSelected == false {
            job.isSelected = true
        }
            
        else {
            job.backgroundColor = UIColor.white
            job.isSelected = false
        }
    }
    @IBAction func personalityButton(_ sender: UIButton) {
        if personality.isSelected == false {
            personality.isSelected = true
        }
            
        else {
            personality.backgroundColor = UIColor.white
            personality.isSelected = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectProfileSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "selectProfileSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "selectProfileSegue") {
            if let vc = segue.destination as? inputProfileViewController {
                vc.array = self.array
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
