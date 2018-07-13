//
//  MessageListViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 2017. 6. 3..
//  Copyright © 2017년 Froglab. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import FMDB

class MessageListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {

    @IBOutlet weak var MessageList: UITableView!
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var email: String = ""
    var str: String = ""
    var roomname: String = ""
    var value: UInt32!
    var nick: String = ""
    var receiver: String = ""
    var act: Bool!
    
    //var userArray = [String]()
    //var timeArray = [String]()
    //var messageArray = [String]()
    //var roomIdArray = [String]()
    //var receiverArray = [String]()
    var chatArray = [String]()
    var chatList = [[String]]()
    //var cmptimeList = [String]()
    var localNick = [String]()
    var listMessage = [[String]]()
    var actList = [Bool]()
    
    var count: Int = 0
    
    var imageArray = [String]()
    
    var configureOK = false
    
    var remoteUrl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileManager = FileManager.default
        
        let dirPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        var databasePath = dirPaths[0].appendingPathComponent("messages.db").path
        
        self.navigationItem.title = "MessageList"
        
        NotificationCenter.default.addObserver(self, selector: #selector(fcmReceive(notification:)), name: NSNotification.Name(rawValue: "pushNoti"), object: nil)
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(request)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                email = match.value(forKey: "email") as! String
                nick = match.value(forKey: "nick") as! String
            } else {
                print("nothing founded")
            }
        } catch {
            print("error")
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.receiveChatList()
//        self.loadChatList()
        
        //self.configureTableView()
        
        //NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: .UIApplicationDidBecomeActive, object: nil)
        
        
        
        tabBarItem.badgeValue = nil
        badgeCount = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        receiveChatList()
        //loadChatList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sortTable() {
        print("sortTable")
        if listMessage.count > 0 {
            for _ in 0 ... listMessage.count - 1 {
                let sort = listMessage.sorted(by: { ($0[6] as NSString).integerValue < ($1[6] as NSString).integerValue })
                self.listMessage = sort
            }
        }
    }
    
    func fcmReceive(notification: Notification) {
        print("messageList fcm")
        
        self.receiveChatList()
        
    }
    
