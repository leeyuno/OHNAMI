//
//  StartViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 2017. 6. 8..
//  Copyright © 2017년 Froglab. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import CoreFoundation
import FMDB

//let ohnamiUrl = "http://61.82.115.34:34543"
//let socketUrl = "http://61.82.115.34:34543"

let ohnamiUrl = "http://192.168.0.4:8080"
let socketUrl = "http://192.168.0.4:7777"

let fileManager = FileManager.default

let dirPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
var databasePath = dirPaths[0].appendingPathComponent("messages.db").path

let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.portrait
}

extension UIColor {
    class func colorWithRGBHex(hex: Int, alpha: Float = 1.0) -> UIColor {
        let r = Float((hex >> 16) & 0xFF)
        let g = Float((hex >> 8 ) & 0xFF)
        let b = Float((hex) & 0xFF)
        
        return UIColor(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue: CGFloat(b / 255.0), alpha: CGFloat(alpha))
    }
}

class StartViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var mainView: UIView!
    @IBOutlet var loginView: UIView!
    @IBOutlet var registerView: UIView!
    @IBOutlet var warningLabels: [UILabel]!
    @IBOutlet weak var switchButton: UIButton!

    
    var isloginViewVisible = true
    
    @IBOutlet weak var loginWarning: UILabel!
    @IBOutlet weak var registerWarning: UILabel!
    
    var loginViewTopConstraint: NSLayoutConstraint!
    var registerTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    
    @IBOutlet weak var registerEmail: UITextField!
    @IBOutlet weak var registerPassword: UITextField! 
    @IBOutlet weak var genderList: UISegmentedControl!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    var deviceId: String!
    var count = 0
    var insertCount = 0
    
    var backColor: UIColor!
    
    //백그라운드 상태에서 온 메시지를 받기위한 배열
    var msgArray = [String]()
    var senderArray = [String]()
    var receiverArray = [String]()
    var timeArray = [String]()
    var roomidArray = [String]()
    var fcmIdArray = [String]()
    var messageList = [[String]]()
    var messageCheckList = [[String]]()
    
    @IBAction func deleteButton(_ sender: Any) {
        self.deleteCoreData()
    }
    var genderValue: String!
    var gender: [String] = ["male", "female"]
    var email: String? = ""
    var nick: String? = ""
    
    @IBAction func valueChanged(_ sender: Any) {
        genderValue = self.gender[self.genderList.selectedSegmentIndex]
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.deleteCoreData()
        
        self.navigationItem.title = "오나미"
        
        self.customization()
        loginButton.layer.cornerRadius = 10
        loginButton.layer.backgroundColor = UIColor(red: 50.0/255.0, green: 255.0/255.0, blue: 95.0/255.0, alpha: 1.0).cgColor
        
        registerButton.layer.cornerRadius = 10
        registerButton.layer.backgroundColor = UIColor(red: 50.0/255.0, green: 255.0/255.0, blue: 95.0/255.0, alpha: 1.0).cgColor
        
//        NotificationCenter.default.addObserver(self, selector: #selector(backgroundfcmReceive(_:)), name: NSNotification.Name(rawValue: "backgroundNoti"), object: nil)
        
        switchButton.tintColor = UIColor.white

        // Do any additional setup after loading the view.
        self.coreDataCheck()
        self.configuretextField()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.registrationCheck()
        
        loginWarning.text = ""
        registerWarning.text = ""
    }
    
    func coreDataCheck() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(request)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                email = match.value(forKey: "email") as? String
                nick = match.value(forKey: "nick") as? String
            } else {
                print("Nothing Founded")
            }
        } catch {
            print("error")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configuretextField() {
        loginEmail.placeholder = "Email"
        loginEmail.addBorderBottom(height: 1.0, color: UIColor.darkGray)
        
        loginPassword.placeholder = "Password"
        loginPassword.addBorderBottom(height: 1.0, color: UIColor.darkGray)
        
        registerEmail.placeholder = "Email"
        registerEmail.addBorderBottom(height: 1.0, color: UIColor.darkGray)
        
        registerPassword.placeholder = "Password"
        registerPassword.addBorderBottom(height: 1.0, color: UIColor.darkGray)
        
        loginPassword.isSecureTextEntry = true
        registerPassword.isSecureTextEntry = true
    }
    
    func setGradientBackgound() {
        let colorTop = UIColor(red: 0.0/255.0, green: 255.0/255.0, blue: 149.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 50.0/255.0, green: 255.0/255.0, blue: 94.0/255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        self.switchButton.tintColor = UIColor.white
        //self.view.layer.addSublayer(gradientLayer)
    }
    
    func customization() {
        
        self.setGradientBackgound()
        //self.mainView.layer.backgroundColor = UIColor.colorWithRGBHex(hex: 0x4CD964)
        self.mainView.backgroundColor = UIColor.colorWithRGBHex(hex: 0x4CD964, alpha: 1.0)
        
        //loginView customization
        self.view.insertSubview(loginView, belowSubview: mainView)
        //self.view.addSubview(loginView)
        self.loginView.translatesAutoresizingMaskIntoConstraints = false
        self.loginView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.loginViewTopConstraint = NSLayoutConstraint.init(item: self.loginView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 100)
        self.loginViewTopConstraint.isActive = true
        self.loginView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.45).isActive = true
        self.loginView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.loginView.layer.cornerRadius = 8
        
        //registerView customization
        self.view.insertSubview(registerView, belowSubview: mainView)
        //self.view.addSubview(self.registerView)
        self.registerView.translatesAutoresizingMaskIntoConstraints = false
        self.registerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.registerTopConstraint = NSLayoutConstraint.init(item: self.registerView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 1000)
        self.registerTopConstraint.isActive = true
        self.registerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.6).isActive = true
        self.registerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.registerView.layer.cornerRadius = 8
    }
    
    @IBAction func switchButton(_ sender: UIButton) {
        if self.isloginViewVisible {
            self.isloginViewVisible = false
            sender.setTitle("Login", for: .normal)
            self.loginViewTopConstraint.constant = 1000
            self.registerTopConstraint.constant = 100
        } else {
            self.isloginViewVisible = true
            sender.setTitle("Create New Account", for: .normal)
            self.loginViewTopConstraint.constant = 100
            self.registerTopConstraint.constant = 1000
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { self.view.layoutIfNeeded() })
        
    }
    
    @IBAction func registerButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "이메일이 정확하지 않습니다.", message: "이메일 포맷을 확인해주세요", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        let emailCheck = registerEmail.text!
        
        if emailCheck.range(of: "@") != nil {
            if emailCheck.range(of: ".") != nil {
                self.uploadData()
            } else {
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            self.present(alert, animated: true, completion: nil)
        }
        
        //self.uploadData()
    }
    
    func saveCoreData() {
        deleteCoreData()
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let contact = Profile(entity: entityDescription!, insertInto: managedObjectContext)
        
        self.deviceId = UIDevice().identifierForVendor?.uuidString
        
        contact.deviceId = self.deviceId
        contact.email = self.registerEmail.text!
        contact.password = self.registerPassword.text!
        contact.gender = self.genderValue!
        
        do {
            try managedObjectContext.save()
            print("success")
        } catch {
            print("error")
        }
    }
    
    @IBAction func loginButton(_ sender: Any) {
        if (loginEmail.text == "" || loginPassword.text == "") {
            let alert = UIAlertController(title: "이메일 또는 패스워드가 일치하지 않습니다", message: "이메일 또는 패스워드를 확인해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            loginWarning.text = "Please try again."
        } else {
            tokenPush()
            loginCheck()
        }
    }
    
    func tokenPush() {
        print("tokenPush")
        let tokenUrl = URL(string: ohnamiUrl + "/currentuser")
        var request = URLRequest(url: tokenUrl!)
        
        //let token = InstanceID.instanceID().token()!
        let token = Messaging.messaging().fcmToken
        
        let json:[String: Any] = ["email" : "\(loginEmail.text!)", "token" : "\(token!)"]
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            if error != nil {
                if (error?.localizedDescription)! == "The request timed out." {
                    let alert = UIAlertController(title: "서버에 접속할 수 없습니다.", message: "다시 시도해 주세요", preferredStyle: .alert)
                    let done = UIAlertAction(title: "확인", style: .default, handler: { action -> Void in
                        exit(0)
                    })
                    
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        }).resume()
    }
    
    func loginCheck() {
        let myUrl = URL(string: ohnamiUrl + "/login")
        var request = URLRequest(url: myUrl!)
        
        //self.coreDataCheck()
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = ["email" : "\(loginEmail.text!)", "password" : "\(loginPassword.text!)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {( data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                if (error?.localizedDescription)! == "The request timed out." {
                    let alert = UIAlertController(title: "서버에 접속할 수 없습니다.", message: "다시 시도해 주세요", preferredStyle: .alert)
                    let done = UIAlertAction(title: "확인", style: .default, handler: { action -> Void in
                        exit(0)
                    })
                    
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                do {
                    let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String : AnyObject]
                    let arrJSON = parseJSON?["profile"]
                    
                    if arrJSON! as? String == "0" {
                        let alert = UIAlertController(title: "에러", message: "에러", preferredStyle: .alert)
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        let sexJSON = parseJSON?["sex"] as! String
                        let aObject = arrJSON as! [String: AnyObject]
                        
                        let pNick = aObject["nick"] as? String
                        let pHobby = aObject["hobby"] as? String
                        let pImageid = aObject["imageId1"] as? String
                        let pJob = aObject["job"] as? String
                        let pAge = aObject["age"] as? String
                        let pPers = aObject["pers"] as? String
                        let pSpec = aObject["spec"] as? String
                        let pSpot = aObject["spot"] as? String
                        
                        let eneityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
                        let contact = Profile(entity: eneityDescription!, insertInto: managedObjectContext)
                        
                        self.deviceId = UIDevice().identifierForVendor?.uuidString
                        
                        contact.deviceId = self.deviceId
                        contact.nick = pNick
                        contact.age = pAge
                        contact.gender = sexJSON
                        contact.hobby = pHobby
                        contact.job = pJob
                        contact.pers = pPers
                        contact.spec = pSpec
                        contact.spot = pSpot
                        contact.imageId = pImageid
                        contact.email = self.loginEmail.text!
                        contact.password = self.loginPassword.text!
                        
                        self.email = self.loginEmail.text!
                        
                        do {
                            try managedObjectContext.save()
                            print("success")
                        } catch {
                            print("save error")
                        }
                        
                        self.registrationCheck()

                    }
                    
//                    if arrJSON == "0" {
//                        let alert = UIAlertController(title: "이메일 패스워드가 일치하지 않습니다", message: "이메일 패스워드가 일치하지 않습니다", preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
//                        
//                        self.registerWarning.text = "Please try again."
//                        self.present(alert, animated: true, completion: nil)
//                    } else {
//                        self.registrationCheck() 
//                    }
                } catch {
                    print("error")
                }
            }
        }) .resume()
    }
    
    func uploadData() {
        let myUrl = URL(string: ohnamiUrl + "/reg")
        var request = URLRequest(url: myUrl!)
        
        deviceId = UIDevice().identifierForVendor?.uuidString
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = ["email" : "\(registerEmail.text!)", "password" : "\(registerPassword.text!)", "sex" : "\(genderValue!)", "deviceId" : "\(deviceId!)"]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                
            if error != nil {
                if (error?.localizedDescription)! == "The request timed out." {
                    
                    let alert = UIAlertController(title: "서버에 접속할 수 없습니다.", message: "다시 시도해 주세요", preferredStyle: .alert)
                    let done = UIAlertAction(title: "확인", style: .default, handler: { action -> Void in
                        exit(0)
                    })
                    
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    let httpResponse = response as! HTTPURLResponse
                    
                    if httpResponse.statusCode == 409 {
                        let alert = UIAlertController(title: "이메일이 중복됩니다.", message: "이메일을 변경해주세요", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { ( action: UIAlertAction!) in
                            self.dismiss(animated: true, completion: nil)
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                        
                    else if httpResponse.statusCode == 200 {
                        self.saveCoreData()
                        
                        self.registerSegue()
                    }
                }
            }
        }) .resume()
    }
    
    //등록된 사용자인지 확인하는 함수
    func registrationCheck() {
        let myUrl = URL(string: ohnamiUrl + "/match/dcmr")
        var request = URLRequest(url: myUrl!)
        
        let deviceId = UIDevice().identifierForVendor?.uuidString
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if email != "" {
            let json:[String : Any] = ["email" : "\(email!)", "deviceId" : "\(deviceId!)"]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            
            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request, completionHandler: {( data: Data?, response: URLResponse?, error: Error?) -> Void in
                
                //error가 nil이 아니면 에러창
                if error != nil {
                    if (error?.localizedDescription)! == "The request timed out." {
                        
                        let alert = UIAlertController(title: "서버에 접속할 수 없습니다.", message: "다시 시도해 주세요", preferredStyle: .alert)
                        let done = UIAlertAction(title: "확인", style: .default, handler: { action -> Void in
                            exit(0)
                        })
                        
                        alert.addAction(done)
                        self.present(alert, animated: true, completion: nil)
                    }
                
                    //error가 nil이 아니고 상태코드 200이면 정상적으로 실행
                } else {
                    let httpResponse = response as! HTTPURLResponse
                    
                    if httpResponse.statusCode == 200 {
                        do {
                            let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String : AnyObject]
                            //profile을 파싱해와서 스트링 값이 0이면 가입이 안되있는 유저
                            let arrJSON = parseJSON?["profile"]
                            let a: String = "0"
                            
                            //평가가 완료되었는지 확인하는 변수
                            let evalJSON = parseJSON?["exam"]
                            
                            //파싱해온 데이터에서 up_message를 뽑아내는 변수
                            let messageJSON = parseJSON?["up_message"]
                            let cObject = messageJSON as? [[String : AnyObject]]
                            
                            //파싱해온 message값의 배열이 비어있는지 아닌지 확인하는 변수 nil일 경우 있음 []일 경우 없음
                            let dObject = cObject as? [[String]]
                            
                            //파싱해온 메시지가 존재한다면 메시지를 받아서 sql에 입력한다.
                            
                            if arrJSON! as? String == a {
                                self.registerSegue()
                                return
                            } else {
                                if dObject == nil {
                                    let m1 = cObject?[0]["message"] as! NSArray
                                    self.insertCount = m1.count - 1
                                    
                                    //메시지 내용, 시간, 받는사람, 보낸사람 을 배열화에서 sql에 삽입
                                    //msg: 메시지내용, time: 보낸시간, nick: 내 닉네임, nick2: 보낸사람 닉네임
                                    for i in 0 ... m1.count - 1 {
                                        let m2 = m1[i] as! [String : AnyObject]
//                                        self.msgArray.append(m2["msg"] as! String)
//                                        self.timeArray.append(m2["time"] as! String)
//                                        self.senderArray.append(m2["nick"] as! String)
//                                        self.receiverArray.append(m2["nick2"] as! String)
//                                        self.roomidArray.append(m2["key"] as! String)
//                                        self.fcmIdArray.append(m2["gcm.message_id"] as! String)
                                        self.messageList.append([m2["msg"] as! String, m2["time"] as! String, m2["nick"] as! String, m2["nick2"] as! String, m2["key"] as! String, m2["m_id"] as! String])
                                    }
                                    
                                    self.messageCheck()
                                }
                                
                                let questJSON = parseJSON?["quest"]
                                let profileJSON = parseJSON?["profile"]
                                
                                //aObject는 질문에 대한 답변값
                                let aObject = questJSON as! [String: AnyObject]
                                //bOjbect는 프로필 등록값
                                let bObject = profileJSON as! [String: AnyObject]
                                
                                //질문, 프로필에 대한 입력값을 랜덤으로 뽑아옴
                                let q1 = aObject["quest1"] as? String
                                let q2 = aObject["quest2"] as? String
                                
                                let p1 = bObject["nick"] as? String
                                let p2 = bObject["spec"] as? String
                                let p3 = bObject["spot"] as? String
                                
                                if q1 != nil && q2 != nil {
                                    
                                    if p1 != nil && p2 != nil && p3 != nil {
                                        
                                        //SocketManager.sharedInstance.socketConn(nick: self.nick!)
                                        if evalJSON as! Bool == false {
                                            self.notEvalSegue()
                                        } else {
                                            self.loginSuccessSegue()
                                        }
                                    } else {
                                        self.notProfileSegue()
                                    }
                                } else {
                                    self.registerSegue()
                                }
                            }
                        } catch {
                            print("error")
                        }
                    }

                }
            }) .resume()

        } else {
            print("email is null")
        }
    }
    
    func messageCheck() {
        print("messageCheck")
        let contactDB = FMDatabase(path: databasePath)
        
        for i in 0 ... messageList.count - 1 {
            if contactDB.open() {
                let selectSQL = "SELECT * FROM MESSAGES WHERE fcmid = '\(self.messageList[i][5])'"
                let results = contactDB.executeQuery(selectSQL, withArgumentsIn: [])
                
                if results?.next() == true {
                    print("업메시지 데이터가 데이터베이스에 존재합니다.")
                } else {
                    print("업메시지 데이터가 데이터베이스에 존재하지 않습니다.")
                    messageCheckList.append(messageList[i])
                    self.insertMessage()
                }

            }
        }
        
        //self.insertMessage()
        
        contactDB.close()

    }
    
    func insertMessage() {
        print("insertmessage")
        let contactDB = FMDatabase(path: databasePath)
        
        for i in 0 ... self.messageCheckList.count - 1 {

            if (contactDB.open()) {
                let insertSQL = "INSERT INTO MESSAGES (nick, message, roomid, receiver, create_at, fcmid) VALUES('\(messageCheckList[i][2])', '\(messageCheckList[i][0])', '\(messageCheckList[i][4])', '\(messageCheckList[i][3])', '\(messageCheckList[i][1])', '\(messageCheckList[i][5])')"
                
                let result = contactDB.executeUpdate(insertSQL, withArgumentsIn: [])
                
                if !result {
                    print("Error: \((contactDB.lastErrorMessage()))")
                } else {
                    print("Success")
                }
            }
            
            else {
                print("Error : \((contactDB.lastErrorMessage()))")
            }
        }
    }
    
    //이미 가입한 유저 바로 로그인
    func loginSuccessSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "loginSuccessSegue", sender: self)
        }
    }
    
    //프로필 작성이 되지 않은 유저
    func notProfileSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "notProfileSegue", sender: self)
        }
    }
    
    //가입테스트가 진행되지 않은 유저
    func notEvalSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "notEvalSegue", sender: self)
        }
    }
    
    func deleteCoreData() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let coreRequest = NSFetchRequest<NSFetchRequestResult>()
        coreRequest.entity = entityDescription
        //coreRequest.returnsObjectsAsFaults = false
        
        if let result = try? managedObjectContext.fetch(coreRequest) {
            for object in result {
                managedObjectContext.delete(object as! Profile)
            }
        }
    }
    
    func registerSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "registerSegue", sender: self)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        loginEmail.resignFirstResponder()
        loginPassword.resignFirstResponder()
        
        registerEmail.resignFirstResponder()
        registerPassword.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "notProfileSegue") {
            if let vc = segue.destination as? RegisterViewController {
                vc.done = 2
            }
        } else if (segue.identifier == "notEvalSegue") {
            if let vc = segue.destination as? RegisterViewController {
                vc.done = 1
            }
        } else if (segue.identifier == "loginSuccessSegue") {
            if let vc = segue.destination as? RegisterViewController {
                vc.done = 3
            }
        }
    }
    
    deinit {
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "pushNoti"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "backgroundNoti"), object: nil)
    }

}
