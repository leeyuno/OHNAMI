//
//  TalkViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 2017. 6. 15..
//  Copyright © 2017년 Froglab. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FMDB
import CoreData
import SocketIO

class TalkViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var messages = [JSQMessage]()
    let defaults = UserDefaults.standard
    
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    
    var useImage: UIImage!
    
    var userArray = [String]()
    var timeArray = [String]()
    var messageArray = [String]()
    var chatList = [[String]]()
    
    fileprivate var displayName: String!
    
    var nick: String = ""
    var nowDate: String = ""
    var roomid: String = ""
    var receiver: String = ""
    var localImage: String = ""
    var act: Bool!
    
    var returnValue: Int = 0
    
    var remoteImage: URL!
    
    //var Cnick: String = ""
    var Ctext: String = ""
    var Ctime: String = ""
    //var Creceiver: String = ""
    //var Croomname: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileManager = FileManager.default
        
        let dirPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        var databasePath = dirPaths[0].appendingPathComponent("messages.db").path

        self.configureNick()
        
        self.setupBackButton()
        self.setupBubble()
        
        self.emptyCheck()
        
        collectionView?.collectionViewLayout.springinessEnabled = false
        
        automaticallyScrollsToMostRecentMessage = true
        
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
        
        self.inputToolbar.contentView.leftBarButtonItem = nil
        
        self.loadMessages()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(notification:)), name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: .UIApplicationWillEnterForeground, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate(_:)), name: .UIApplicationWillTerminate, object: nil)
        
        SocketManager.sharedInstance.OSocketConnect()
        SocketManager.sharedInstance.socketConn(nick: self.nick)
        SocketManager.sharedInstance.joinRoom(roomname: roomid, nick: nick)
        
        SocketManager.sharedInstance.receiveMessage()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationTitleImage()
        collectionView.collectionViewLayout.springinessEnabled = true
        self.emptyCheck()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func applicationDidEnterBackground(notification: Notification) {
        print("applicationDidEnterBacground")
        SocketManager.sharedInstance.disConnect(nick: self.nick, roomname: self.roomid)
        SocketManager.sharedInstance.OSocketDisConnect()
    }
    
//    func applicationDidBecomeActive(_ notification: Notification) {
//        print("applicationDidBecomeActive")
//        SocketManager.sharedInstance.OSocketConnect()
//        SocketManager.sharedInstance.socketConn(nick: self.nick)
//        SocketManager.sharedInstance.joinRoom(roomname: self.roomid, nick: self.nick)
//    }
    
    func applicationWillEnterForeground(_ notification : Notification) {
        print("applicationWillEnterForeground"  )
        SocketManager.sharedInstance.OSocketConnect()
        SocketManager.sharedInstance.socketConn(nick: self.nick)
        SocketManager.sharedInstance.joinRoom(roomname: self.roomid, nick: self.nick)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        print("applicationWillTerminate")
        SocketManager.sharedInstance.disConnect(nick: self.nick, roomname: self.roomid)
        SocketManager.sharedInstance.OSocketDisConnect()
    }
    
    func navigationTitleImage() {
        let imageView = UIImageView(frame: CGRect(x:0, y:0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        //imageView.center.x = self.view.center.x
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 0.5
        
        let data = NSData(contentsOf: remoteImage)
        var myImage: UIImage = UIImage(data: data! as Data)!
        
        myImage = myImage.resizeWithWidth(width: 40)!
        
        let compressData = UIImageJPEGRepresentation(myImage, 1)
        imageView.image = UIImage(data: compressData!)
        
        navigationItem.titleView = imageView
        navigationItem.title = self.receiver
    }
    
    func sendPushB(nick: String, message: String, roomname: String, receiver: String, time: String) {
        print("pushB")
        //self.insertMessage(nick: self.senderId, message: self.Ctext, roomid: self.roomid, receiver: self.receiver, create_at: self.Ctime)
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let time = dateFormatter.string(from: date)
        
        let sendUrl = URL(string: ohnamiUrl + "/pushB")
        var request = URLRequest(url: sendUrl!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String : Any] = ["sender" : "\(nick)", "message" : "\(message)", "receiver" : "\(receiver)", "msgKey" : "\(roomname)", "time" : "\(time)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        DispatchQueue.main.async {
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
                    print("http success")
                }
            }) .resume()
        }
    }
    
    func emptyCheck() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let time = dateFormatter.string(from: date)
        let time2 = dateFormatter.date(from: time)
        
