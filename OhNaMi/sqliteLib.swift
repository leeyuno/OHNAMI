//
//  sqliteLib.swift
//  OhNaMi
//
//  Created by leeyuno on 2017. 6. 24..
//  Copyright © 2017년 Froglab. All rights reserved.
//

import Foundation
import FMDB

class sqliteLib: NSObject {

    var databasePath: String = ""
    
    let fileManager = FileManager.default
    
//    let dirPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//    databasePath = dirPaths[0].appendingPathComponent("message.db").path
//    
//    let contactDB = FMDatabase(path: databasePath)
    
    func createDB() {
        
    }
    
    func selectDB() {
        
    }
    
    func insertDB() {
        
    }
    
    func deleteDB() {
        
    }
    
}
