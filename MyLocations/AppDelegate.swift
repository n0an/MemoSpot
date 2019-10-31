//
//  AppDelegate.swift
//  MyLocations
//
//  Created by nag on 14.06.16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

import CoreData



let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"

func fatalCoreDataError(_ error: Error) {
    
    print("*** Fatal error: \(error)")
    NotificationCenter.default.post(name: Notification.Name(rawValue: MyManagedObjectContextSaveDidFailNotification), object: nil)
    
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    // MARK: - didFinishLaunchingWithOptions

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        // GOOGLE ANALYTICS
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true

        
        // FABRIC AND CRASHLYTICS
        Fabric.with([Crashlytics.self])
        
        
        
        customizeAppearance()
      
        
        let tabBarController = window!.rootViewController as! UITabBarController
        
        if let tabBarViewControllers = tabBarController.viewControllers {
            
            let navigationController = tabBarViewControllers[1] as! UINavigationController
            let locationsViewController = navigationController.viewControllers[0] as! LocationsViewController
            
            locationsViewController.managedObjectContext = managedObjectContext
            
            
            let _ = locationsViewController.view
            
            
            let currentLocationViewController = tabBarViewControllers[0] as! CurrentLocationViewController
            
            currentLocationViewController.managedObjectContext = managedObjectContext
            
            
            let mapViewController = tabBarViewControllers[2] as! MapViewController
            mapViewController.managedObjectContext = managedObjectContext
            
        }
        
        listenForFatalCoreDataNotifications()
        
        return true
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
    
    
    // MARK: - HELPER METHODS
   
    func customizeAppearance() {
        UINavigationBar.appearance().barTintColor = UIColor.black
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        UITabBar.appearance().barTintColor = UIColor.black
        
        let tintColor = UIColor(red: 255/255.0, green: 238/255.0, blue: 136/255.0, alpha: 1.0)
        
        UITabBar.appearance().tintColor = tintColor
        
    }
    
    
    // MARK: - NOTIFICATION HANDLERS | UIALERT FOR COREDATA ERRORS
    
    func listenForFatalCoreDataNotifications() {
        
        NotificationCenter.default.addObserver( forName: NSNotification.Name(rawValue: MyManagedObjectContextSaveDidFailNotification), object: nil, queue: OperationQueue.main, using: { notification in
            
            let alert = UIAlertController(title: "Internal Error", message: "There was a fatal error in the app and it cannot continue.\n\n" + "Press OK to terminate the app. Sorry for the inconvenience.", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                
                let exception = NSException(
                name: NSExceptionName.internalInconsistencyException,
                reason: "Fatal Core Data error", userInfo: nil)
                
                exception.raise()
            }
            
            alert.addAction(action)
            
            self.viewControllerForShowingAlert().present(alert, animated: true, completion: nil)
            
        })
    }
    
    // ** Getting current Top ViewController
    func viewControllerForShowingAlert() -> UIViewController {
        
        let rootViewController = self.window!.rootViewController!
        
        if let presentedViewController = rootViewController.presentedViewController {
            
            return presentedViewController
            
        } else {
            
            return rootViewController
        }
        
    }
    
                
    
    // MARK: - CORE DATA STACK
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        guard let modelURL = Bundle.main.url(forResource: "DataModel", withExtension: "momd") else { fatalError("Could not find data model in app bundle") }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else { fatalError("Error initializing model from: \(modelURL)") }
        
        let urls = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask)
        
        let documentsDirectory = urls[0]
        
        let storeURL = documentsDirectory.appendingPathComponent("DataStore.sqlite")
        
        
        do {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            
            context.persistentStoreCoordinator = coordinator
            
            return context
        
        } catch {
            fatalError("Error adding persistent store at \(storeURL): \(error)")
        
        }
    }()


}