//    func insertMessage() {
//        let contactDB = FMDatabase(path: databasePath)
//        
//        for i in 0 ... self.userArray.count - 1 {
//            let localMessage = messageArray[i]
//            let localNick = userArray[i]
//            let localReceiver = receiverArray[i]
//            let localRoomid = roomIdArray[i]
//            let localTime = timeArray[i]
//            
//            if contactDB.open() {
//                let insertSQL = "INSERT INTO MESSAGES (nick, message, roomid, receiver, create_at) VALUES('\(localNick)', '\(localMessage)', '\(localRoomid)', '\(localReceiver)', '\(localTime)')"
//                
//                let results = contactDB.executeUpdate(insertSQL, withArgumentsIn: [])
//                
//                if !results {
//                    print("Error : \(contactDB.lastErrorMessage())")
//                } else {
//                    print("Save success")
//                }
//            } else {
//                print("Error : \(contactDB.lastErrorMessage())")
//            }
//        }
//        
//        userArray.removeAll()
//        messageArray.removeAll()
//        timeArray.removeAll()
//        receiverArray.removeAll()
//        roomIdArray.removeAll()
//        
//        //self.MessageList.reloadData()
//        receiveChatList()
//        
//    }
    
    func receiveChatList() {
        print("receiveChatList")
        let messageUrl = URL(string: ohnamiUrl + "/chat/list")
        var request = URLRequest(url: messageUrl!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json:[String: Any] = ["email" : "\(self.email)"]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: {( data: Data?, response: URLResponse?, error: Error?) -> Void in
            
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
                do {
                    let parseJSON = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: NSArray]
                    let arrJSON = parseJSON["msgKey"]!
                    
                    self.count = arrJSON.count
                    
                    if self.count > 0 {
                        for i in 0 ... self.count - 1 {
                            let aObject = arrJSON[i] as! [String: AnyObject]
                            
                            self.chatArray.append(aObject["key"] as! String)
                            self.imageArray.append(aObject["img"] as! String)
                            self.actList.append(aObject["act"] as! Bool)
                        }
                    }
                    self.loadChatList()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.configureTableView()
                        //self.reloadTableViewData()
                    }
                    
                } catch {
                    print("error")
                }
            }
        }) .resume()

    }
    
    //chatList를 만드는 함수
    func loadChatList() {
        print("loadChatList")
        let contactDB = FMDatabase(path: databasePath)
        
        self.listMessage.removeAll()
        
        if (contactDB.open()) {
            if self.count > 0 {
                for i in 0 ... self.count - 1 {
                    
                    let query = "SELECT * FROM MESSAGES WHERE roomid = '\(self.chatArray[i])'"
                    let results = contactDB.executeQuery(query, withArgumentsIn: [])
                    
                    if results == nil {
                        print("Error :\(contactDB.lastErrorMessage())")
                    } else {
                        //self.listMessage.removeAll()
                        while results?.next() == true {
                            let message: String = (results?.string(forColumn: "message"))!
                            let sender: String = (results?.string(forColumn: "nick"))!
                            let receiver: String = (results?.string(forColumn: "receiver"))!
                            let roomid: String = (results?.string(forColumn: "roomid"))!
                            let time: String = (results?.string(forColumn: "create_at"))!
                            chatList.append(["\(message)", "\(receiver)", "\(sender)", "\(roomid)", "\(time)"])
                        }
                        
                        //listMessage.removeAll()
                        if chatList.count > 0 {
                            let tmpImage = imageArray[i]
//                            let tmpAct = actList[i]
                            let tmpAct = String(actList[i])
                            for i in 0 ... chatList.count - 1 {
                                if i == chatList.count - 1 {

                                    let date = Date()
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    
                                    let nowDate = formatter.string(from: date)
                                    let nowDate2 = formatter.date(from: nowDate)
                                    var string = ""
                                    
                                    let cmpTime = formatter.date(from: chatList[i][4])
                                    
                                    let compareTime = nowDate2?.timeIntervalSince(cmpTime!)
                            
                                    let tmpTime = String(describing: compareTime!)
                                    
                                    let second = Int((compareTime?.truncatingRemainder(dividingBy: 60))!)
                                    let minute = Int((compareTime?.divided(by: 60))!)
                                    
                                    if minute != 0 {
                                        let hour = minute / 60
                                        if hour != 0 {
                                            let day = hour / 24
                                            if day >= 1 {
                                                string = "\(day)일 전"
                                                //self.cmptimeList.append(string)
                                                //self.listMessage[i].append(string)
                                                //self.listMessage.append([chatList[i][0], chatList[i][1], chatList[i][2], chatList[i][3], chatList[i][4], imageArray[i], tmpTime, string, actList[i]])
                                            } else {
                                                string = "\(hour)시간 전"
                                                //self.cmptimeList.append(string)
                                                //self.listMessage[i].append(string)
                                                //self.listMessage.append([chatList[i][0], chatList[i][1], chatList[i][2], chatList[i][3], chatList[i][4], imageArray[i], tmpTime, string, actList[i]])
                                            }
                                        } else {
                                            string = "\(minute)분 전"
                                            //self.cmptimeList.append(string)
                                            //self.listMessage[i].append(string)
                                                //self.listMessage.append([chatList[i][0], chatList[i][1], chatList[i][2], chatList[i][3], chatList[i][4], imageArray[i], tmpTime, string, actList[i]])
                                        }
                                    } else {
                                        string = "\(second)초 전"
                                        //self.cmptimeList.append(string)
                                        //self.listMessage[i].append(string)
                                                //self.listMessage.append([chatList[i][0], chatList[i][1], chatList[i][2], chatList[i][3], chatList[i][4], imageArray[i], tmpTime, string, actList[i]])
                                    }
                                    self.listMessage.append([chatList[i][0], chatList[i][1], chatList[i][2], chatList[i][3], chatList[i][4], tmpImage, tmpTime, string, tmpAct])
                                }
                                
                            }
                            
                        }

                    }
                    //chatList = [["", ""]]
                    chatList.removeAll()
                }
            }
            contactDB.close()
        } else {
            print("Error : \(contactDB.lastErrorMessage())")
        }

        self.count = listMessage.count
    
        self.sortTable()
    }
    
    func configureTableView() {
        print("configureTable")
        let nib = UINib(nibName: "MListTableViewCell", bundle: nil)
        MessageList.register(nib, forCellReuseIdentifier: "MListCell")
        MessageList.tableFooterView = UIView()
        MessageList.delegate = self
        MessageList.dataSource = self
        
        MessageList.reloadData()
    }
    
    @IBAction func joinButton(_ sender: Any) {
        self.selectedRoomSegue()
    }
    
    func selectedRoomSegue() {
        print("selectedRoomsegue")
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "selectedRoomSegue", sender: self)
        }
        
    }
    
    func leaveChatRoom(_ msgKey: Int) {
        print("leaveChatRoom")
        let leaveUrl = URL(string: ohnamiUrl + "/chat/remove")
        var request = URLRequest(url: leaveUrl!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json: [String : Any] = ["nick" : "\(self.nick)", "roomname" : "\(listMessage[msgKey][3])"]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
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
                
            }
            
        }) .resume()
        
    }
    
    func deleteChatRoom(_ indexPath : Int) {
        print("deleteChatRoom")
        let contactDB = FMDatabase(path: databasePath)
        
        if (contactDB.open()) {
            let deleteSQL = "DELETE FROM MESSAGES WHERE roomid = '\(listMessage[indexPath][3])'"
            
            let result = contactDB.executeUpdate(deleteSQL, withArgumentsIn: [])
            
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
    
    func reloadTableViewData() {
        print("reload")
        MessageList.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listMessage.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.nick != listMessage[indexPath.row][1] {
            receiver = listMessage[indexPath.row][1]
        } else {
            receiver = listMessage[indexPath.row][2]
        }
        
        self.act = Bool(listMessage[indexPath.row][8])
        
        roomname = listMessage[indexPath.row][3]
        
        remoteUrl = URL(string: ohnamiUrl + "/download/\(imageArray[indexPath.row])")
        
        self.selectedRoomSegue()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MListCell", for: indexPath) as! MListTableViewCell

        let imageUrl = URL(string: ohnamiUrl + "/download/\(listMessage[indexPath.row][5])")

        let data = NSData(contentsOf: imageUrl!)
        
        if self.nick != listMessage[indexPath.row][1] {
            cell.Mnick.text = listMessage[indexPath.row][1]
        } else {
            cell.Mnick.text = listMessage[indexPath.row][2]
        }
        
        cell.Mmessage.text = listMessage[indexPath.row][0]
        cell.Mtime.text = listMessage[indexPath.row][7]
        cell.Mimage.image = UIImage(data: data! as Data)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    //tableview delete
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        print("editing table")
        let deleteButton = UITableViewRowAction(style: .normal, title: "나가기", handler: { (action, index) -> Void in

            self.leaveChatRoom(indexPath.row)
            self.deleteChatRoom(indexPath.row)
            
            self.listMessage.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            //self.count = self.count - 1
            
        })
        
        deleteButton.backgroundColor = UIColor.red

        return [deleteButton]
    }
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(self.MessageList.responds(to: #selector(setter: UITableViewCell.separatorInset))) {
            self.MessageList.separatorInset = .zero
        }
        
    if(self.MessageList.responds(to: #selector(setter: UIView.layoutMargins))) {
            self.MessageList.layoutMargins = .zero
        }
        
        if(cell.responds(to: #selector(setter: UIView.layoutMargins))) {
            cell.layoutMargins = .zero
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectedRoomSegue" {
            let destinationController = segue.destination as! UINavigationController
            let target = destinationController.topViewController as! TalkViewController
            target.nick = self.nick
            target.receiver = self.receiver
            target.roomid = self.roomname
            target.remoteImage = self.remoteUrl
            target.act = self.act
        }
    }
 
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "pushNoti"), object: nil)
    }

}
