
//  RegisterViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 2017. 6. 8..
//  Copyright © 2017년 Froglab. All rights reserved.
//

import UIKit
import CoreData


//텍스트필드를 테두리를 밑줄만 남기는 함수
extension UITextField {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height-height, width: self.frame.width, height: self.frame.height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}

extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil}
        UIGraphicsEndImageContext()
        return result
    }
}

class RegisterViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    //질문 답변 뷰
    @IBOutlet var EvalView: UIView!
    @IBOutlet weak var quest1: UITextField!
    @IBOutlet weak var quest2: UITextField!
    @IBOutlet weak var quest3: UITextField!
    
    //평가가 완료되지 않으면 대기화면
    @IBOutlet var WaitView: UIView!
    //프로필 작성뷰
    @IBOutlet var ProfileView: UIView!
    //이미지 등록뷰
    @IBOutlet weak var imageView: UIImageView!
    //@IBOutlet weak var ImageView: UIImage!

    @IBOutlet weak var ProfileButtonView: UIView!
    @IBOutlet weak var doneEvalButton: UIButton!
    @IBOutlet weak var doneProfileButton: UIButton!
    
    @IBOutlet var mainView: UIView!
    
    var Pnick: String = ""
    var Ppers: String = ""
    var Phobby: String = ""
    var Psepc: String = ""
    var Pjob: String = ""
    var Pspot: String = ""
    var Page: String = ""
    
    @IBOutlet weak var profileNick: UITextField!
    @IBOutlet weak var profilePers: UITextField!
    @IBOutlet weak var profileHobby: UITextField!
    @IBOutlet weak var profileSpec: UITextField!
    @IBOutlet weak var profileJob: UITextField!
    @IBOutlet weak var profileSpot: UITextField!
    @IBOutlet weak var profileAge: UITextField!
    @IBOutlet weak var evalText: UILabel!
    
    @IBOutlet weak var ProfileImageView: UIView!
    
    var agePickerView = UIPickerView()
    var pickAge = ["나이를 선택해주세요", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40"]
    
    var spotPickerView = UIPickerView()
    var pickSpot = ["지역을 선택해주세요", "서울", "경기", "부산", "강원", "충남", "충북", "경북", "경남", "전북", "전남", "해외"]
    
    var ageFirst: String!
    var ageSecond: String!
    
    //현재 사용자가 어디까지 프로필 작성을 완료했는지 알기위한 변수
    var done = 0
    var imageName: String!
    var email: String!
    var gender: String!
    var password: String!
    
    var EvalViewContraint: NSLayoutConstraint!
    var WaitViewContraint: NSLayoutConstraint!
    var ProfileViewContraint: NSLayoutConstraint!
    var ImageViewContraint: NSLayoutConstraint!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return UIInterfaceOrientationMask.portrait
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //필요한 코어데이터 로드
        //self.configureCoreData()
        //뷰 커스터마이징
        self.customization()
        //사용자가 어디까지 완료했는지 확인
        self.doneCheck()
        //텍스트필드 커스터마이징
        self.configureTextField()
        //이미지 클릭시 프로필사진 등록 함수
        self.configureTapImage()
        //피커뷰 생성
        self.configurePickerView()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        //let contact = Profile(entity: entityDescription!, insertInto: managedObjectContext)
        
        let CoreRequest = NSFetchRequest<NSFetchRequestResult>()
        CoreRequest.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(CoreRequest)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                email = match.value(forKey: "email") as? String
                gender = match.value(forKey: "gender") as? String
                password = match.value(forKey: "password") as? String
            }
        } catch {
            print("error")
        }
        
        self.doneEvalButton.isEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardUp(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardDown(notification:)), name: .UIKeyboardDidHide, object: nil)
        
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.receiveQuestion()
        //self.configureTextView()
        
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = imageView.frame.size.height / 2
        imageView.clipsToBounds = true
        imageView.layoutIfNeeded()

        self.configureTextField()
        self.setGradientBackgound()
        
        self.tokenPush()
        
    }
    
    func tokenPush() {
        let tokenUrl = URL(string: ohnamiUrl + "/currentuser")
        var request = URLRequest(url: tokenUrl!)
        
        //let token = InstanceID.instanceID().token()!
        let token = Messaging.messaging().fcmToken

        let json:[String: Any] = ["email" : "\(email!)", "token" : "\(token!)"]

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
    
    func setGradientBackgound() {
        let colorTop = UIColor(red: 0.0/255.0, green: 255.0/255.0, blue: 149.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 50.0/255.0, green: 255.0/255.0, blue: 94.0/255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    
        //self.view.layer.addSublayer(gradientLayer)
    }
    
    func configureTextField() {
        quest1.placeholder = "첫번째 질문을 입력하세요"
        quest2.placeholder = "두번째 질문을 입력하세요"
        quest3.placeholder = "세번째 질문을 입력하세요"
        
        quest1.addBorderBottom(height: 1.0, color: UIColor.black)
        quest2.addBorderBottom(height: 1.0, color: UIColor.black)
        quest3.addBorderBottom(height: 1.0, color: UIColor.black)
        
        quest1.delegate = self
        quest2.delegate = self
        quest3.delegate = self
        
        profileNick.placeholder = "닉네임을 입력하세요"
        profileSpot.placeholder = "지역을 입력하세요"
        profilePers.placeholder = "성격을 입력하세요"
        profileAge.placeholder = "나이를 입력하세요"
        profileSpec.placeholder = "특기를 입력하세요"
        profileJob.placeholder = "직업을 입력하세요"
        profileHobby.placeholder = "취미를 입력하세요"
        
        profileNick.addBorderBottom(height: 1.0, color: UIColor.black)
        profilePers.addBorderBottom(height: 1.0, color: UIColor.black)
        profileSpec.addBorderBottom(height: 1.0, color: UIColor.black)
        profileSpot.addBorderBottom(height: 1.0, color: UIColor.black)
        profileJob.addBorderBottom(height: 1.0, color: UIColor.black)
        profileHobby.addBorderBottom(height: 1.0, color: UIColor.black)
        profileAge.addBorderBottom(height: 1.0, color: UIColor.black)
        
        profileNick.delegate = self
        profilePers.delegate = self
        profileSpec.delegate = self
        profileSpot.delegate = self
        profileJob.delegate = self
        profileHobby.delegate = self
        profileAge.delegate = self
        
    }
    
    func configureTapImage() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.showActionSheet))
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
    }
    
    //필요한 코어데이터 가져오는 함수
    func configureCoreData() {

    }
    
    func doneCheck() {
        if done == 1 {
            self.showWaitView()
            self.evalText.text = "평가가 완료되지 않았습니다."
            //self.evalText.center.x = self.WaitView.center.x

            self.doneEvalButton.isEnabled = false
        }
        
        if done == 2 {
            self.showProfileView()
        }
        
        if done == 3 {
            self.showWaitView()
            self.evalText.text = "평가가 완료되었습니다."
            self.doneEvalButton.isEnabled = true
        }
    }
    
    //뷰 커스터마이징 함수
    func customization() {
        self.mainView.layer.backgroundColor = UIColor.lightGray.cgColor
        
        //EvalView customization
        self.view.insertSubview(EvalView, belowSubview: mainView)
        self.EvalView.translatesAutoresizingMaskIntoConstraints = false
        self.EvalView.center = self.view.center
        self.EvalView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.EvalView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.EvalViewContraint = NSLayoutConstraint.init(item: self.EvalView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 80)
        self.EvalViewContraint.isActive = true
        self.EvalView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.74).isActive = true
        self.EvalView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9).isActive = true
        self.EvalView.layer.cornerRadius = 8
        self.EvalView.center.x = self.view.center.x
        
        //WaitView customization
        self.view.insertSubview(WaitView, belowSubview: mainView)
        self.WaitView.translatesAutoresizingMaskIntoConstraints = false
        self.WaitView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.WaitViewContraint = NSLayoutConstraint.init(item: self.WaitView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 1000)
        self.WaitViewContraint.isActive = true
        self.WaitView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.45).isActive = true
        self.WaitView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.WaitView.layer.cornerRadius = 8
        
        //ProfileView customization
        self.view.insertSubview(ProfileView, belowSubview: mainView)
        self.ProfileView.translatesAutoresizingMaskIntoConstraints = false
        self.ProfileView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.ProfileViewContraint = NSLayoutConstraint.init(item: self.ProfileView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 1000)
        self.ProfileViewContraint.isActive = true
        self.ProfileView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.70).isActive = true
        self.ProfileView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.80).isActive = true
        self.ProfileView.layer.cornerRadius = 8
    
        //self.ProfileButtonView.frame.size = CGSize(width: self.view.frame.size.width * 0.85, height: 35)
        
        //self.ProfileButtonView.frame = CGRect(x: 10, y: 300, width: self.ProfileButtonView.frame.size.width, height: self.ProfileButtonView.frame.size.height)

        self.doneEvalButton.layer.cornerRadius = 8
        
        //평가가 아직 완료되지 않았다면 다음으로 진행하는 버튼을 숨김
        self.doneEvalButton.isEnabled = true
    }
    
    //질문을 서버에 전송하는 함수
    func makeQuestion() {
        let questUrl = URL(string: ohnamiUrl + "/quest_reply")
        var request = URLRequest(url: questUrl!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String : Any] = ["email" : "\(email!)", "quest1" : "\(quest1.text!)", "quest2" : "\(quest2.text!)", "quest3" : "\(quest3.text!)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let contactRequest = NSFetchRequest<NSFetchRequestResult>()
        
        contactRequest.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(contactRequest)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                
                match.setValue(quest1.text!, forKey: "quest1")
                match.setValue(quest2.text!, forKey: "quest2")
                match.setValue(quest3.text!, forKey: "quest3")
                
                do {
                    try managedObjectContext.save()
                    print("success")
                } catch {
                    print("save error")
                }
            } else {
                print("nothing founded")
            }
        } catch {
            print("save error2")
        }
        
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
                self.showProfileView()
            }
        }) .resume()
    }
    
    //질문작성, 이미지 등록하는 버튼
    @IBAction func doneQuest(_ sender: Any) {
        
        if quest1.text! == "" || quest2.text! == "" || quest3.text! == "" {
            let alert = UIAlertController(title: "입력되지 않은 항목이 있습니다.", message: "다시 입력해주세요", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            alert.addAction(cancel)
            
            present(alert, animated: true, completion: nil)
        } else {
            self.uploadImage()
            self.makeQuestion()
        }
    }

    //evalview 나타나게 설정하는 함수
    func showEvalView() {
        DispatchQueue.main.async {
            self.EvalViewContraint.constant = 80
            self.ProfileViewContraint.constant = 1000
            self.WaitViewContraint.constant = 1000
        }
    }
    
    //showWaitView 나타나게 설정하는 함수
    func showWaitView() {
        DispatchQueue.main.async {
            self.EvalViewContraint.constant = 1000
            self.ProfileViewContraint.constant = 1000
            self.WaitViewContraint.constant = 80
        }
    }
    
    //showProfileView 나타나게 설정하는 함수
    func showProfileView() {
        DispatchQueue.main.async {
            self.EvalViewContraint.constant = 1000
            self.ProfileViewContraint.constant = 80
            self.WaitViewContraint.constant = 1000
        }
    }
    
    func keyboardUp(notification: Notification) {
        
        let keyboardFrame: CGRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0
            
            self.view.frame.origin.y -= keyboardFrame.size.height - 80
        }
    }
    
    func keyboardDown(notification: Notification) {
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0
        }
    }
    
    //텍스트뷰에 글자가 작성될때 글자를 검정으로 변경하고 텍스트 입력

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        quest1.resignFirstResponder()
        quest2.resignFirstResponder()
        quest3.resignFirstResponder()
        
        profileNick.resignFirstResponder()
        profileAge.resignFirstResponder()
        profileHobby.resignFirstResponder()
        profileSpot.resignFirstResponder()
        profileJob.resignFirstResponder()
        profilePers.resignFirstResponder()
        profileSpec.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func EvalButton(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "doneProfileSegue", sender: self)
        }
    }

    @IBAction func doneProfileButton(_ sender: Any) {
        if (profileNick.text! == "" || profileAge.text! == "" || profileJob.text! == "" || profilePers.text! == "" || profileSpec.text! == "" || profileSpot.text! == "" || profileHobby.text! == "") {
            
            let alert = UIAlertController(title: "입력되지 않은 항목이 있습니다.", message: "다시 입력해주세요", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            alert.addAction(cancel)
            
            present(alert, animated: true, completion: nil)
        } else {
            self.uploadData()
        }
    }
    
    func doneProfileSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "doneProfileSegue", sender: self)
        }
    }
    
    func useCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.camera
        self.show(picker, sender: nil)
    }
    
    func addImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        self.show(picker, sender: nil)
    }
    
    func deleteImage() {
        imageView.image = nil
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        imageView.image = selectedImage
    }
    
    func showActionSheet() {
        let alert = UIAlertController(title: "프로필 등록", message: "프로필에 사용할 사진을 등록해주세요", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let CameraAction = UIAlertAction(title: "Camera", style: .default, handler: { action -> Void in
            self.useCamera()
        })
        let AlbumAction = UIAlertAction(title: "Album", style: .default, handler: { action -> Void in
            self.addImage()
        })
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { action -> Void in
            self.deleteImage()
        })
        
        alert.addAction(CameraAction)
        alert.addAction(AlbumAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func uploadImage() {
        let imageUrl = URL(string: ohnamiUrl + "/uploads")
        
        var temp = email!
        imageName = temp.replacingOccurrences(of: "@", with: "")
        imageName = imageName.replacingOccurrences(of: ".", with: "")
        
        let request = NSMutableURLRequest(url : imageUrl!)
        request.httpMethod = "POST"
        
        imageName = imageName + ".jpg"
        
        
        if imageView == nil {
            print("image is nil")
        }
        
        var boundary = "******"
        
        let imageData = UIImageJPEGRepresentation((imageView.image?.resizeWithWidth(width: 200))!, 0.5)
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        let mimetype = "image/*"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"images\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("hi\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"images\"; filename=\"\(imageName!)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageData!)
        
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        request.httpBody = body as Data
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard ((data) != nil), let _:URLResponse = response, error == nil else {
                print("error \(error!)")
                return
            }
            
            if let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            {
                print("response \(response!)")
                print("dataString: \(dataString)")
            }
        })
        task.resume()
    }
    
    func uploadData() {
        
        var temp = email!
        imageName = temp.replacingOccurrences(of: "@", with: "")
        imageName = imageName.replacingOccurrences(of: ".", with: "")
        imageName = imageName + ".jpg"
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let CoreRequest = NSFetchRequest<NSFetchRequestResult>()
        CoreRequest.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(CoreRequest)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                
                match.setValue(self.profileNick.text!, forKey: "nick")
                match.setValue(self.profileJob.text!, forKey: "job")
                match.setValue(self.profilePers.text!, forKey: "pers")
                match.setValue(self.profileSpec.text!, forKey: "spec")
                match.setValue(self.profileSpot.text!, forKey: "spot")
                match.setValue(self.profileHobby.text!, forKey: "hobby")
                match.setValue(self.profileAge.text!, forKey: "age")
                match.setValue(imageName, forKey: "imageId")

                do {
                    try managedObjectContext.save()
                    print("success")
                } catch {
                    print("error")
                }
                
            } else {
                print("Nothing founded")
            }
        } catch {
            print("error")
        }
        
        let myUrl = URL(string: ohnamiUrl + "/profile")
        var request = URLRequest(url: myUrl!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = ["email" : "\(email!)", "nick" : "\(self.profileNick.text!)", "age" : "\(self.profileAge.text!)", "job" : "\(self.profileJob.text!)", "hobby" : "\(self.profileHobby.text!)", "spec" : "\(self.profileSpec.text!)", "pers" : "\(self.profilePers.text!)", "spot" : "\(self.profileSpot.text!)", "imageId1" : "\(imageName!)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {( data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                if (error?.localizedDescription)! == "The reqeust timed out" {
                    let alert = UIAlertController(title: "서버에 접속할 수 없습니다.", message: "다시 시도해 주세요", preferredStyle: .alert)
                    let done = UIAlertAction(title: "확인", style: .default, handler: { action -> Void in
                        exit(0)
                    })
                    
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                do {
                    let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                    
                    let arrJSON = parseJSON["result"] as? String
                    
                    if arrJSON! == "0" {
                        let alert = UIAlertController(title: "닉네임이 중복됩니다.", message: "닉네임이 중복됩니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.showWaitView()
                        SocketManager.sharedInstance.socketConn(nick: self.profileNick.text!)
                    }
                } catch {
                    print("error")
                }
            }
        }) .resume()
    }
    
    func configurePickerView() {
        agePickerView.delegate = self
        agePickerView.tag = 1
        profileAge.inputView = agePickerView
        
        spotPickerView.delegate = self
        spotPickerView.tag = 2
        profileSpot.inputView = spotPickerView
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(RegisterViewController.donePressed(sender:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(RegisterViewController.cancelPressed(sender:)))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        profileAge.inputAccessoryView = toolBar
        profileSpot.inputAccessoryView = toolBar
        //profileAge_part.inputAccessoryView = toolBar
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 1 {
            return pickAge.count
        } else if pickerView.tag == 2 {
            return pickSpot.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return pickAge[row]
        } else if pickerView.tag == 2 {
            return pickSpot[row]
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            profileAge.text = pickAge[row]
        } else if pickerView.tag == 2 {
            profileSpot.text = pickSpot[row]
        }
    }
    
    func cancelPressed(sender: UIBarButtonItem) {
        profileAge.text = ""
        profileSpot.text = ""
        //profileAge_part.text = ""
        
        profileAge.resignFirstResponder()
        profileSpot.resignFirstResponder()
        //profileAge_part.resignFirstResponder()
    }
    
    func donePressed(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "정확하게 선택해주세요", message: "정확하게 선택해주세요", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        
        if profileAge.text == "나이를 선택해주세요" {
            self.present(alert, animated: true, completion: nil)
        } else {
            profileAge.resignFirstResponder()
            //profileAge_part.resignFirstResponder()
        }
        
        if profileSpot.text == "지역을 선택해주세요" {
            self.present(alert, animated: true, completion: nil)
        } else {
            profileSpot.resignFirstResponder()
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
