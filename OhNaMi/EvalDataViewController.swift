//
//  EvalDataViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 25/05/2017.
//  Copyright © 2017 Froglab. All rights reserved.
//

import UIKit
import CoreData

class EvalDataViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var textField1: UITextView!
    @IBOutlet weak var textField2: UITextView!
    @IBOutlet weak var textField3: UITextView!
    
    @IBOutlet weak var textLabel1: UILabel!
    @IBOutlet weak var textLabel2: UILabel!
    @IBOutlet weak var textLabel3: UILabel!
    
    var question: String = ""
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //receivedQuestion()

        configureTextView()

        // Do any additional setup after loading the view.
        
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        receivedQuestion()
    }

    
    //질문을 받아오는 함수
    func receivedQuestion() {
        print("receivedQuestion")
        let myUrl = URL(string: ohnamiUrl + "/quest_ran")
        var request = URLRequest(url: myUrl!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print("error")
            }
            
            print("response: \(response)")
            
            do {
                let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:NSArray]
                print("parseJSON : \(parseJSON)")
                
                let arrJSON = parseJSON["quest_list"]
                print("arrJSON : \(arrJSON)")
                
                for i in 0 ... 2 {
                    
                    print(i)
                    
                    let jsonObject = arrJSON?[i] as! [String:AnyObject]
                    
                    DispatchQueue.main.async {
                        if i == 0 {
                            self.textLabel1.text = jsonObject["quest"] as? String
                        }
                            
                        else if i == 1 {
                            self.textLabel2.text = jsonObject["quest"] as? String
                        }
                            
                        else if i == 2 {
                            self.textLabel3.text = jsonObject["quest"] as? String
                        }
                    }
                }

            } catch {
                print("error")
            }
            
        }) .resume()
    }
    
    
    //textView 설정함수
    func configureTextView() {
        textField1.text = "답변을 작성해주세요 글자수는 30자 제한입니다."
        textField1.textColor = UIColor.lightGray
        
        //글자수 제한
        //textField1.textContainer.maximumNumberOfLines = 2
        //textField1.textContainer.lineBreakMode = .byTruncatingTail
        
        textField2.text = "답변을 작성해주세요 글자수는 30자 제한입니다."
        textField2.textColor = UIColor.lightGray
        
        //글자수 제한
        //textField2.textContainer.maximumNumberOfLines = 2
        //textField2.textContainer.lineBreakMode = .byWordWrapping
        
        textField3.text = "답변을 작성해주세요 글자수는 30자 제한입니다."
        textField3.textColor = UIColor.lightGray

        
        textField1.delegate = self
        textField2.delegate = self
        textField3.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(EvalDataViewController.keyboardUp(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EvalDataViewController.keyboardDown(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    //전송버튼
    @IBAction func submit(_ sender: Any) {
        
        replyquestion()
    }
    
    //질문 - 답변을 서버로 전송하는 함수
    func replyquestion() {
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let Corerequest = NSFetchRequest<NSFetchRequestResult>()
        Corerequest.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(Corerequest)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                email = match.value(forKey: "email") as? String
                print("email : \(email)")
            } else {
                print("Nothing Founded")
            }
        } catch {
                print("error")
        }

        let myUrl = URL(string: ohnamiUrl + "/quest_reply")
        var request = URLRequest(url: myUrl!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = ["email" : "\(email!)", "quest1" : "\(textLabel1.text!)", "quest2" : "\(textLabel2.text!)", "quest3" : "\(textLabel3.text!)", "reply1" : "\(textField1.text!)", "reply2" : "\(textField2.text!)", "reply3" : "\(textField3.text!)"]
        
        print(json)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {( data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print("error")
            }
            
            print(response)
            
            self.EvalSegue()
            
        }) .resume()
        
        
    }
    
    func EvalSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "EvalSegue", sender: self)
        }
    }
    
    
    //글자수 제한을 두는 함수
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxAllowedCharacterPerLine = 30
        let lines = (textView.text as NSString).replacingCharacters(in: range, with: text).components(separatedBy: .newlines)
        
        for line in lines {
            if line.characters.count > maxAllowedCharacterPerLine {
                return false
            }
        }
        
        return true
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "답변을 작성해주세요"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func keyboardUp(notification: Notification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0
            
            //키보드가 올라올때 뷰를 위로 옮기고 싶은만큼 숫자증가
            self.view.frame.origin.y -= 50
        }
    }
    
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
        textField1.resignFirstResponder()
        textField2.resignFirstResponder()
        textField3.resignFirstResponder()
    }

}
