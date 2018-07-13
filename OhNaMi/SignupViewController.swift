//
//  SignupViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 24/05/2017.
//  Copyright © 2017 Froglab. All rights reserved.
//

import UIKit
import CoreData

class SignupViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var pwdText: UITextField!
    @IBOutlet weak var gender: UISegmentedControl!
    
    var genderList: [String] = ["male", "female"]
    
    var genderValue: String!
    
    var tapNumber = 0
    
    var deviceId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pwdText.isSecureTextEntry = true
        
        emailText.delegate = self
        pwdText.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignupViewController.keyboardUp(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignupViewController.keyboardDown(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        //let tapImage = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.showActionSheet))
        
        pwdText.isSecureTextEntry = true


        // Do any additional setup after loading the view.
    }
    
    func uploadData() {
        let myUrl = URL(string: ohnamiUrl + "/reg")
        print(myUrl!)
        
        var request = URLRequest(url: myUrl!)
        
        deviceId = UIDevice().identifierForVendor?.uuidString
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = ["email" : "\(emailText.text!)", "password" : "\(pwdText.text!)", "sex" : "\(genderValue!)", "deviceId" : "\(deviceId!)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print("error")
            }
            
            let httpResponse = response as! HTTPURLResponse
            
            if httpResponse.statusCode == 409 {
                let alert = UIAlertController(title: "이메일이 중복됩니다.", message: "이메일 중복", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "back", style: .default, handler: { (action: UIAlertAction!) in
                    self.dismiss(animated: true, completion: nil)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            
            else if httpResponse.statusCode == 200 {
                self.SignupSegue()
            }
            
            print("response: \(response)")
        }) .resume()
        
    }
    
    //입력받은 이메일 패스워드 값을 서버에 저장
    //존재하는 값이면 경고창 출력
    @IBAction func signupButton(_ sender: Any) {
        
        deleteCoreData()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let contact = Profile(entity: entityDescription!, insertInto: managedObjectContext)
        
        deviceId = UIDevice().identifierForVendor?.uuidString
        print(deviceId)
        
//        contact.setValue(deviceId, forKey: "deviceId")
//        contact.setValue(emailText.text!, forKey: "email")
//        contact.setValue(pwdText.text!, forKey: "password")
//        contact.setValue(genderValue, forKey: "gender")
        
        contact.deviceId = deviceId
        contact.email = emailText.text!
        contact.password = pwdText.text!
        contact.gender = genderValue
        
        do {
            try managedObjectContext.save()
            print("success")
            
        } catch {
            print("error")
        }

        print(contact)
        
        self.uploadData()
        
        //SignupSegue()
    }
    
    func deleteCoreData() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let Corerequest = NSFetchRequest<NSFetchRequestResult>()
        Corerequest.entity = entityDescription
        
        if let result = try? managedObjectContext.fetch(Corerequest) {
            for object in result {
                managedObjectContext.delete(object as! Profile)
            }
        }
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        genderValue = self.genderList[self.gender.selectedSegmentIndex]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //키보드업 제스쳐
    func keyboardUp(notification: Notification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0
            
            //키보드가 올라올때 뷰를 위로 옮기고 싶은만큼 숫자증가
            self.view.frame.origin.y -= 0
        }
    }
    
    //키보드다운 제스쳐
    func keyboardDown(notification: Notification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            //키보드를 제자리로
            self.view.frame.origin.y = 0
        }
    }
    
    //키보드 리턴키터치시 키보드 숨기는 이벤트
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    //다른곳 터치시 키보드 숨기는 이벤트
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailText.resignFirstResponder()
        pwdText.resignFirstResponder()
    }
    
    func SignupSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "SignupSegue", sender: self)
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