//        if self.act == false {
//            self.inputToolbar.contentView.rightBarButtonItem.isEnabled = false
//        } else {
//            self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
//        }
        
        if messages.count == 0 {
            let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: time2, text: "입장하셨습니다")
            self.messages.append(message!)
            
            self.finishSendingMessage(animated: true)
        }
    }

    func setupBubble() {
        if defaults.bool(forKey: Setting.removeBubbleTails.rawValue) {
            // Make taillessBubbles
            incomingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
            outgoingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).outgoingMessagesBubbleImage(with: UIColor.lightGray)
        }
        else {
            // Bubbles with tails
            incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
            outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.lightGray)
        }
        
        /**
         *  Example on showing or removing Avatars based on user settings.
         */
        
        if defaults.bool(forKey: Setting.removeAvatar.rawValue) {
            collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        } else {
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        }
    }
    
    func setupBackButton() {
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func backButtonTapped() {
        SocketManager.sharedInstance.disConnect(nick: senderId, roomname: roomid)
        //SocketManager.sharedInstance.SocketDisConnected(senderId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            //SocketManager.sharedInstance.OSocketDisConnect()
        }
        //self.returnCardView()
        dismiss(animated: true, completion: nil)
        //_ = navigationController?.popToRootViewController(animated: true)
        
        //self.present((self.view.window?.rootViewController)!, animated: true, completion: nil)
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let ddate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let time = dateFormatter.string(from: ddate)
        let time2 = dateFormatter.date(from: time)
        
        let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderId, date: date, text: text)
        self.messages.append(message!)
        self.finishSendingMessage(animated: true)
        
//        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
//        self.messages.append(message!)
        
        //self.insertMessage(nick: senderId, message: text, roomid: roomid, receiver: receiver, create_at: time)
        
        //self.Cnick = senderId
//        self.Ctext = text
//        self.Ctime = time
        //self.Creceiver = receiver
        //self.Croomname = roomid
        
        SocketManager.sharedInstance.sendMessage(sender: senderId!, receiver: receiver, message: text!, roomname: roomid)
        
        
        
//        SocketManager.sharedInstance.receiveMessage { (messageInfo) -> Void in
//
//            //socket으로 sended, not_sended 를 파악해서 접속중인지 아닌지 확인하는 함수
//            let message1 = messageInfo["return"] as? String
//            
//            if message1 == "not_sended" {
//                
//                self.sendPushB(nick: self.senderId, message: text, roomname: self.roomid, receiver: self.receiver, time: time)
//
//            } else if message1 == "sended" {
//
////                let socketSender = messageInfo["sender"] as! String
////                let socketReceiver = messageInfo["receiver"] as! String
////                let socketMessage = messageInfo["message"] as! String
////                let socketRoomid = messageInfo["roomid"] as! String
////                
////                let message = JSQMessage(senderId: socketSender, senderDisplayName: socketSender, date: time2, text: socketMessage)
////                self.messages.append(message!)
////                
////                self.insertMessage(nick: socketSender, message: socketMessage, roomid: socketRoomid, receiver: socketReceiver, create_at: time)
////                self.finishSendingMessage(animated: true)
//
//            }
//        }
//        
//        self.insertMessage(nick: self.nick, message: text, roomid: self.roomid, receiver: self.receiver, create_at: time)
//        
//        let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderId, date: date, text: text)
//        self.messages.append(message!)
//        self.finishSendingMessage(animated: true)
//        //self.sendPushB(senderId: senderId!, message: text!, roomid: roomid, receiver: receiver, time: time)
//        
//        
//    }
    }
    
