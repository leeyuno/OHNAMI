//
//  Copyright (c) 2016 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import UserNotifications
import CoreData

import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var nick: String = ""
    
    func loadCoreData() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        
        request.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(request)
            
            if objects.count > 0 {
                print("coredata")
                let match = objects[0] as! Profile
                nick = match.value(forKey: "nick") as! String
            } else {
                print("nothing founded")
            }
        } catch {
            print("Error")
        }
    }
    
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        print("didEnterBackground")
//        
//        self.loadCoreData()
//        
//        //SocketManager.sharedInstance.SocketDisConnected(self.nick)
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            SocketManager.sharedInstance.OSocketDisConnect()
//        }
//        
//    }
//    
    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
//        self.loadCoreData()
//
//        //SocketManager.sharedInstance.SocketDisConnected(self.nick)
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            SocketManager.sharedInstance.OSocketDisConnect()
//        }
        
        SocketManager.sharedInstance.OSocketDisConnect()
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        print("IOS application - start")
//        SocketManager.sharedInstance.OSocketConnect()
        FirebaseApp.configure()
        
        // [START set_messaging_delegate]
        
        Messaging.messaging().delegate = self
    
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        if launchOptions != nil {
            var userInfo: [AnyHashable: Any] = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as! [AnyHashable : Any]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "backgroundNoti"), object: self, userInfo: userInfo)
        }
        // [END register_for_notifications]
        return true
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        print("didReceiveRemoteNoti")
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
        
        let state: UIApplicationState = UIApplication.shared.applicationState
        
        if state == .inactive {
            print("inative1")
        } else if state == .background {
            print("background1")
        } else {
            print("inactive1")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "backgroundNoti"), object: self, userInfo: userInfo)
        }
        
        // Print full message.
        print(userInfo)
    }
    
    //백그라운드상태에서 메시지 받는함수 (apns payload에 content_available : true 값 추가해줘야함)
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        let state: UIApplicationState = UIApplication.shared.applicationState
        
        if state == .active {
            print("active2")
        } else if state == .background {
            print("background2")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "backgroundNoti"), object: self, userInfo: userInfo)
        } else {
            print("inactive2")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "backgroundNoti"), object: self, userInfo: userInfo)
        }
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
    }
    // [END disconnect_from_fcm]
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Profile")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // [END disconnect_from_fcm]
}


// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    //포그라운드 데이터 수신
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            //print("Message ID: \(messageID)")
        }
        
//        let state: UIApplicationState = UIApplication.shared.applicationState
//        
//        if state == .background {
//            print("background Print : \(userInfo)")
//            print("background")
//        } else if state == .active {
//            print("foreground")
//        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pushNoti"), object: self, userInfo: userInfo)
        
        // Print full message.
        //print("Print full message \(userInfo)")
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    //백그라운드 데이터 수신 (작업표시줄에 떳을때 누른 데이터만 받아옴)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
    
        let state: UIApplicationState = UIApplication.shared.applicationState
        
        if state == .active {
            print("inative")
        } else if state == .background {
            print("background 3")
        } else if state == .inactive {
            print("inactive 3")
            print(userInfo)
        }
        
        // Print full message.
        //print(userInfo)
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("123")
        print("Firebase registration token: \(fcmToken)")
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("12344")
        print("Received data message: \(remoteMessage.appData)")
        
    }
    // [END ios_10_data_message]
}

