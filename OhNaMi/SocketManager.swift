//
//  SocketManager.swift
//  OhNaMi
//
//  Created by leeyuno on 2017. 6. 3..
//  Copyright © 2017년 Froglab. All rights reserved.
//

import UIKit
import SocketIO
import FMDB

class SocketManager: NSObject {
    
    static let sharedInstance = SocketManager()
    
    var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: socketUrl)!)
    
    override init() {
        super.init()
    }
    
    func OSocketConnect() {
        print("socket connect")
        socket.connect()
    }
    
    func OSocketDisConnect() {
        print("socket disconnect")
        socket.disconnect()
    }
    
    func SocketDisConnected(_ nick: String) {
        print("socket disconnected2")
        let json: [String: Any] = ["nick" : "\(nick)"]
        socket.emit("disconnected", json)
    }
    
    //conn
    func socketConn(nick: String) {
        print("socketConn")
        let json: [String: Any] = ["nick" : "\(nick)"]
        self.socket.emit("conn", json)
    }
    
    //채팅방 디스커넥트 함수
    func disConnect(nick : String, roomname: String) {
        print("join disconnected")
        let json: [String: Any] = ["nick" : "\(nick)", "roomname" : "\(roomname)"]
        self.socket.emit("dc", json)
    }
    
    //채팅방에 들어가는 함수
    func joinRoom(roomname: String, nick: String) {
        print("join room")
        let json: [String: Any] = ["roomname" : "\(roomname)", "nick" : "\(nick)"]
        socket.emit("join", json)
        
    }
    
    //메시지를 보내는 함수
    func sendMessage(sender: String, receiver: String, message: String, roomname: String) {
        print("socket send message")
        let json: [String: Any] = ["nick" : "\(sender)", "msg" : "\(message)", "roomname" : "\(roomname)", "receiver" : "\(receiver)"]
        print(json)
        socket.emit("send", json)
        
    }
    
    //메시지를 받는함수 sended: 상호 접호중일경유 not_sended : receiver가 접속중이지 않을경우
//    func receiveMessage() {
//        print("receiveMessage")
//        
//        var messageDictionary = [String: Any]()
//        
//        socket.on("sended") {data, ack in
//            print(data)
//            messageDictionary["return"] = "sended"
//            completionHandler(messageDictionary)
//        }
//        
//        socket.on("not_sended") { data, ack in
//            print("not_sended")
//            print(data)
//            messageDictionary["return"] = "not_sended"
//            completionHandler(messageDictionary)
//        }
//    }
    
    func receiveMessage() {
        print("receiveMessage")
        
        var messageDictionary = [String: Any]()
        
        socket.on("sended") { data, act in
            print("sended")
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let time = dateFormatter.string(from: date)
            
            self.insertSQL(nick: data[0] as! String, message: data[3] as! String, roomname: data[2] as! String, receiver: data[1] as! String, time: time)
        }
        
        socket.on("not_sended") { data, act in
            //nick, receiver, roomid, message
            print("not_sended")
            self.sendPushB(nick: data[0] as! String, message: data[3] as! String, roomname: data[2] as! String, receiver: data[1] as! String)
        }
    }
    
    func sendPushB(nick: String, message: String, roomname: String, receiver: String){
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let time = dateFormatter.string(from: date)
        
        let sendUrl = URL(string: ohnamiUrl + "/pushB")
        var request = URLRequest(url: sendUrl!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String : Any] = ["sender" : "\(nick)", "message" : "\(message)", "receiver" : "\(receiver)", "msgKey" : "\(roomname)", "time" : "\(time)"]
        print(json)
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        DispatchQueue.main.async {
            URLSession.shared.dataTask(with: request, completionHandler: {( data: Data?, response: URLResponse?, error: Error?) -> Void in
                
                if error != nil {
                    if (error?.localizedDescription)! == "The request timed out." {
                        
                    }
                } else {
                    self.insertSQL(nick: nick, message: message, roomname: roomname, receiver: receiver, time: time)
                }
                
            }) .resume()
        }

    }
    
    func insertSQL(nick: String, message: String, roomname: String, receiver: String, time: String) {
        let contactDB = FMDatabase(path: databasePath)
        
        if (contactDB.open()) {
            let insertSQL = "INSERT INTO MESSAGES (nick, message, roomid, receiver, create_at) VALUES('\(nick)', '\(message)', '\(roomname)', '\(receiver)', '\(time)')"
            print(insertSQL)
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
