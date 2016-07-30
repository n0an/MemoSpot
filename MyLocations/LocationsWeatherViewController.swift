//
//  LocationsWeatherViewController.swift
//  MyLocations
//
//  Created by Anton Novoselov on 30/07/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData

class LocationsWeatherViewController: UITableViewController {
    
    // MARK: - PROPERTIES
    
    var locations: [Location]!
    
    var managedObjectContext: NSManagedObjectContext!
    
    var userTemperatureCelsius : Bool!

    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTemperatureCelsius = true
        
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White

        
        let fetchRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let foundObjects = try managedObjectContext.executeFetchRequest(fetchRequest)
            
            locations = foundObjects as! [Location]
            
        } catch {
            fatalCoreDataError(error)
        }
        
    }

    
    
    // MARK: - WEATHER METHODS
    
    func getCurrentWeatherDataForLocation(location: Location, andSetCell cell: LocationCell) {
        
        let userLatitude = location.coordinate.latitude
        let userLongitude = location.coordinate.longitude
        
        let userLocation = "\(userLatitude),\(userLongitude)"
        
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = NSURL(string: "\(userLocation)", relativeToURL:baseURL)
        
        
        let sharedSession = NSURLSession.sharedSession()
        
        
        
        let dataTask = sharedSession.dataTaskWithURL(forecastURL!) { (data, response, error) in
            
            if (error == nil) {
                
                let dataObject = data
                
                let weatherDictionary: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(dataObject!, options: [])) as! NSDictionary
                
                let currentWeather = CurrentWeather(weatherDictionary: weatherDictionary)
                
                
                dispatch_async(dispatch_get_main_queue(), {

                    var addingText: String
                    
                    if self.userTemperatureCelsius == true {
                        addingText = "\(Fahrenheit2Celsius(currentWeather.temperature))"
                        
                    } else {
                        addingText = "\(currentWeather.temperature)"
                    }
                    
                    if currentWeather.temperature > 0 {
                        cell.addressLabel.text = "Temperature: +" + addingText

                    } else {
                        cell.addressLabel.text = "Temperature: -" + addingText

                    }
                    
                    
                    
                    cell.weatherImageView.image = currentWeather.altIcon
                    
                    
                    
                })
                
                
            } else {
                
                
            }
            
            
        }
        
        dataTask.resume()
        
        
        
        
        
        
    }
    
    
    
    // MARK: - ACTIONS

    @IBAction func actionMenuPressed(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowWeather" {
            
            
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                
                let location = locations[indexPath.row]
                
                let controller = segue.destinationViewController as! WeatherViewController
                
                controller.locationToEdit = location
            }
            
        }
        
    }

    
    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return locations.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! LocationCell
        
        let location = locations[indexPath.row]
        
        cell.configureForLocation(location)
        
        getCurrentWeatherDataForLocation(location, andSetCell: cell)
        
        return cell
        
    }
    
    
    // MARK: - UITableViewDelegate
    
    
    
}






