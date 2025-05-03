//
//  AppDelegate.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-04-12.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        notificationCenter.requestAuthorization(options: [.alert,.sound,.badge]) { granded, error in
            guard granded else {return}
            self.notificationCenter.getNotificationSettings { settings in
                print(settings)
                guard settings.authorizationStatus == .authorized else {return}
                
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(sendEnterNotification), name:  NSNotification.Name("locationEnter"), object: nil)
        notificationCenter.delegate = self
        
        return true
    }
 
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}

extension AppDelegate:UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner,.sound])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationCenter.default.post(name: NSNotification.Name("clickedOnTheNotification"), object: nil)
    }
}

extension AppDelegate{
    @objc
    func sendEnterNotification(){
        let content = UNMutableNotificationContent()
        content.title = "Geo Alarm"
        content.body = "you are inside the zone"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("ALARM!!!.wav"))
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "zone", content: content, trigger: trigger)
        notificationCenter.add(request){ error in
            print("error notificationCenter request:  \(String(describing: error?.localizedDescription)) ")
        }
    }
}
