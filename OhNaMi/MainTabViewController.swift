
//
//  MainTabViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 24/05/2017.
//  Copyright © 2017 Froglab. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import FMDB
import UserNotifications

var badgeCount = 0

class MainTabViewController: UITabBarController {

    @IBOutlet weak var mainTabBar: UITabBar!
    
    var userArray = [String]()
    var timeArray = [String]()
    var messageArray = [String]()
    var roomIdArray = [String]()
    var receiverArray = [String]()
    var fcmIdArray = [String]()
    
    var email: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        self.tabBar.backgroundColor = UIColor.colorWithRGBHex(hex: 0x4CD964, alpha: 1.0)
        self.tabBar.tintColor = UIColor.white
        
        //navigationItem.title = "ONAMI"
        
        self.selectedIndex = 1
        self.setNavigationBar()
        //self.createSQLite()
        
        NotificationCenter.default.addObserver(self, selector: #selector(fcmReceive(_:)), name: NSNotification.Name(rawValue: "pushNoti"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(backgroundfcmReceive(_:)), name: NSNotification.Name(rawValue: "backgroundNoti"), object: nil)

        // Do any additional setup after loading the view.
        
        //self.checkCoreData()
        
        //SocketManager.sharedInstance.OSocketConnect()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        SocketManager.sharedInstance.receiveMessage { (messageInfo) -> Void in
//            print("messageInfo : \(messageInfo)")
//        }
        
//        let nick = UserDefaults.standard.object(forKey: "nick")
//        let message = UserDefaults.standard.object(forKey: "message")
//        let receiver = UserDefaults.standard.object(forKey: "recevier")
//        let time = UserDefaults.standard.object(forKey: "time")
//        let key = UserDefaults.standard.object(forKey: "key")
//        
//        print(nick, message, receiver, time, key)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(receiveNoti(notification:)), name: NSNotification.Name(rawValue: "pushNoti"), object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    func backgroundfcmReceive(_ notification: Notification) {
        badgeCount = badgeCount + 1
        
        mainTabBar.items?[0].badgeValue = String(badgeCount)
        mainTabBar.items?[0].badgeColor = UIColor.red
        
        let userInfo = notification.userInfo
        
        let notiNick = userInfo?["nick"]
        let notiMessage = userInfo?["message"]
        let notiTime = userInfo?["time"]
        let notiReceiver = userInfo?["receiver"]
        let notiRoomid = userInfo?["key"]
        let notiId = userInfo?["gcm.message_id"]
        
        print(notiNick, notiMessage, notiTime, notiReceiver, notiRoomid, notiId)
        
        if notiNick != nil {
            self.userArray.append(notiNick as! String)
            self.messageArray.append(notiMessage as! String)
            self.timeArray.append(notiTime as! String)
            self.receiverArray.append(notiReceiver as! String)
            self.roomIdArray.append(notiRoomid as! String)
            self.fcmIdArray.append(notiId as! String)
            
            self.insertMessage()
        } else {
            print("backNotitititititi")
        }
    }
    
    func fcmReceive(_ notification : Notification) {
        
        badgeCount = badgeCount + 1
        
        mainTabBar.items?[0].badgeValue = String(badgeCount)
        mainTabBar.items?[0].badgeColor = UIColor.red
        
        let userInfo = notification.userInfo
        
        let notiNick = userInfo?["nick"]
        let notiMessage = userInfo?["message"]
        let notiTime = userInfo?["time"]
        let notiReceiver = userInfo?["receiver"]
        let notiRoomid = userInfo?["key"]
        let notiId = userInfo?["gcm.message_id"]
        
        if notiNick != nil {
            self.userArray.append(notiNick as! String)
            self.messageArray.append(notiMessage as! String)
            self.timeArray.append(notiTime as! String)
            self.receiverArray.append(notiReceiver as! String)
            self.roomIdArray.append(notiRoomid as! String)
            self.fcmIdArray.append(notiId as! String)
            
            self.insertMessage()
            
            print("tabBar fcmReceive")
        } else {
            print("pushnotitititititi")
        }
    }
    
    func insertMessage() {
        print("insertMessage")
        let contactDB = FMDatabase(path: databasePath)
        
        if self.userArray.count > 0 {
            for i in 0 ... self.userArray.count - 1 {
                let localMessage = messageArray[i]
                let localNick = userArray[i]
                let localReceiver = receiverArray[i]
                let localRoomid = roomIdArray[i]
                let localTime = timeArray[i]
                let localId = fcmIdArray[i]

                if contactDB.open() {
                    let insertSQL = "INSERT INTO MESSAGES (nick, message, roomid, receiver, create_at, fcmid) VALUES('\(localNick)', '\(localMessage)', '\(localRoomid)', '\(localReceiver)', '\(localTime)', '\(localId)')"
                    
                    let results = contactDB.executeUpdate(insertSQL, withArgumentsIn: [])
                    
                    if !results {
                        print("Error : \(contactDB.lastErrorMessage())")
                    } else {
                        print("Save success")
                    }
                } else {
                    print("Error : \(contactDB.lastErrorMessage())")
                }
            }
            
            userArray.removeAll()
            messageArray.removeAll()
            timeArray.removeAll()
            receiverArray.removeAll()
            roomIdArray.removeAll()
            fcmIdArray.removeAll()
        }
    }
    
    func setNavigationBar() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        
        var myImage = UIImage(named: "sface_white")
        myImage = myImage?.resizeWithWidth(width: 100)
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        let compressData = UIImageJPEGRepresentation(myImage!, 1)
        imageView.image = UIImage(data: compressData!)
        
        navigationItem.titleView = imageView
    }
    
    func createSQLite() {
        let fileManager = FileManager.default
        let dirPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        databasePath = dirPaths[0].appendingPathComponent("messages.db").path

        if !fileManager.fileExists(atPath: databasePath) {
            let contactDB = FMDatabase(path: databasePath)
            
            if contactDB == nil {
                print("Error : \(contactDB.lastErrorMessage())")
            }
            
            if (contactDB.open()) {
                let sql_stmt = "CREATE TABLE IF NOT EXISTS MESSAGES (ID INTEGER PRIMARY KEY AUTOINCREMENT, nick TEXT, message TEXT, roomid TEXT, receiver TEXT, create_at TEXT, fcmid TEXT)"
                
                if !(contactDB.executeStatements(sql_stmt)) {
                    print("Error : \(contactDB.lastErrorMessage())")
                } else {
                    print("DB create success")
                }
                
                contactDB.close()
            } else {
                print("Error : \(contactDB.lastErrorMessage())")
            }
        } else {
            print("database already created")
        }
    }
    
    func checkCoreData() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(request)
            
            if objects.count > 0 {
                for i in 0 ... objects.count {
                    let match = objects[i] as! Profile
                }
            } else {
                print("nothing founded")
            }
        } catch {
            print("error")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureCoreData()
        self.createSQLite()
        
        
    }
    
    func configureCoreData() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(request)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                email = match.value(forKey: "email") as! String
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
    
    func configureTabBar() {
        mainTabBar.items?[2].badgeValue = "call"
        //tabBarController?.tabBar.items?[2].badgeValue = "Hey"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "pushNoti"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "backgroundNoti"), object: nil)
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
