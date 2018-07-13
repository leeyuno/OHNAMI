//
//  CardViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 24/05/2017.
//  Copyright © 2017 Froglab. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import FMDB

class CardViewController: UIViewController, UIScrollViewDelegate, CardViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet var detailView: UIView!
    var count: Int! = nil
    var pagecount: Int! = nil
    
    var GenderValue: String = ""
    var blureffectView: UIVisualEffectView!
    
    var nick: [String] = []
    var age: [Int] = []
    //var age_part: [String] = []
    var spec: [String] = []
    var spot: [String] = []
    var hobby: [String] = []
    var pers: [String] = []
    var job: [String] = []
    //var age_part_k: String = ""
    var imageId: [String] = []
    
    var caller: String = ""
    var receiver: String = ""
    
    var email: String = ""
    var Unick: String = ""
    var value: UInt32!
    var roomname: String = ""
    
    var act: String!
    
    @IBOutlet weak var Dhobby: UILabel!
    @IBOutlet weak var Dspec: UILabel!
    @IBOutlet weak var Dpers: UILabel!
    @IBOutlet weak var Dnick: UILabel!
    @IBOutlet weak var Djob: UILabel!
    @IBOutlet weak var Dspot: UILabel!
    @IBOutlet weak var Dage: UILabel!
    @IBOutlet weak var Dimage: UIImageView!
    
    @IBOutlet var replyView: UIView!
    @IBOutlet weak var Rquest1: UILabel!
    @IBOutlet weak var Rquest2: UILabel!
    @IBOutlet weak var Rquest3: UILabel!
    @IBOutlet weak var Rreply1: UITextField!
    @IBOutlet weak var Rreply2: UITextField!
    @IBOutlet weak var Rreply3: UITextField!
    
    //pushNotification 함수에서 푸시 보낼때 caller, receiver를 담기위한 변수
    var sendCaller: String = ""
    var sendReceiver: String = ""
    var remoteUrl: URL!
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    
    var refreshControl: UIRefreshControl!
    
    var TopContraint: NSLayoutConstraint!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.backgroundColor = UIColor.colorWithRGBHex(hex: 0xEBEBEB, alpha: 1.0).cgColor

        // Do any additional setup after loading the view.
        
