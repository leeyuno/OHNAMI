//
//  LikeViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 24/05/2017.
//  Copyright © 2017 Froglab. All rights reserved.
//

import UIKit
import CoreData
import FMDB

class LikeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var likeTableView: UITableView!
    
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likeNick: UILabel!
    @IBOutlet weak var likeMessage: UILabel!
    @IBOutlet weak var likeTime: UILabel!
    
//    var nickList:[String] = []
//    var imageList: [String] = []
//    var timeList: [String] = []
//    var cmptimeList: [String] = []
//    var msgKeyList = [String]()
//    var replyList = [[String]]()
    var likeList = [[String]]()
    var questList = [String]()
    
    var email: String = ""
    var nick: String = ""
    
    var act: Bool!
    var act2: Int!
    
    var receiver: String = ""
    var roomid: String = ""
    var remoteImage: URL!
    var msgKey: String!
    
    var count: Int!
    var returnCount: Int = 0
    
    @IBOutlet var detailView: UIView!
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var detailNick: UILabel!
    @IBOutlet weak var detailReply1: UILabel!
    @IBOutlet weak var detailReply2: UILabel!
    @IBOutlet weak var detailReply3: UILabel!
    @IBOutlet weak var detailQuest1: UILabel!
    @IBOutlet weak var detailQuest2: UILabel!
    @IBOutlet weak var detailQuest3: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.loadLikeList()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.deleteSQL()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(request)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                email = match.value(forKey: "email") as! String
                nick = match.value(forKey: "nick") as! String
            }
        } catch {
            print("error")
        }
        
        //self.configureTableView()
        //self.loadLikeList()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.hideDetailView()
    }
    
    func configureTableView() {
        let nib = UINib(nibName: "LikeTableViewCell", bundle: nil)
        likeTableView.register(nib, forCellReuseIdentifier: "LikeCell")
        likeTableView.tableFooterView = UIView()
        likeTableView.delegate = self
        likeTableView.dataSource = self
        //likeTableView.estimatedRowHeight = 55.0
        likeTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func loadLikeList() {
        let myUrl = URL(string: ohnamiUrl + "/heart/ho")
        var request = URLRequest(url: myUrl!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json:[String: Any] = ["email" : "\(email)"]
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
                do {
                    let parseJSON = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                    let listJSON = parseJSON["ho_list"] as? NSArray
                    if (listJSON?.count)! > 0 {
                        
                        for i in 0 ... listJSON!.count - 1 {
                            let aObject = listJSON?[i] as! [String : AnyObject]
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let tmpDate = formatter.date(from: aObject["rece_time"] as! String)
                            
                            let date = Date()
                            let nowDate = formatter.string(from: date)
                            let nowDate2 = formatter.date(from: nowDate)
                            
                                                        //시간 차이 구하는 부분
                            let compareTime = nowDate2?.timeIntervalSince(tmpDate!)
                            
                            let second = Int((compareTime?.truncatingRemainder(dividingBy: 60))!)
                            
                            let minute = Int((compareTime?.divided(by: 60))!)
                            
                            var string = ""
                            
                            let tmpTime = String(describing: compareTime!)
                            
                            if minute != 0 {
                                let hour = minute / 60
                                if hour != 0 {
                                    let day = hour / 24
                                    if day >= 1 {
                                        string = "\(day)일 전"
                                        //self.likeList[i].append(string)
                                        //self.likeList.append([aObject["rece"] as! String, aObject["rece_img"] as! String, aObject["rece_time"] as! String, aObject["rece_msgKey"] as! String, aObject["rece_reply1"] as! String, aObject["rece_reply2"] as! String, aObject["rece_reply3"] as! String, String(describing: aObject["rece_act"]), string])
                                    } else {
                                        string = "\(hour)시간 전"
                                        //self.likeList[i].append(string)
                                        //self.likeList.append([aObject["rece"] as! String, aObject["rece_img"] as! String, aObject["rece_time"] as! String, aObject["rece_msgKey"] as! String, aObject["rece_reply1"] as! String, aObject["rece_reply2"] as! String, aObject["rece_reply3"] as! String, String(describing: aObject["rece_act"]), string])
                                    }
                                } else {
                                    string = "\(minute)분 전"
                                    //self.likeList[i].append(string)
                                    //self.likeList.append([aObject["rece"] as! String, aObject["rece_img"] as! String, aObject["rece_time"] as! String, aObject["rece_msgKey"] as! String, aObject["rece_reply1"] as! String, aObject["rece_reply2"] as! String, aObject["rece_reply3"] as! String, String(describing: aObject["rece_act"]), string])
                                }
                            } else {
                                string = "\(second)초 전"
                                //self.likeList[i].append(string)
                            }
                            
                            let tempAct = aObject["rece_act"] as! Int
                            
                            self.likeList.append([aObject["rece"] as! String, aObject["rece_img"] as! String, aObject["rece_time"] as! String, aObject["rece_msgKey"] as! String, aObject["rece_reply1"] as! String, aObject["rece_reply2"] as! String, aObject["rece_reply3"] as! String, String(tempAct), string, tmpTime])
                        }
                    
                    }
                    let questJSON = parseJSON["quest"] as! [String : AnyObject]

                    self.questList.append(questJSON["quest1"] as! String)
                    self.questList.append(questJSON["quest2"] as! String)
                    self.questList.append(questJSON["quest3"] as! String)
                    
                    self.sortTable()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.configureTableView()
                    }

                } catch {
                    print("error")
                }
            }
        }) .resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sortTable() {
        print("sortTable")
        if likeList.count > 0 {
            for _ in 0 ... likeList.count - 1 {
                let sort = likeList.sorted(by: { ($0[9] as NSString).integerValue < ($1[9] as NSString).integerValue })
                
                self.likeList = sort
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.likeList.count > 0 {
            return self.likeList.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LikeCell", for: indexPath) as! LikeTableViewCell

        let imageUrl = URL(string: ohnamiUrl + "/download/\(self.likeList[indexPath.row][1])")
        let data = NSData(contentsOf: imageUrl!)
            
        cell.LikeImage.image = UIImage(data: data! as Data)
        cell.LikeTextLabel.text = "\(self.likeList[indexPath.row][0])님이 호감을 표시했습니다."
        cell.timeTextLabel.text = self.likeList[indexPath.row][8]
        
        if self.likeList[indexPath.row][7] == "1" {
            cell.choiceTextLabel.text = "좋아요"
            //cell.choiceTextLabel.textColor = UIColor.colorWithRGBHex(hex: 0x64FF64, alpha: 1.0)
            cell.choiceTextLabel.textColor = UIColor.green
            //cell.choiceTextLabel.layer.backgroundColor = UIColor.colorWithRGBHex(hex: 0x64FF64, alpha: 1.0).cgColor
        } else if self.likeList[indexPath.row][7] == "2" {
            cell.choiceTextLabel.text = "싫어요"
            cell.choiceTextLabel.textColor = UIColor.colorWithRGBHex(hex: 0xFF69B4, alpha: 1.0)
            //cell.choiceTextLabel.layer.backgroundColor = UIColor.colorWithRGBHex(hex: 0xFF69B4, alpha: 1.0).cgColor
        } else {
            cell.choiceTextLabel.text = "대기중"
            cell.choiceTextLabel.textColor = UIColor.darkGray
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.roomid = likeList[indexPath.row][3]
        self.receiver = likeList[indexPath.row][0]
        self.remoteImage = URL(string: ohnamiUrl + "/download/\(likeList[indexPath.row][1])")
        
        self.msgKey = likeList[indexPath.row][3]
        
        self.showDetailView(likeList[indexPath.row][0], likeList[indexPath.row][1], likeList[indexPath.row][3], likeList[indexPath.row][4], likeList[indexPath.row][5], likeList[indexPath.row][6])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    @IBOutlet weak var allowButton: UIButton!
    @IBAction func allowButton(_ sender: Any) {
        let url = URL(string: ohnamiUrl + "/heart/ho/check")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        act = true
        act2 = 1
        
        let json: [String : Any] = ["sender" : "\(self.nick)", "receiver" : "\(self.detailNick.text!)", "act" : "\(act!)", "msgKey" : "\(msgKey!)", "act2" : "\(act2!)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data : Data?, response: URLResponse?, error: Error?) -> Void in
            
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
                self.allowSegue()
            }
            
        }) .resume()
        
    }
    
    func allowSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "allowSegue", sender: self)
        }
    }
    
    @IBOutlet weak var rejectButton: UIButton!
    @IBAction func rejectButton(_ sender: Any) {
        let url = URL(string: ohnamiUrl + "/heart/ho/check")
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        act = false
        act2 = 2
        
        let json: [String : Any] = ["sender" : "\(self.nick)", "receiver" : "\(self.detailNick.text!)", "act" : "\(act!)", "msgKey" : "\(msgKey!)", "act2" : "\(act2!)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data : Data?, response: URLResponse?, error: Error?) -> Void in
            
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
            
            self.hideDetailView()
            
        }) .resume()
    }
    
    @IBAction func backButton(_ sender: Any) {
        if let viewWilthTag = self.view.viewWithTag(1) {
            viewWilthTag.removeFromSuperview()
        } else {
            print("일치하는 뷰가 없음")
        }
    }
    
    func hideDetailView() {
        if let viewWithTag = self.view.viewWithTag(1) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    func showDetailView(_ nick : String, _ img : String, _ msgKey: String, _ reply1 : String, _ reply2 : String, _ reply3 : String) {
        
        let imageUrl = URL(string: ohnamiUrl + "/download/\(img)")
        let data = NSData(contentsOf: imageUrl!)
        
        detailNick.text = nick
        detailImage.image = UIImage(data: data! as Data)
        detailReply1.text = reply1
        detailReply2.text = reply2
        detailReply3.text = reply3
        detailQuest1.text = questList[0]
        detailQuest2.text = questList[1]
        detailQuest3.text = questList[2]
        
        detailView.frame = CGRect(x: self.view.frame.origin.x, y: (self.navigationController?.navigationBar.frame.height)!, width: self.view.frame.size.width, height: self.view.frame.size.height)
        detailView.tag = 1
        
        self.view.addSubview(detailView)
    }
    
    func deleteSQL() {
        let dropTable = "DROP TABLE MESSAGES"
        
        let contactDB = FMDatabase(path: databasePath)
        
        if (contactDB.open()) {
            
            let result = contactDB.executeUpdate(dropTable, withArgumentsIn: [])
            
            if !result {
                print("Error: \(contactDB.lastErrorMessage())!")
            } else {
                print("success")
            }
        } else {
            print("Error: \(contactDB.lastErrorMessage())!")
        }
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "allowSegue" {
            let destinationController = segue.destination as! UINavigationController
            let target = destinationController.topViewController as! TalkViewController
            target.nick = self.nick
            target.receiver = self.receiver
            target.roomid = self.roomid
            target.remoteImage = self.remoteImage
            target.act = self.act
        }
        
    }
 

}
