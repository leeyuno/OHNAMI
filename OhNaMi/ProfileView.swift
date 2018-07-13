//
//  ProfileView.swift
//  OhNaMi
//
//  Created by leeyuno on 2017. 6. 17..
//  Copyright © 2017년 Froglab. All rights reserved.
//

import UIKit
import CoreData

protocol profileViewDelegate: class {
    func inputNick(nick: String)
    func inputPers(pers: String)
    func inputHobby(hobby: String)
    func inputSpec(spec: String)
    func inputSpot(spot: String)
    func inputAge(age: String)
    func inputJob(job: String)
}

class ProfileView: UIView, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    weak var profileViewDelegate: profileViewDelegate?
    
    @IBOutlet weak var nick: UITextField!
    @IBOutlet weak var pers: UITextField!
    @IBOutlet weak var hobby: UITextField!
    @IBOutlet weak var spec: UITextField!
    @IBOutlet weak var job: UITextField!
    @IBOutlet weak var spot: UITextField!
    @IBOutlet weak var age: UITextField!
    
    var pickAge = ["나이를 선택해주세요", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40"]
    
    var agePickerView = UIPickerView()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //pickerview 행 수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 1 {
            return pickAge.count
        }
        
        //        if pickerView.tag == 2 {
        //            return pickAge_part.count
        //        }
        
        return 0
    }
    
    //pickerview 라벨별 네임
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 1 {
            return pickAge[row]
        }
        
        //        if pickerView.tag == 2 {
        //            return pickAge_part[row]
        //        }
        
        return nil
    }
    
    
    //피커뷰 선택
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 1 {
            age.text = pickAge[row]
        }
        //
        //        if pickerView.tag == 2 {
        //            profileAge_part.text = pickAge_part[row]
        //        }
        
        //피커뷰의 항목을 선택하면 자동으로 피커뷰가 닫히는 코드
        //self.view.endEditing(true)
    }
    
    func configurePickerView() {
        agePickerView.delegate = self
        agePickerView.tag = 1
        age.inputView = agePickerView
        //agePickerView.layer.height = 100
        
        //apartPickerView.delegate = self
        //apartPickerView.tag = 2
        //profileAge_part.inputView = apartPickerView
        //apartPickerView.layer.height = 100
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(ProfileView.donePressed(sender:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(ProfileView.cancelPressed(sender:)))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        age.inputAccessoryView = toolBar
        //profileAge_part.inputAccessoryView = toolBar
        
    }
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        configureTextField()
        configurePickerView()
        
        nick.delegate = self
        job.delegate = self
        hobby.delegate = self
        spec.delegate = self
        spot.delegate = self
        age.delegate = self
        pers.delegate = self
        
    }
    
    func saveCoreData() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        var request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(request)
            if objects.count > 0 {
                let match = objects[0] as! Profile
                
                match.setValue(nick.text!, forKey: "nick")
                match.setValue(job.text!, forKey: "job")
                match.setValue(pers.text!, forKey: "pers")
                match.setValue(spec.text!, forKey: "spec")
                match.setValue(spot.text!, forKey: "spot")
                match.setValue(hobby.text!, forKey: "hobby")
                match.setValue(age.text!, forKey: "age")
                print(match)
                
                do {
                    try managedObjectContext.save()
                    print("success")
                } catch {
                    print("error")
                }
            } else {
                print("Nothing Founded")
            }
        } catch {
            print("error")
        }
    }
    
    func donePressed(sender: UIBarButtonItem) {
        if age.text == "나이를 선택해주세요" {
            let alert = UIAlertController(title: "나이를 선택해주세요", message: "나이를 선택해주세요", preferredStyle: .alert)
            let cancelButton = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            alert.addAction(cancelButton)
            //alert.dismiss(animated: true, completion: nil)
            //alert.addAction(UIAlertAction(title: "", style: .cancel, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            age.resignFirstResponder()
            //profileAge_part.resignFirstResponder()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nick {
            print("nick")
            profileViewDelegate?.inputNick(nick: nick.text!)
            print(nick.text!)
        } else if textField == job {
            profileViewDelegate?.inputJob(job: job.text!)
        } else if textField == pers {
            profileViewDelegate?.inputPers(pers: pers.text!)
        } else if textField == spec {
            profileViewDelegate?.inputSpec(spec: spec.text!)
        } else if textField == spot {
            profileViewDelegate?.inputSpot(spot: spot.text!)
        } else if textField == hobby {
            profileViewDelegate?.inputHobby(hobby: hobby.text!)
        } else if textField == age {
            profileViewDelegate?.inputAge(age: age.text!)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nick.resignFirstResponder()
        job.resignFirstResponder()
        pers.resignFirstResponder()
        spot.resignFirstResponder()
        spec.resignFirstResponder()
        age.resignFirstResponder()
        hobby.resignFirstResponder()
    }
    
    func cancelPressed(sender: UIBarButtonItem) {
        let inputProfileView = Bundle.main.loadNibNamed("ProfileView", owner: self, options: nil)?[0] as! ProfileView
        inputProfileView.age.text = ""
        //profileAge_part.text = ""
        
        inputProfileView.age.resignFirstResponder()
        //profileAge_part.resignFirstResponder()
    }
 
    func configureTextField() {
        nick.addBorderBottom(height: 1.0, color: UIColor.black)
        pers.addBorderBottom(height: 1.0, color: UIColor.black)
        spec.addBorderBottom(height: 1.0, color: UIColor.black)
        spot.addBorderBottom(height: 1.0, color: UIColor.black)
        job.addBorderBottom(height: 1.0, color: UIColor.black)
        hobby.addBorderBottom(height: 1.0, color: UIColor.black)
        age.addBorderBottom(height: 1.0, color: UIColor.black)
    }

}
