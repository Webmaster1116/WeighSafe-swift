//
//  AppDelegate.swift
//  WeighSafe
//
//  Created by Brian Barton on 4/30/18.
//  Copyright © 2018 Lemonadestand Inc. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let validQueryKeys = ["tongueWeight","towBallToEndOfSpringBars","towBallToTrailerAxle","rearAxleToEndOfReceiver","holesVisible","drawbarPosition"]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        PersistenceManager.shared.deleteAll(entity: "Configuration")
//        PersistenceManager.shared.deleteAll(entity: "Vehicle")
//        PersistenceManager.shared.deleteAll(entity: "Hitch")
//        PersistenceManager.shared.deleteAll(entity: "Trailer")
//        PersistenceManager.shared.deleteAll(entity: "Cargo")
//        let domain = Bundle.main.bundleIdentifier!
//        UserDefaults.standard.removePersistentDomain(forName: domain)
//        UserDefaults.standard.synchronize()
        
//        UserDefaults.standard.set(0, forKey: "currentConfigIndex")
//        UserDefaults.standard.set(0, forKey: "currentVehicleIndex")
//        UserDefaults.standard.set(0, forKey: "currentHitchIndex")
//        UserDefaults.standard.set(0, forKey: "currentTrailerIndex")
//        UserDefaults.standard.set([], forKey: "currentCargoIndexes")
        
        if UserDefaults.standard.object(forKey: "shownDisclaimer") == nil {
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "disclaimerPageViewController")
    
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
            
            UserDefaults.standard.set(true, forKey: "shownDisclaimer")
            
        }
        
        UINavigationBar.appearance().tintColor = UIColor.white
        
        if #available(iOS 13.0, *) {
            window!.overrideUserInterfaceStyle = .light
        }
        
        UITabBar.appearance().clipsToBounds = false
        UITabBar.appearance().layer.borderColor = UIColor.clear.cgColor
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        UserDefaults.standard.set(true, forKey: "shownDisclaimer")
        UserDefaults.standard.set(false, forKey: "wizardOn")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UserDefaults.standard.removeObject(forKey: "shownDisclaimer")
        PersistenceManager.shared.save()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard
            let query = url.query,
            let queryItems = URLComponents(string: "?\(query)")?.queryItems else { return false }
        for item in queryItems {
            if validQueryKeys.firstIndex(of: item.name) != nil {
                UserDefaults.standard.set(item.value, forKey: item.name)
            }
        }
            
        // weighsafe://?tongueWeight=850&rearAxleToEndOfReceiver=69&towBallToEndOfSpringBars=31&towBallToTrailerAxle=172
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems else { return false }
        for item in queryItems {
            if validQueryKeys.firstIndex(of: item.name) != nil {
                UserDefaults.standard.set(item.value, forKey: item.name)
            }
        }
        
        return true
    }

}

