//
//  AppDelegate.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 3/20/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import UIKit
import CoreData
import Onboard
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let notificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(notificationSettings)
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        let defaults = UserDefaults.standard
        let userHasOnboarded =  defaults.bool(forKey: "userHasOnboarded")
        if userHasOnboarded {
            self.setupNormalRootViewController()
        } else {
            UserDefaults.standard.set(true, forKey: "isSeeingRentalPrice")
            UserDefaults.standard.set(25, forKey: "numberOfMovies")
            self.window?.rootViewController = self.generateStandardOnboardingVC()
        }
        
        //Set the tint color of the entire app
        window?.tintColor = UIColor(red: 101/255, green: 153/255, blue: 185/255, alpha: 1.0)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    //MARK: Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "iTunesCodingChallenge")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.x
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("MessageID: \(userInfo["gcm_message_id"]!)")
        print(userInfo)
    }

    //MARK: Core Data Saving support

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
    
    //MARK: Onboarding Functions
    
    func generateStandardOnboardingVC () -> OnboardingViewController {
        
        // Initialize onboarding view controller
        var onboardingVC = OnboardingViewController()
        
        // Create slides
        let firstPage = OnboardingContentViewController.content(withTitle: "Welcome To The Top 25 Movies!", body: "Your one-stop-shop for iTune's top rated movies right now.", image: nil, buttonText: nil, action: nil)
        let secondPage = OnboardingContentViewController.content(withTitle: "Tap", body: "Select any movie you wish to see more info about it.", image: nil, buttonText: nil, action: nil)
        let thirdPage = OnboardingContentViewController.content(withTitle: "Swipe", body: "Swipe left on a movie to add it to your list of favorites.", image: nil, buttonText: "Get started 👍", action: self.handleOnboardingCompletion)
        
        // Define onboarding view controller properties
        onboardingVC = OnboardingViewController.onboard(withBackgroundImage: #imageLiteral(resourceName: "Clouds"), contents: [firstPage, secondPage, thirdPage])
        onboardingVC.shouldFadeTransitions = true
        onboardingVC.shouldMaskBackground = false
        onboardingVC.shouldBlurBackground = true
        onboardingVC.fadePageControlOnLastPage = true
        onboardingVC.pageControl.pageIndicatorTintColor = UIColor.white
        onboardingVC.pageControl.currentPageIndicatorTintColor = UIColor.white
        onboardingVC.skipButton.setTitleColor(UIColor.white, for: .normal)
        onboardingVC.allowSkipping = true
        onboardingVC.fadeSkipButtonOnLastPage = true
        
        onboardingVC.skipHandler = {
            self.skip()
        }
        
        return onboardingVC
        
    }
    
    func handleOnboardingCompletion (){
        self.setupNormalRootViewController()
    }
    
    func setupNormalRootViewController (){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "NavigationController") as! UIViewController
        UIApplication.shared.keyWindow?.rootViewController = viewController
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "userHasOnboarded")
        
    }
    
    func skip (){
        self.setupNormalRootViewController()
    }

}

