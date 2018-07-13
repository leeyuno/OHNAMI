//
//  MypageViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 24/05/2017.
//  Copyright © 2017 Froglab. All rights reserved.
//

import UIKit
import CoreData

class MypageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet weak var myImage: UIImageView!
//    @IBOutlet weak var nick: UILabel!
//    @IBOutlet weak var job: UILabel!
//    @IBOutlet weak var hobby: UILabel!
//    @IBOutlet weak var spot: UILabel!
//    @IBOutlet weak var pers: UILabel!
//    @IBOutlet weak var spec: UILabel!
//    @IBOutlet weak var age: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    let collectionViewList = ["공지사항", "이벤트", "회원탈퇴", "FAQ", "팔로워", "하트충전", "카드", "스페이스"]
    let collectionViewImageList = ["003-signs-1", "005-gift-1", "001-exit-1", "discuss-issue", "like", "heart", "card", "sface_white"]
    
    @IBOutlet var noticeView: UIView!
    @IBOutlet var eventView: UIView!
    @IBOutlet var signoutView: UIView!
    @IBOutlet var faqView: UIView!
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    
    var nick: String!
    var job: String!
    var hobby: String!
    var spot: String!
    var spec: String!
    var age: String!
    var pers: String!
    
    //프로필수정 조건 변수
    var isEditingProfile = true
    
    var ageFirst: String!
    var ageSecond: String!
    var imageId: String!
    var email: String!
    var imageName: String!
    
    var quest1: String!
    var quest2: String!
    var quest3: String!
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var hoScrollView: UIScrollView!
    
    @IBOutlet weak var Enick: UILabel!
    @IBOutlet weak var Eimage: UIImageView!
    @IBOutlet weak var Ejob: UITextField!
    @IBOutlet weak var Ehobby: UITextField!
    @IBOutlet weak var Espot: UITextField!
    @IBOutlet weak var Epers: UITextField!
    @IBOutlet weak var Espec: UITextField!
    @IBOutlet weak var Eage: UITextField!
    @IBOutlet var EditView: UIView!
    
    @IBOutlet weak var hoListTextLabel: UILabel!
    
    @IBOutlet var QuestView: UIView!
    @IBOutlet weak var inputQuest1: UITextField!
    @IBOutlet weak var inputQuest2: UITextField!
    @IBOutlet weak var inputQuest3: UITextField!
    
    var agePickerView = UIPickerView()
    var pickAge = ["나이를 선택해주세요", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40"]
    
    var spotPickerView = UIPickerView()
    var pickSpot = ["지역을 선택해주세요", "서울", "경기", "부산", "강원", "충남", "충북", "경북", "경남", "전북", "전남", "해외"]
    
    var tap = UITapGestureRecognizer()
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var questButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        Eimage.removeGestureRecognizer(tap)
        
        myImage.layer.masksToBounds = true
        myImage.layer.cornerRadius = self.myImage.frame.height / 2
        myImage.frame.origin.y = 5
        myImage.layer.borderColor = UIColor.darkGray.cgColor
        myImage.layer.borderWidth = 0.5
        
        self.view.layer.backgroundColor = UIColor.colorWithRGBHex(hex: 0xEBEBEB, alpha: 1.0).cgColor
        
        //0xE6E6E6
        //0xF0F0F0
        
        self.navigationItem.title = "MyPage"
        self.title = "MyPage"
        
        doneButton.layer.cornerRadius = 8
        questButton.layer.cornerRadius = 8
        
        hoListTextLabel.sizeToFit()
        
        //NotificationCenter.default.addObserver(self, selector: #selector(MypageViewController.keyboardUp(notification:_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MypageViewController.keyboardUp(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MypageViewController.keyboardDown(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        let nib: UINib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")
        
        self.configureCollectionView()
        self.configureMainView()
        self.configurePickerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        findProfile()
        //configureScrollView()
        self.receiveHolist()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.hideEditQuestView()
        //self.hideEditView()
    }
    
    func configureMainView() {
        //(self.navigationController?.navigationBar.frame.size.height)! + 5
        self.firstView.frame = CGRect(x: self.view.frame.origin.x, y: self.firstView.frame.origin.y, width: self.view.frame.size.width, height: self.firstView.frame.size.height)
        
        self.secondView.frame = CGRect(x: self.view.frame.origin.x , y: collectionView.frame.origin.y + collectionView.frame.size.height + 5, width: self.view.frame.size.width, height: self.secondView.frame.size.height)
        //self.firstView.frame.size = CGSize(width: self.view.frame.size.width, height: self.secondView.frame.size.height)
        //self.secondView.frame.size = CGSize(width: self.view.frame.size.width, height: self.secondView.frame.size.height)
    }
    
    func downloadImage() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let Corerequest = NSFetchRequest<NSFetchRequestResult>()
        Corerequest.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(Corerequest)
            
            let match = objects[0] as! Profile
            email = match.value(forKey: "email") as? String
            
            imageId = match.value(forKey: "imageId") as! String
            
            let imageUrl = URL(string: ohnamiUrl + "/download/\(imageId!)")
            
            let data = NSData(contentsOf: imageUrl!)
            myImage.image = UIImage(data: data! as Data)

        } catch {
            print("error")
        }
    }
    
    func configurePickerView() {
        agePickerView.delegate = self
        agePickerView.tag = 1
        Eage.inputView = agePickerView
        
        spotPickerView.delegate = self
        spotPickerView.tag = 1
        Espot.inputView = spotPickerView
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.blue
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(MypageViewController.donePressed(sender:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(MypageViewController.cancelPressed(sender:)))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        Eage.inputAccessoryView = toolBar
        Espot.inputAccessoryView = toolBar
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return pickAge.count
        } else if pickerView.tag == 2{
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
            Eage.text = pickAge[row]
        } else if pickerView.tag == 2 {
            Espot.text = pickSpot[row]
        }
    }
    
    func cancelPressed(sender: UIBarButtonItem) {
        Eage.text = ""
        Espot.text = ""
        
        Eage.resignFirstResponder()
        Espot.resignFirstResponder()
    }
    
    func donePressed(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "정확하게 선택해주세요", message: "다시 시도해 주세요.", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        
        if Eage.text == "나이를 선택해주세요" {
            self.present(alert, animated: true, completion: nil)
        } else {
            Eage.resignFirstResponder()
        }
        
        if Espot.text == "지역을 선택해주세요" {
            self.present(alert, animated: true, completion: nil)
        } else {
            Espot.resignFirstResponder()
        }
    }
    
    func findProfile() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let Corerequest = NSFetchRequest<NSFetchRequestResult>()
        
        Corerequest.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(Corerequest)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                email = match.value(forKey: "email") as? String
                nick = match.value(forKey: "nick") as? String
                spot = match.value(forKey: "spot") as? String
                spec = match.value(forKey: "spec") as? String
                pers = match.value(forKey: "pers") as? String
                age = match.value(forKey: "age") as? String
                job = match.value(forKey: "job") as? String
                hobby = match.value(forKey: "hobby") as? String
                quest1 = match.value(forKey: "quest1") as? String
                quest2 = match.value(forKey: "quest2") as? String
                quest3 = match.value(forKey: "quest3") as? String
            }
        } catch {
            print("error")
        }
        
        downloadImage()
    }
    
    func showEditView() {
        self.configureEditView()
        EditView.frame = CGRect(x: self.view.frame.origin.x, y: (self.navigationController?.navigationBar.frame.size.height)!, width: self.view.frame.size.width, height: self.view.frame.size.height)
        EditView.tag = 100
        
        self.mainView.addSubview(EditView)
    }
    
    func showQuestView() {
        
        self.configureQuestView()
        
        QuestView.frame = CGRect(x: self.view.frame.origin.x, y: (self.navigationController?.navigationBar.frame.height)!, width: self.view.frame.size.width, height: self.view.frame.size.height)
        QuestView.tag = 200
        
        self.mainView.addSubview(QuestView)
    }
    
    func hideEditView() {
        DispatchQueue.main.async {
            self.doneEdit.setTitle("수정하기", for: .normal)
            self.Eimage.removeGestureRecognizer(self.tap)
            
            self.configureEditView()
            
            if let viewWithTag = self.view.viewWithTag(100) {
                viewWithTag.removeFromSuperview()
            } else {
                print("Error!!")
            }
        }
        //self.isEditingProfile = true

        
        //self.mainView.willRemoveSubview(EditView)
    }
    
    func hideEditQuestView() {
        DispatchQueue.main.async {
            self.doneEditRequest.setTitle("수정하기", for: .normal)
            
            self.configureQuestView()
            
            if let viewWithTag = self.view.viewWithTag(200) {
                viewWithTag.removeFromSuperview()
            } else {
                print("error!!")
            }
        }
        //self.isEditingProfile = true
    }
    
    @IBAction func editButton(_ sender: Any) {
        self.showEditView()
    }
    
    @IBAction func questButton(_ sender: Any) {
        self.showQuestView()
    }
    @IBAction func doneEditRequest(_ sender: Any) {
        
        if isEditingProfile {
            self.isEditingProfile = false
            doneEditRequest.setTitle("완료", for : .normal)
            
            inputQuest1.isEnabled = true
            inputQuest2.isEnabled = true
            inputQuest3.isEnabled = true
            
        } else {
            self.isEditingProfile = true
            doneEditRequest.setTitle("완료", for : .normal)
            
            inputQuest1.isEnabled = false
            inputQuest2.isEnabled = false
            inputQuest3.isEnabled = false
        }
        
    }
    
    @IBOutlet weak var doneEditRequest: UIButton!
    @IBOutlet weak var doneEdit: UIButton!
    
    func saveEditProfile() {
        let editUrl = URL(string: ohnamiUrl + "/profile")
        var request = URLRequest(url: editUrl!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let temp = email!
        imageName = temp.replacingOccurrences(of: "@", with: "")
        imageName = imageName.replacingOccurrences(of: ".", with: "")
        imageName = imageName + ".jpg"
        
        let json: [String : Any] = ["email" : "\(email!)", "nick" : "\(self.Enick.text!)", "age" : "\(self.Eage.text!)", "spot" : "\(self.Espot.text!)", "pers" : "\(self.Epers.text!)", "spec" : "\(self.Espec.text!)", "hobby" : "\(self.Ehobby.text!)", "job" : "\(self.Ejob.text!)", "imageId1" : "\(imageName!)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let contactRequest = NSFetchRequest<NSFetchRequestResult>()
        contactRequest.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(contactRequest)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                
                match.setValue(self.Eage.text!, forKey: "age")
                match.setValue(self.Espot.text!, forKey: "spot")
                match.setValue(self.Epers.text!, forKey: "pers")
                match.setValue(self.Espec.text!, forKey: "spec")
                match.setValue(self.Ehobby.text!, forKey: "hobby")
                match.setValue(self.Ejob.text!, forKey: "job")
                match.setValue(imageName, forKey: "imageId")
                
                do {
                    try managedObjectContext.save()
                    print("success")
                } catch {
                    print("save data error")
                }
            } else {
                print("nothing founded")
            }
            
        } catch {
            print("data error")
        }
        
        DispatchQueue.main.async {
            URLSession.shared.dataTask(with: request, completionHandler: {(data : Data?, response: URLResponse?, error: Error?) -> Void in
                
                if error != nil {
                    if (error?.localizedDescription)! == "The request timed out" {
                        print("samesame")
                        
                        let alert = UIAlertController(title: "서버에 접속할 수 없습니다.", message: "다시 시도해 주세요", preferredStyle: .alert)
                        let done = UIAlertAction(title: "확인", style: .default, handler: { action -> Void in
                            exit(0)
                        })
                        
                        alert.addAction(done)
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    self.uploadImage()
                    self.isEditingProfile = true
                }
            }) .resume()
        }
    }
    
    func configureCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.frame = CGRect(x: 0, y: self.collectionView.frame.origin.y, width: self.view.frame.size.width, height: self.collectionView.frame.size.height)
        //self.collectionView.frame.size.width = self.view.frame.size.width
        self.collectionView.center.x = self.view.center.x
        self.collectionView.layer.borderColor = UIColor.lightGray.cgColor
        self.collectionView.layer.borderWidth = 0.5
        
    }
