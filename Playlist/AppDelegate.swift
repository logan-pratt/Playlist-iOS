//
//  AppDelegate.swift
//  Playlist
//
//  Created by Logan Pratt on 7/13/15.
//  Copyright (c) 2015 Logan Pratt. All rights reserved.
//

import UIKit
//import Parse
//import Bolts
import AVFoundation
import Fabric
import Crashlytics
import MediaPlayer
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
//    let playback = PlaybackViewController.sharedInstance
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Parse.setApplicationId("ZFcq1SiHvUzDSqgPlhHG7lO5pxe9YWJDLcNZYsdn", clientKey: "7xgtE3mz33ABlEtuCwJLvMt3wdExoG9QHMnDvEYp")
        FIRApp.configure()
        Fabric.with([Crashlytics()])
        
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()

        var error: NSError?
        var success: Bool
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            success = true
        } catch let error1 as NSError {
            error = error1
            success = false
        }
        if success {
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch _ {
            }
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } else {
            NSLog("Failed to set audio session category.  Error: \(error)")
        }
        
//        let rcc = MPRemoteCommandCenter.sharedCommandCenter()
//        
//        rcc.nextTrackCommand.addTargetWithHandler { (event: MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
//            return MPRemoteCommandHandlerStatus.Success
//        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return application(app, open: url, sourceApplication: nil, annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let dynamicLink = FIRDynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url)
        if let dynamicLink = dynamicLink {
            print("LINK: \(dynamicLink.url?.absoluteString)")
            return true
        }
        
        return false
    }
    
    @available(iOS 8.0, *)
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard let dynamicLinks = FIRDynamicLinks.dynamicLinks() else {
            return false
        }
        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            // ...
            print("ACTIVITY: \(userActivity.activityType)")
        }
        
        return handled
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
        
    }
    
}

extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
    }
}