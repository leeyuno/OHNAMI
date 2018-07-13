//
//  LoginViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 24/05/2017.
//  Copyright © 2017 Froglab. All rights reserved.
//

import UIKit
import CoreData

let ohnamiUrl = "http://192.168.0.32:8080"
let socketUrl = "http://192.168.0.32:7777"
//let ohnamiUrl = "http://sface.me:8080"

let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

class LoginViewController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var pwdText: UITextField!
    
    var count = 0
    
    var deviceCheck: String = ""
    
    var emailCheck: String = ""
    
    @IBAction func loginButton(_ sender: Any) {
        
        //아이디 패스워드가 입력되지 않으면 에러창
        if (emailText.text == "" || pwdText.text == "") {
            let alert = UIAlertController(title: "이메일 또는 패스워드가 일치하지 않습니다", message: "이메일 또는 패스워드를 확인해주세요", preferredStyle: .alert)
            //alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            print("id or password not available")
        } else {
            loginCheck()
        }
        
        //서버와 통신해서 아이디 패스워드가 일치하면 로그인 불일치하면 에러창을 출력
    }
    
    func loginCheck() {
        let myUrl = URL(string: ohnamiUrl + "/login")
        var request = URLRequest(url: myUrl!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json:[String: Any] = ["email" : "\(emailText.text!)", "password" : "\(pwdText.text!)"]
        print(json)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print("error")
            }
            
            print("response \(response)")
            
            do {
                let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                
                let arrJSON = parseJSON["result"] as! String
                
                if arrJSON == "1" {
                    print("success")
                    self.loginSuccess()
                }
                    
                else {
                    let alert = UIAlertController(title: "이메일 패스워드가 일치하지 않습니다.", message: "이메일 패스워드가 일치하지 않습니다.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
            } catch {
                print("error")
            }
            
        }) .resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loginView")

        // Do any additional setup after loading the view.
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(request)
            
            if objects.count > 0 {
                print(objects.count)
                for i in 0 ... objects.count {
                    let match = objects[i] as! Profile
                    emailCheck = match.value(forKey: "email") as! String
                    print(match)
                }
            } else {
                print("Nothing founded")
            }
        } catch {
            print("error")
        }
        
        pwdText.isSecureTextEntry = true
        
        //alreadyLogin()
    }
    
    func alreadyLogin() {
        
        let myUrl = URL(string: ohnamiUrl + "/match/dcmr")
        var request = URLRequest(url: myUrl!)
        
        let deviceId = UIDevice().identifierForVendor?.uuidString
        print(deviceId!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json:[String : Any] = ["email" : "\(emailCheck)", "deviceId" : "\(deviceId!)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        print("emailCheck \(emailCheck)")
        
        if emailCheck != nil {
            print("emailCheck")
            URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response:URLResponse?, error: Error?) -> Void in
                
                if error != nil {
                    print(error)
                }
                
                do {
                    //서버에 이전에 입력한 답변값이 있는지 파싱해온다.
                    let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                    print(parseJSON)
                    
                    let arrJSON = parseJSON?["profile"]
                    
                    print(arrJSON)
                    
                    let a: String = "0"
                    
                    
                    //이미 로그인한 유저인지 확인하는 루프
                    if arrJSON! as? String == a {
                        //데이터 파싱값이 없을때
                        print("register not yet")
                    } else {
                        //데이터 파싱값이 존재할때
                        print("already register")
                        
                        let questJSON = parseJSON?["quest"]
                        let profileJSON = parseJSON?["profile"]
                        
                        //aObject는 질문에 대한 답변값
                        let aObject = questJSON as! [String: AnyObject]
                        //bObject는 프로필 등록값
                        let bObject = profileJSON as! [String: AnyObject]
                        
                        //질문, 프로필에 대한 입력값을 랜덤으로 뽑아옴
                        let q1 = aObject["quest3"] as? String
                        let q2 = aObject["reply3"] as? String
                        
                        let p1 = bObject["nick"] as? String
                        let p2 = bObject["spec"] as? String
                        let p3 = bObject["spot"] as? String
                        
                        self.count = 20
                        
                        //질문에 대한 답변값이 존재할때 {
                        if q1 != nil && q2 != nil {
                            //평가가 10회 이상 진행되었을 경우 다음으로 진행
                            if self.count > 10 {
                                //프로필 작성이 되어있는 경우
                                if p1 != nil && p2 != nil && p3 != nil {
                                    // 로그인 시킨다
                                    self.loginSuccess()
                                } else {
                                    //프로필 작성이 안되어있을경우
                                    self.notProfileSegue()
                                }
                            } else {
                                //평가가 완료되지 않은 경우
                                self.notEvalSegue()
                            }
                        } else {
                            //질문답변이 완료되지 않은 경우
                            self.notQuestSegue()
                        }
                    }
                    
                } catch {
                    print("error")
                }
                
            }) .resume()
        } else {
            return
        }
    }
    
    func notEvalSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "notEvalSegue", sender: self)
        }
    }
    
    func notProfileSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "notProfileSegue", sender: self)
        }
    }
    
    func notQuestSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "notquestSegue", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginSuccess() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "loginSuccessSegue", sender: self)
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
