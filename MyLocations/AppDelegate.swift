//
//  AppDelegate.swift
//  MyLocations
//
//  Created by nag on 14.06.16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

import CoreData


// ** NOTIFICATION WHEN COREDATA FAIL

let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"

func fatalCoreDataError(error: ErrorType) {
    
    print("*** Fatal error: \(error)")
    NSNotificationCenter.defaultCenter().postNotificationName(MyManagedObjectContextSaveDidFailNotification, object: nil)
    
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    // MARK: - didFinishLaunchingWithOptions

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let tabBarController = window!.rootViewController as! UITabBarController
        
        if let tabBarViewControllers = tabBarController.viewControllers {
            
            let currentLocationViewController = tabBarViewControllers[0] as! CurrentLocationViewController
            
            currentLocationViewController.managedObjectContext = managedObjectContext
            
        }
        
        listenForFatalCoreDataNotifications()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    
    // MARK: - NOTIFICATION HANDLERS
    
    func listenForFatalCoreDataNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserverForName( MyManagedObjectContextSaveDidFailNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in
            
            let alert = UIAlertController(title: "Internal Error", message: "There was a fatal error in the app and it cannot continue.\n\n" + "Press OK to terminate the app. Sorry for the inconvenience.", preferredStyle: .Alert)
            
            let action = UIAlertAction(title: "OK", style: .Default) { _ in
                
                let exception = NSException(
                name: NSInternalInconsistencyException,
                reason: "Fatal Core Data error", userInfo: nil)
                
                exception.raise()
            }
            
            alert.addAction(action)
            
            self.viewControllerForShowingAlert().presentViewController(alert, animated: true, completion: nil)
            
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
        
        guard let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") else { fatalError("Could not find data model in app bundle") }
        
        print("modelURL = \(modelURL)")
        
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else { fatalError("Error initializing model from: \(modelURL)") }
        
        let urls = NSFileManager.defaultManager().URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask)
        
        let documentsDirectory = urls[0]
        
        let storeURL = documentsDirectory.URLByAppendingPathComponent("DataStore.sqlite")
        
        print("storeURL = \(storeURL)")
        
        do {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            
            let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            
            context.persistentStoreCoordinator = coordinator
            
            return context
        
        } catch {
            fatalError("Error adding persistent store at \(storeURL): \(error)")
        
        }
    }()


}

