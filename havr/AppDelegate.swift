//
//  AppDelegate.swift
//  havr
//
//  Created by Arben Pnishi on 4/19/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FacebookCore
import TwitterCore
import TwitterKit
import AWSCore
import AWSS3
import KanvasCameraSDK
import Firebase
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var state: ApplicationPlace?
    var window: UIWindow?
    var requestedOrientation: InterfaceOrientation = .portraitOnly
    fileprivate var googleAPIKey = "AIzaSyBKeCqzLTOr3ihxlK_MOZ6OKHDLug9ZVhk"
    fileprivate let apiKey = "58f60e3a1e329e0d7a7b2b23"
    fileprivate let sdkKey = "MEQCIB7KDOd5Dw/6q3hU+90EvwaaUdswKRyqo01X1HXjwFkOAiA4C95gtEVIWIIAm+XEp7NittJ5UbO+gKnmuakjPTcT2Q=="
    fileprivate let twitterApiKey = "msTkAlBVmmbJKhgBcQEnRtFWS"
    fileprivate let twitterSecretKey = "I3pCP0dQID7SBzgvrzvs4tHAFl2kYrKryNBmyz0sFi9aBIfjnE"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        AccountManager.start()
        NetworkManager.start()
        
        window?.makeKeyAndVisible()
        checkForFirstRun()
        Apperance.setup()
        Twitter.sharedInstance().start(withConsumerKey: twitterApiKey, consumerSecret: twitterSecretKey)
        FirebaseApp.configure()
        
        UIApplication.shared.isStatusBarHidden = false

        GMSServices.provideAPIKey(googleAPIKey)
        GMSPlacesClient.provideAPIKey(googleAPIKey)
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        let loggedIn = AccountManager.isLogged
        switchWindowRoot(to: loggedIn ? .slide : .login)
        Fabric.with([Crashlytics.self])
        
        if AccountManager.isLogged {
            ChatManager.shared.start()
        }
        
        print("---------------------------------------------")
        for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
        print("---------------------------------------------")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        SocketManager.shared.disconnect()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        NetworkManager.stop()
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        NetworkManager.start()
        SocketManager.shared.reconnect()
        
        ChatManager.shared.appEnterForeground()
        NotificationCenter.default.post(name: Constants.AppEnterForegroundNotification, object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        PushNotificationManager.didRegister(with: deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let state = UIApplication.shared.applicationState
        
        if state == .inactive {
            Timer.after(1.5) {
                PushNotificationManager.handleNotification(userInfo: userInfo, for: state)
            }
        } else {
            PushNotificationManager.handleNotification(userInfo: userInfo, for: state)
        }
        
        completionHandler(.noData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushNotificationManager.didFailToRegister(with: error)
    }
    
    
    open func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "twitterkit-msTkAlBVmmbJKhgBcQEnRtFWS" {
            return Twitter.sharedInstance().application(app, open: url, options: options)
        }
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    func switchWindowRoot(to place: ApplicationPlace){
        if place == state {
            return
        }
        switch place {
        case .login:
            let controller = UIStoryboard.introduction.instantiateInitialViewController()!
            self.window?.set(root: controller)
            self.state = place
            break
            
        case .slide:
            let controller = UIStoryboard.slide.instantiateInitialViewController()!
            self.window?.set(root: controller)
            self.state = place
            break
        }
    }
    
    fileprivate func checkForFirstRun(){
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "hasRunBefore") == false {
            // Remove Keychain items here
            AccountManager.delete()
            // Update the flag indicator
            userDefaults.set(true, forKey: "hasRunBefore")
            userDefaults.synchronize() // Forces the app to update UserDefaults
        }
    }
    
    //MARK: Rotation Screen Method.
    //shouldRotate => Is accessable by View Controllers which we ant to allow UpSideDown or Portrait
    //var shouldRotate = false
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        switch requestedOrientation {
        case .portraitOnly:
            return .portrait
        case .landscapeOnly:
            return .landscape
        case .all:
            return .allButUpsideDown
        }
    }
    
    //MARK: Screen Rotation Functions
    static func disableScreenOrientation(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.requestedOrientation = .portraitOnly
        delay(delay: 0) {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
    
    static func enableScreenOrientation(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.requestedOrientation = .all
    }
    
    static func enableScreenOrientationOnlyForLandscape(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.requestedOrientation = .landscapeOnly
        delay(delay: 0) {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
        }
    }
}

enum ApplicationPlace {
    case login
    case slide
}

enum InterfaceOrientation{
    case all
    case portraitOnly
    case landscapeOnly
}