//        let fileManager = FileManager.default
//        let dirPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//        databasePath = dirPaths[0].appendingPathComponent("messages.db").path
        
        pageControl.isHidden = true
        self.navigationItem.hidesBackButton = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.configurePageControl()
        }
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let Corerequest = NSFetchRequest<NSFetchRequestResult>()
        Corerequest.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(Corerequest)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                email = match.value(forKey: "email") as! String
                roomname = match.value(forKey: "email") as! String
                Unick = match.value(forKey: "nick") as! String
                GenderValue = match.value(forKey: "gender") as! String
            } else {
                print("Nothing Founded")
            }
        } catch {
            print("error")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(CardViewController.keyboardUp(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CardViewController.keyboardDown(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        configureScrollView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureReplyView()
        //navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.hideReplyView()
    }
    
    @IBAction func detailViewBack(_ sender: Any) {
        self.hideDetailView()
    }
    
    func showDetailView() {
        detailView.frame = CGRect(x: self.view.frame.origin.x, y: (self.navigationController?.navigationBar.frame.size.height)!, width: self.view.frame.size.width, height: self.view.frame.size.height)
        detailView.tag = 100
        
        Dhobby.text = self.hobby[pageControl.currentPage]
        Dpers.text = self.pers[pageControl.currentPage]
        Dspec.text = self.spec[pageControl.currentPage]
        Dnick.text = self.nick[pageControl.currentPage]
        Dspot.text = self.spot[pageControl.currentPage]
        Djob.text = self.job[pageControl.currentPage]
        Dage.text = String(self.age[pageControl.currentPage])
        
        let dimageId = self.imageId[pageControl.currentPage]
        
        let imageUrl = URL(string: ohnamiUrl + "/download/\(dimageId)")
        
        let data = NSData(contentsOf: imageUrl!)
        
        Dimage.layer.masksToBounds = true
        Dimage.layer.cornerRadius = self.Dimage.frame.height / 2
        Dimage.image = UIImage(data: data! as Data)
        
        self.mainView.addSubview(detailView)
        
    }
    
    //사용자에게 관심을 표하기 위해 답변을 작성하는 창을 띄우는 함수
    
    func configureReplyView() {
        Rreply1.text = ""
        Rreply2.text = ""
        Rreply3.text = ""
    }
    
    func showReplyView(caller: String, receiver: String) {
        sendCaller = caller
        sendReceiver = receiver
        
        let replyUrl = URL(string: ohnamiUrl + "/test0708")
        var replyRequest = URLRequest(url: replyUrl!)
        
        replyRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        replyRequest.httpMethod = "POST"
        
        let json: [String: Any] = ["nick" : "\(receiver)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        replyRequest.httpBody = jsonData
        
        URLSession.shared.dataTask(with: replyRequest, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                if (error?.localizedDescription)! == "The request timed out" {
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
                        
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                        
                        let arrJSON = parseJSON["result"]
                        
                        let aObject = arrJSON as! [String: AnyObject]
                        
                        let q1 = aObject["quest1"]
                        let q2 = aObject["quest2"]
                        let q3 = aObject["quest3"]
                        
                        self.replyView.frame = CGRect(x: self.view.frame.origin.x, y: (self.navigationController?.navigationBar.frame.size.height)!, width: self.view.frame.size.width, height: self.view.frame.size.height)
                        self.replyView.tag = 200
                        
                        self.Rquest1.text = q1 as? String
                        self.Rquest2.text = q2 as? String
                        self.Rquest3.text = q3 as? String
                        
                        self.mainView.addSubview(self.replyView)
                        
                        
                    } catch {
                        print("parse Error")
                    }
                }

            }
        }) .resume()
    }
    
    //질문에 대한 답을 적어 다른사용자에게 보내는 함수
    func sendReply(caller: String, receiver: String, reply1: String, reply2: String, reply3: String) {
        print("sendReply")
        value = arc4random()
        
        let temp = roomname.replacingOccurrences(of: ".", with: "")
        roomname = temp.replacingOccurrences(of: "@", with: "")
        
        roomname = roomname + "\(value!)"
        
        self.caller = caller
        self.receiver = receiver
        
        let pushUrl = URL(string: ohnamiUrl + "/pushA")
        
        var request = URLRequest(url: pushUrl!)
        let json: [String: Any] = ["sender" : "\(self.caller)", "receiver" : "\(self.receiver)", "msgKey" : "\(roomname)", "reply1" : "\(reply1)", "reply2" : "\(reply2)", "reply3" : "\(reply3)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {( data: Data?, response: URLResponse?, error: Error?) -> Void in
            
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
                self.joinRoom()
            }
        }) .resume()
    }
    
    //질문에 대한 대답 서브뷰를 제거하는 버튼
    @IBAction func exitReplyView(_ sender: Any) {
        self.hideReplyView()
    }
    
    @IBAction func sendReplyButton(_ sender: Any) {
        //self.pushNotification(sendCaller, sendReceiver)
        sendReply(caller: sendCaller, receiver: sendReceiver, reply1: self.Rreply1.text!, reply2: self.Rreply2.text!, reply3: self.Rreply3.text!)
        
    }
    
    func hideReplyView() {
        
        Rreply1.text = ""
        Rreply2.text = ""
        Rreply3.text = ""
        
        if let viewWithTag = self.view.viewWithTag(200) {
            viewWithTag.removeFromSuperview()
        } else {
            print("Nooooo")
        }
        
        self.mainView.willRemoveSubview(replyView)
    }
    
    //사용자 상세정보창을 없애는 함수
    func hideDetailView() {
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }else{
            print("No!")
        }
        self.mainView.willRemoveSubview(detailView)
    }
    
    func configureRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "pull to refresh")
        refreshControl.addTarget(self, action: #selector(CardViewController.configureScrollView), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)
    }
    
    func configureScrollView() {
        scrollView.scrollsToTop = true
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = true
        
        self.automaticallyAdjustsScrollViewInsets = false
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        
        scrollView.layer.backgroundColor = UIColor.colorWithRGBHex(hex: 0xEBEBEB, alpha: 1.0).cgColor
        scrollView.bounces = false
        
        scrollView.frame = CGRect(x: self.scrollView.frame.origin.x, y: self.scrollView.frame.origin.y, width: self.scrollView.frame.size.width, height: self.scrollView.frame.size.height)
        //scrollView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        scrollView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        //scrollView.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: 0.9).isActive = true
        scrollView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0.9).isActive = true
        
        scrollView.delegate = self
        
        let myUrl = URL(string: ohnamiUrl + "/match_ran")
        var request = URLRequest(url: myUrl!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = ["email" : "\(email)", "sex" : "\(GenderValue)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
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
                DispatchQueue.main.async {
                    
                    do {
                        let parseJSON = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: NSArray]
                        let arrJSON = parseJSON["user_list"]
                        
                        self.count = arrJSON!.count - 1
                        
                        self.pagecount = arrJSON!.count
                        
                        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: self.scrollView.frame.size.height * CGFloat(self.pagecount))
                        
                        if self.pagecount > 0 {
                            for i in 0 ... self.count! {
                                let aObject = arrJSON?[i] as! [String:AnyObject]
                                
                                self.age.append(aObject["age"] as! Int)
                                self.hobby.append(aObject["hobby"] as! String)
                                self.imageId.append(aObject["imageId1"] as! String)
                                self.job.append(aObject["job"] as! String)
                                self.nick.append(aObject["nick"] as! String)
                                self.pers.append(aObject["pers"] as! String)
                                self.spec.append(aObject["spec"] as! String)
                                self.spot.append(aObject["spot"] as! String)
                                
                                let imageValue: String! = self.imageId[i]
                                var imageName: String = imageValue!
                                let imageUrl = URL(string: ohnamiUrl + "/download/\(imageName)")
                                self.remoteUrl = imageUrl!
                                
                                let data = NSData(contentsOf: imageUrl!)
                                
                                let tap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapped))
                                tap.numberOfTapsRequired = 2
                                
                                let blureffect = UIBlurEffect(style: UIBlurEffectStyle.light)
                                
                                self.blureffectView = UIVisualEffectView(effect: blureffect)
                                self.blureffectView.frame = CGRect(x: self.scrollView.frame.origin.x, y: CGFloat(i) * self.scrollView.frame.size.height + 15, width: self.scrollView.frame.size.width * 0.80, height: self.scrollView.frame.size.height * 0.80)
                                
                                self.blureffectView.center.x = self.scrollView.center.x
                                self.blureffectView.layer.cornerRadius = 8
                                self.blureffectView.tag = i
                                
                                let cardView = Bundle.main.loadNibNamed("CardView", owner: self, options: nil)?[0] as! CardView
                                
                                cardView.frame = CGRect(x: self.scrollView.frame.origin.x, y: CGFloat(i) * self.scrollView.frame.size.height + 10, width: self.scrollView.frame.size.width * 0.9, height: self.scrollView.frame.size.height * 0.95)
                                
                                cardView.center.x = self.scrollView.center.x
                                
                                cardView.layer.cornerRadius = 8
                                
                                let ageTmp: String = "\(self.age[i])"
                                
                                cardView.age.text = ageTmp
                                cardView.nick.text = self.nick[i]
                                cardView.spot.text = self.spot[i]
                                cardView.job.text = self.job[i]
                                
                                cardView.Cimage.image = UIImage(data: data! as Data)
                                
                                cardView.CardViewDelegate = self
                                
                                self.blureffectView.addGestureRecognizer(tap)
                                self.scrollView.addSubview(cardView)
                                self.scrollView.addSubview(self.blureffectView)
                            }
                        }
                        
                    } catch {
                        print("Error")
                    }
                }

            }
        }).resume()
    }
    
    func doubleTapped() {
        let pageNumber = pageControl.currentPage
        
        let alert = UIAlertController(title: "카드를 확인하시겠습니까?", message: "하트가 소모됩니다", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인하기", style: .default, handler: {( action: UIAlertAction!) in
            for subview in self.scrollView.subviews {
                if subview is UIVisualEffectView && subview.tag == pageNumber {
                    subview.removeFromSuperview()
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func configurePageControl() {
        pageControl.numberOfPages = pagecount
        
        pageControl.currentPage = 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = floor(scrollView.contentOffset.y / scrollView.frame.size.height);
        
        // Set the new page index to the page control.
        pageControl.currentPage = Int(currentPage)
    }
    
    @IBAction func changePage(_ sender: AnyObject) {
        // Calculate the frame that should scroll to based on the page control current page.
        var newFrame = scrollView.frame
        //newFrame.origin.x = newFrame.size.width * CGFloat(pageControl.currentPage)
        newFrame.origin.y = newFrame.size.height * CGFloat(pageControl.currentPage)
        scrollView.scrollRectToVisible(newFrame, animated: true)
    }
    
    func sendHeart(caller : String, receiver : String) {
        sendCaller = caller
        sendReceiver = receiver
        //self.showReplyView()

        //self.heartSegue()
        
        //self.pushNotification(caller, receiver)
    }
    
    func createEntiy(userName: String) {
        var properties = Array<NSAttributeDescription>()
        
        let user = NSAttributeDescription()
        user.name = "\(userName)"
        user.attributeType = .stringAttributeType
        user.isOptional = false
        user.isIndexed = true
        properties.append(user)
    }
    
    func joinRoom() { 
        
        DispatchQueue.main.async {
            self.heartSegue()
        }
    }
    
    func pushNotification(_ caller : String, _ receiver : String) {
        value = arc4random()
        
        let temp = roomname.replacingOccurrences(of: ".", with: "")
        roomname = temp.replacingOccurrences(of: "@", with: "")
        
        roomname = roomname + "\(value!)"
        
        self.caller = caller
        self.receiver = receiver
        
        let pushUrl = URL(string: ohnamiUrl + "/pushA")
        
        var request = URLRequest(url: pushUrl!)
        let json: [String: Any] = ["sender" : "\(self.caller)", "receiver" : "\(self.receiver)", "msgKey" : "\(roomname)"]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {( data: Data?, response: URLResponse?, error: Error?) -> Void in
            
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
                self.joinRoom()
            }
        }) .resume()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        Rreply1.resignFirstResponder()
        Rreply2.resignFirstResponder()
        Rreply3.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func keyboardUp(notification: Notification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0
            
            self.view.frame.origin.y -= 80
        }
    }
    
    func keyboardDown(notification: Notification) {
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0
        }
    }
    
    func heartSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "heartSegue", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "heartSegue" {
            let destinationController = segue.destination as! UINavigationController
            let target = destinationController.topViewController as! TalkViewController
            target.nick = self.caller
            target.receiver = self.receiver
            target.roomid = self.roomname
            target.remoteImage = self.remoteUrl
            target.act = false
        }
    }
    
}
