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
        
        if UserDefaults.standard.bool(forKey: "userHasOnboarded") {
            self.setupNormalRootViewController()
        } else {
            UserDefaults.standard.set(25, forKey: "numberOfMovies")
            self.window?.rootViewController = generateStandardOnboardingVC()
        }
        
        //Set the tint color of the entire app
        window?.tintColor = UIColor.purple
    
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}

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
    
    func handleOnboardingCompletion() {
        self.setupNormalRootViewController()
    }
    
    func setupNormalRootViewController() {
        let navigationController = UINavigationController(rootViewController: MainTableViewController())
        navigationController.navigationBar.barTintColor = UIColor(red: 101/255, green: 153/255, blue: 185/255, alpha: 1.0)
        navigationController.navigationBar.tintColor = .white
        if #available(iOS 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        UserDefaults.standard.set(true, forKey: "userHasOnboarded")
        
    }
    
    func skip() {
        self.setupNormalRootViewController()
    }

}

