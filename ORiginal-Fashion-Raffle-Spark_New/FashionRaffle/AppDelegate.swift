//
//  AppDelegate.swift
//  FashionRaffle
//
//  Created by Mac on 2016/10/28.
//  Copyright © 2016年 Mac. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import EventKit
import Cache


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var eventStore: EKEventStore?

    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        SVProgressHUD.setDefaultStyle(.dark)
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = false
        rootToLogIn()


        // Override point for customization after application launch.
        if FIRAuth.auth()?.currentUser != nil {
            let userID = FIRAuth.auth()?.currentUser?.uid
            
            let userCache = HybridCache(name: "UserCache")
            let syncUserCache = SyncHybridCache(userCache)
            print("=========")
            if let json:JSON = syncUserCache.object("UserProfile") {
                let datadic = json.object as? [String:[String:Any]]
                print("Has Cache Value!")
                for data in datadic! {
                    let cacheID = data.key
                    let dict = data.value
                    
                    // Need to check if the current user is actually the user logged in last time.
                    if cacheID == userID {
                        let userProfile = Profile.initWithUserID(userID: userID!, profileDict: dict)
                        Profile.currentUser = userProfile!
                        if userProfile?.lastCheckDate != Date.nowDate() {
                            userProfile?.lastCheckDate = Date.nowDate()
                            let count = userProfile?.checkInCount
                            userProfile?.checkInCount = count! + 1
                            Profile.currentUser = userProfile!
                            Profile.currentUser?.sync(onSuccess: {}, onError: {
                                error in
                                print(error.localizedDescription)
                            })
                        }
                        
                        print("CurrentUser data inputs successfully.")
                        self.rootToMainTab()
                    }
                    else {
                        print("The user now is not who get cached before.")
                        print("Will log out")
                        try! FIRAuth.auth()?.signOut()
                        if FBSDKAccessToken.current() != nil{
                            FBSDKLoginManager().logOut()
                        }
                    }
                }
            }
            else {
                // This part can later be used as an option that the user doesn't want to cache the user data
                print("No cache data, will log out")
                try! FIRAuth.auth()?.signOut()
                if FBSDKAccessToken.current() != nil {
                    FBSDKLoginManager().logOut()
                }
            }

            print("=========")
        }
        else {
            print("=----------=")
            print("No User Signed in")
        }
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        let defaults = UserDefaults.standard
        let defaultValue = ["AlarmTime": 0]
        defaults.register(defaults: defaultValue)
        
        
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)

        //return AWSMobileClient.sharedInstance.withApplication(application: application, withURL: url as NSURL, withSourceApplication: sourceApplication, withAnnotation: annotation)
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
        //Cache the profile Info so don't need to retrieve again from DB
        //It will reserve for 7 days and then cleaned automatically
        let cache = HybridCache(name: "UserCache")
        let syncCache = SyncHybridCache(cache)
        if let currentUser = Profile.currentUser {
            let currentUserProfile = currentUser.dictValue()
            let currentUserID = currentUser.userID
            let cacheDict : [String:Any] = [currentUserID:currentUserProfile]
            let jsonDic = JSON.dictionary(cacheDict)
            syncCache.add("UserProfile", object: jsonDic, expiry: Expiry.seconds(604800))
            print("User Profile Caches Successfully")
        }
        else {
            print("No need to cache now")
        }
        
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

        

    }
    private func rootToLogIn() {
    
        let storyboard = UIStoryboard(name:"Start", bundle:nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! LoginViewController
        self.window?.rootViewController = loginVC
    }
    
    private func rootToMainTab() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        self.window?.rootViewController = viewController
    }


}