//
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
//
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! CollectionViewCell
        
        cell.collectionTextLabel.text = collectionViewList[indexPath.row]
        cell.collectionImage.image = UIImage(named: collectionViewImageList[indexPath.row])
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            self.showNoticeView()
        case 1:
            self.showEventView()
        case 2:
            self.showsignoutView()
        case 3:
            self.showfaqView()
        case 4:
            print("Tapped item number 5")
        case 5:
            self.showAccountView()
        case 6:
            print("Tapped item number 7")
        case 7:
            print("Tapped item number 8")
        default:
            break
        }
    }
    
    func showNoticeView() {
//        noticeView.frame = CGRect(x: self.view.frame.origin.x, y: (self.navigationController?.navigationBar.frame.size.height)!, width: self.view.frame.size.width, height: self.view.frame.size.height)
//        noticeView.tag = 10
//        
//        self.mainView.addSubview(noticeView)
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "noticeSegue", sender: self)
        }
    }
    
    func showEventView() {
//        eventView.frame = CGRect(x: self.view.frame.origin.x, y: (self.navigationController?.navigationBar.frame.size.height)!, width: self.view.frame.size.width, height: self.view.frame.size.height)
//        eventView.tag = 11
//        
//        self.mainView.addSubview(eventView)
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "eventSegue", sender: self)
        }
    }
    
    func showsignoutView() {
//        signoutView.frame = CGRect(x: self.view.frame.origin.x, y: (self.navigationController?.navigationBar.frame.size.height)!, width: self.view.frame.size.width, height: self.view.frame.size.height)
//        signoutView.tag = 12
//        
//        self.mainView.addSubview(signoutView)
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "signoutSegue", sender: self)
        }
    }
    
    func showfaqView() {
//        faqView.frame = CGRect(x: self.view.frame.origin.x, y: (self.navigationController?.navigationBar.frame.size.height)!, width: self.view.frame.size.width, height: self.view.frame.size.height)
//        faqView.tag = 13
//        
//        self.mainView.addSubview(faqView)
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "faqSegue", sender: self)
        }
    }
    
    func showAccountView() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "accountSegue", sender: self)
        }
    }
    
    @IBOutlet weak var backButton: UIButton!
    @IBAction func backButton(_ sender: Any) {
//        if let viewWithTag = self.view.viewWithTag(10) {
//            viewWithTag.removeFromSuperview()
//        } else if let viewWithTag = self.view.viewWithTag(11) {
//            viewWithTag.removeFromSuperview()
//        } else if let viewWithTag = self.view.viewWithTag(12) {
//            viewWithTag.removeFromSuperview()
//        }else if let viewWithTag = self.view.viewWithTag(13) {
//            viewWithTag.removeFromSuperview()
//        } else {
//            print("Errorrrr!!!!!")
//        }
    }
    
    @IBAction func doneEdit(_ sender: UIButton) {
        if self.isEditingProfile{
            print("111111")
            self.isEditingProfile = false
            doneEdit.setTitle("완료", for: .normal)
            Ejob.isEnabled = true
            Espot.isEnabled = true
            Epers.isEnabled = true
            Ehobby.isEnabled = true
            Espec.isEnabled = true
            Eage.isEnabled = true
            
            tap = UITapGestureRecognizer(target: self, action: #selector(MypageViewController.showActionSheet))
            Eimage.isUserInteractionEnabled = true

            Eimage.addGestureRecognizer(tap)
        } else {
            print("111")
            self.isEditingProfile = true
            doneEdit.setTitle("수정하기", for: .normal)
            Ejob.isEnabled = false
            Espot.isEnabled = false
            Epers.isEnabled = false
            Ehobby.isEnabled = false
            Espec.isEnabled = false
            Eage.isEnabled = false
            
            Eimage.isUserInteractionEnabled = false
            Eimage.removeGestureRecognizer(tap)
            
            self.saveEditProfile()
            self.reloadInputViews()
        }
    }
    
    func uploadImage() {
        let imageUrl = URL(string: ohnamiUrl + "/uploads")
        let request = NSMutableURLRequest(url : imageUrl!)
        request.httpMethod = "POST"

        var boundary = "******"
        
        let imageData = UIImageJPEGRepresentation((Eimage.image?.resizeWithWidth(width: 200))!, 0.5)
        
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
        self.hideEditView()
        task.resume()
    }
    
    func applicationDidBecomeActive(notification: Notification) {
        print("didbecomeActive")
        self.downloadImage()
        self.configureEditView()
        self.configureQuestView()
    }
    
    func receiveHolist() {
        hoScrollView.scrollsToTop = true
        hoScrollView.bounces = true
        hoScrollView.isPagingEnabled = false
        hoScrollView.isScrollEnabled = true
        
        hoScrollView.layer.borderWidth = 0.5
        hoScrollView.layer.borderColor = UIColor.lightGray.cgColor
        
        hoScrollView.frame = CGRect(x: 0, y: self.hoScrollView.frame.origin.y, width: self.view.frame.size.width, height: self.hoScrollView.frame.size.height)
        hoScrollView.center.x = self.view.center.x
        
        hoScrollView.delegate = self
        
        let heartUrl = URL(string: ohnamiUrl + "/heart/ho/send")
        var request = URLRequest(url: heartUrl!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String : Any] = ["email" : "\(email!)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                if (error?.localizedDescription)! == "The request timed out." {
                    print("samesame")
                    
                    let alert = UIAlertController(title: "서버에 접속할 수 없습니다.", message: "다시 시도해 주세요", preferredStyle: .alert)
                    let done = UIAlertAction(title: "확인", style: .default, handler: { action -> Void in
                        exit(0)
                    })
                    
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    do {
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : NSArray]
                        
                        let arrJSON = parseJSON["ho_list"]
                        
                        var sendList = [String]()
                        
                        let hoCount = (arrJSON?.count)! - 1
                        
                        if (arrJSON?.count)! - 1 > 0 {
                            for i in 0 ... arrJSON!.count - 1 {
                                
                                let hoListView = Bundle.main.loadNibNamed("hoList", owner: self, options: nil)?[0] as! hoListView
                                
                                self.hoScrollView.contentSize = CGSize(width: CGFloat(60 * hoCount), height: self.hoScrollView.frame.size.height)
                                
                                hoListView.layer.cornerRadius = 8
                                let aObject = arrJSON?[i] as! [String: AnyObject]
                                
                                sendList.append(aObject["send_img"] as! String)
                                
                                let imageUrl = URL(string: ohnamiUrl + "/download/\(sendList[i])")
                                let data = NSData(contentsOf: imageUrl!)
                                
                                hoListView.frame = CGRect(x: 60 * CGFloat(i), y: 0, width: self.view.frame.size.width, height: self.hoScrollView.frame.size.height)
                                
                                hoListView.hoImage.frame = CGRect(x: 10, y: 5, width: hoListView.hoImage.frame.size.width, height: hoListView.hoImage.frame.size.height)
                                hoListView.hoImage.image = UIImage(data: data! as Data)
                                
                                self.hoScrollView.addSubview(hoListView)
                            }
                        }
                    } catch {
                        print("Error!!!!")
                    }
                }
            }
        }) .resume()
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.isEditingProfile = true
        self.hideEditView()

    }
    @IBAction func questBackBtn(_ sender: Any) {
        self.isEditingProfile = true
        self.hideEditQuestView()
    }
    
    func configureEditView() {
        let imageUrl = URL(string: ohnamiUrl + "/download/\(imageId!)")
        let data = NSData(contentsOf: imageUrl!)
        
        Eimage.layer.borderColor = UIColor.blue.cgColor
        Eimage.layer.borderWidth = 0.5
        Eimage.clipsToBounds = true
        Eimage.layer.cornerRadius = self.Eimage.frame.size.height / 2
        
        self.Eimage.image = UIImage(data: data! as Data)
        self.Enick.text = self.nick
        
        self.Ejob.text = self.job
        self.Eage.text = self.age
        self.Espot.text = self.spot
        self.Epers.text = self.pers
        self.Espec.text = self.spec
        self.Ehobby.text = self.hobby
        
        Ejob.isEnabled = false
        Eage.isEnabled = false
        Espot.isEnabled = false
        Epers.isEnabled = false
        Espec.isEnabled = false
        Ehobby.isEnabled = false
        
    }
    
    func configureQuestView() {
        self.inputQuest1.text = quest1
        self.inputQuest2.text = quest2
        self.inputQuest3.text = quest3
        
        inputQuest1.isEnabled = false
        inputQuest2.isEnabled = false
        inputQuest3.isEnabled = false
    }
    
    func showActionSheet() {
        let alert = UIAlertController(title: "프로필 등록", message: "프로필에 사용할 사진을 등록해주세요", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { action -> Void in
            self.useCamera()
        })
        let albumAction = UIAlertAction(title: "Album", style: .default, handler: { action -> Void in
            self.useAlbum()
            
        })
        
        alert.addAction(cameraAction)
        alert.addAction(albumAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func useCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        self.show(picker, sender: nil)
    }
    
    func useAlbum() {
        let picker = UIImagePickerController()
        picker.delegate = self
        self.show(picker, sender: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        Eimage.image = selectedImage
    }
    
    func keyboardUp(notification: Notification) {
        let keyboardFrame: CGRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0
        
            self.view.frame.origin.y -= keyboardFrame.size.height - 50
        }
        
    }
    
    @IBAction func testBtn(_ sender: Any) {
        SocketManager.sharedInstance.socketConn(nick: "파이브에스")
    }
    
    func keyboardDown(notification: Notification) {
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        Eimage.resignFirstResponder()
        Ejob.resignFirstResponder()
        Espot.resignFirstResponder()
        Epers.resignFirstResponder()
        Ehobby.resignFirstResponder()
        Eage.resignFirstResponder()
        Espec.resignFirstResponder()
        
        inputQuest1.resignFirstResponder()
        inputQuest2.resignFirstResponder()
        inputQuest3.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
