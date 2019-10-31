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
        
        tableView.backgroundColor = UIColor.black
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .white

        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: managedObjectContext)
        
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let foundObjects = try managedObjectContext.fetch(fetchRequest)
            
            locations = foundObjects as! [Location]
            
        } catch {
            fatalCoreDataError(error)
        }
        
    }

    
    
    // MARK: - WEATHER METHODS
    
    func getCurrentWeatherDataForLocation(_ location: Location, andSetCell cell: LocationCell) {
        
        let userLatitude = location.coordinate.latitude
        let userLongitude = location.coordinate.longitude
        
        let userLocation = "\(userLatitude),\(userLongitude)"
        
        let baseURL = URL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = URL(string: "\(userLocation)", relativeTo:baseURL)
        
        
        let sharedSession = URLSession.shared
        
        
        
        let dataTask = sharedSession.dataTask(with: forecastURL!, completionHandler: { (data, response, error) in
            
            if (error == nil) {
                
                let dataObject = data
                
                let weatherDictionary: NSDictionary = (try! JSONSerialization.jsonObject(with: dataObject!, options: [])) as! NSDictionary
                
                let currentWeather = CurrentWeather(weatherDictionary: weatherDictionary)
                
                
                DispatchQueue.main.async(execute: {

                    var addingText: String
                    
                    if self.userTemperatureCelsius == true {
                        addingText = "\(Fahrenheit2Celsius(currentWeather.temperature))"
                        
                    } else {
                        addingText = "\(currentWeather.temperature)"
                    }
                    
                    if currentWeather.temperature > 0 {
                        cell.addressLabel.text = NSLocalizedString("TEMPERATURE", comment: "") + " +" + addingText

                    } else {
                        cell.addressLabel.text = NSLocalizedString("TEMPERATURE", comment: "") + " -" + addingText

                    }
                    
                    
                    
                    cell.weatherImageView.image = currentWeather.altIcon
                    
                    
                    
                })
                
                
            } else {
                
                
            }
            
            
        }) 
        
        dataTask.resume()
        
        
        
        
        
        
    }
    
    
    
    // MARK: - ACTIONS

    @IBAction func actionMenuPressed(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowWeather" {
            
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                
                let location = locations[indexPath.row]
                
                let controller = segue.destination as! WeatherViewController
                
                controller.locationToEdit = location
            }
            
        }
        
    }

    
    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return locations.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        let location = locations[indexPath.row]
        
        cell.configureForLocation(location)
        
        getCurrentWeatherDataForLocation(location, andSetCell: cell)
        
        return cell
        
    }
    
    
    // MARK: - UITableViewDelegate
    
    
    
}