//    func insertMessage(nick: String, message: String, roomid: String, receiver: String, create_at: String) {
//        let contactDB = FMDatabase(path: databasePath)
//        
//        if (contactDB.open()) {
//            let insertSQL = "INSERT INTO MESSAGES (nick, message, roomid, receiver, create_at) VALUES('\(nick)', '\(message)', '\(roomid)', '\(receiver)', '\(create_at)')"
//            print(insertSQL)
//            let result = contactDB.executeUpdate(insertSQL, withArgumentsIn: [])
//            
//            if !result {
//                print("Error: \((contactDB.lastErrorMessage()))")
//            } else {
//                print("Success")
//            }
//        }
//            
//        else {
//            print("Error : \((contactDB.lastErrorMessage()))")
//        }
//    }
    
    func loadMessages() {
        print("씨발 loadMessge")
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date1 = dateFormatter.string(from: now)
        let date2 = dateFormatter.date(from: date1)
        
        let contactDB = FMDatabase(path: databasePath)
        
        if (contactDB.open()) {
            let querySQL = "SELECT * FROM MESSAGES WHERE roomid = '\(roomid)'"
            
            let results = contactDB.executeQuery(querySQL, withArgumentsIn: [])
            
            if results == nil {
                print("Error: \(contactDB.lastErrorMessage())")
            } else {
                while results?.next() == true {
                    let sender: String = (results?.string(forColumn: "nick"))!
                    let message: String = (results?.string(forColumn: "message"))!
                    let receiver: String = (results?.string(forColumn: "receiver"))!
                    let roomid: String = (results?.string(forColumn: "roomid"))!
                    let time: String = (results?.string(forColumn: "create_at"))!
                    
                    chatList.append(["\(sender)", "\(message)", "\(receiver)", "\(roomid)", "\(time)"])
                    if chatList.count > 0 {
                        for i in 0 ... chatList.count - 1 {
                            if i == chatList.count - 1 {
                                let message = JSQMessage(senderId: chatList[i][0], senderDisplayName: senderId, date: date2, text: chatList[i][1])
                                
                                self.messages.append(message!)
                                
                                self.finishSendingMessage(animated: true)
                            }
                        }
                    }
                }
            }
            
            contactDB.close()
        } else {
            print("Error: \((contactDB.lastErrorMessage()))")
        }
        
        
    }
    
    func deleteSQL() {
        let dropTable = "DROP TABLE MESSAGES"
        
        let contactDB = FMDatabase(path: databasePath)
        
        let result = contactDB.executeUpdate(dropTable, withArgumentsIn: [])
        
        if !result {
            print("Error: \(contactDB.lastErrorMessage())")
        }

    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        
        let sheet = UIAlertController(title: "Media messages", message: nil, preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "Send photo", style: .default) { (action) in
            
            self.addPhoto()
        }
        
        let cameraACtion = UIAlertAction(title: "카메라", style: .default, handler: { ( action) in
            self.takePhoto()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        sheet.addAction(photoAction)
        sheet.addAction(cameraACtion)
        sheet.addAction(cancelAction)
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    func takePhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        self.show(picker, sender: nil)
    }
    
    func addPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.show(picker, sender: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let photoItem = JSQPhotoMediaItem(image: selectedImage)
        self.addMedia(photoItem!)
    }
    
    func addMedia(_ media:JSQMediaItem) {
        let message = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: media)
        self.messages.append(message!)
        
        //Optional: play sent sound
        
        self.finishSendingMessage(animated: true)
    }
    
    func configureNick() {
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(request)
            if objects.count > 0 {
                let match = objects[0] as! Profile
                
                self.nick = match.value(forKey: "nick") as! String
                self.localImage = match.value(forKey: "imageId") as! String
            } else {
                print("Nothing Founded")
            }
        } catch {
            print("error")
        }
        
        self.senderId = self.nick
        self.senderDisplayName = self.nick
    }
    
    func getAvatar(_ id: String) -> JSQMessagesAvatarImage {
        let imageName: String = ""
        
        let imageUrl = URL(string: ohnamiUrl + "/download/\(imageName)")
        
        let data = NSData(contentsOf: imageUrl!)
        let talkImage = UIImage(data: data! as Data)
        
        let returnImage = JSQMessagesAvatarImageFactory.avatarImage(with: talkImage, diameter: 1)
        
        return returnImage!
    }
    
    func getLocalImage() -> JSQMessagesAvatarImage {
        
        let imageUrl = URL(string: ohnamiUrl + "/download/\(localImage)")
        
        let data = NSData(contentsOf: imageUrl!)
        let myImage = UIImage(data: data! as Data)
        
        let returnImage = JSQMessagesAvatarImageFactory.avatarImage(with: myImage, diameter: 100)
        
        return returnImage!
    }
    
    func getRemoteImage() -> JSQMessagesAvatarImage {
        
        let data = NSData(contentsOf: remoteImage)
        var myImage: UIImage = UIImage(data: data! as Data)!
        
        let returnImage = JSQMessagesAvatarImageFactory.avatarImage(with: myImage, diameter: 100)
        
        return returnImage!
        
//        myImage = myImage.resizeWithWidth(width: 40)!
//        let compressData = UIImageJPEGRepresentation(myImage, 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    //메시지가 보내는건지 받은건지 확인
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return messages[indexPath.item].senderId == self.senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if (indexPath.item % 3 == 0) {
            let message = self.messages[indexPath.item]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    //메시지 이미지
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        if messages[indexPath.item].senderId == self.senderId {
            return getLocalImage()
        } else {
            return getRemoteImage()
        }
        
        let message = messages[indexPath.item]
        //return getAvatar(message.senderId)
        
        //JSQMessagesAvatarImageFactory.avatarImage(with: UIImage!, diameter: UInt)
        
        //return nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
        //NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
    }

}
