//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Anton Novoselov on 16/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreLocation

import CoreData

// * PRIVATE GLOBAL PROPERTY

private let apiKey = "da80aefa4ec207511622f3af58b36013"  // https://developer.forecast.io

private let dateFormatter: NSDateFormatter = {
    
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    
    print("return formatter")
    
    return formatter
}()

class LocationDetailsViewController: UITableViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    // MARK: - ATTRIBUTES
    
    var locationToEdit: Location? {
        
        didSet {
            
            if let location = locationToEdit {
                
                descriptionText = location.locationDescription
                
                categoryName = location.category
                
                date = location.date
                
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                
                placemark = location.placemark
                
            }
            
        }
    }
    
    var descriptionText = ""

    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    
    var categoryName = "No Category"
    
    var managedObjectContext: NSManagedObjectContext!

    var date = NSDate()
    
    
    var image: UIImage? {
        didSet {
            
            if let image = image {
                
                imageView.image = image
                imageView.hidden = false
//                imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
                addPhotoLabel.hidden = true
            }
            
        }
    }
    
    var observer: AnyObject!
    
    
    

    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView colors changing
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White
        
        descriptionTextView.textColor = UIColor.whiteColor()
        descriptionTextView.backgroundColor = UIColor.blackColor()
        
        addPhotoLabel.textColor = UIColor.whiteColor()
        addPhotoLabel.highlightedTextColor = addPhotoLabel.textColor
        
        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        
        addressLabel.highlightedTextColor = addressLabel.textColor
        
        
        
        if let location = locationToEdit {
            title = "Edit Location"
            
            getCurrentWeatherData()
            
            if location.hasPhoto {
                
                if let image = location.photoImage {
                    
                    showImage(image)
                }
            }
            
        }
        
        descriptionTextView.text = descriptionText
        
        categoryLabel.text = categoryName

        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark)
            
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = formatDate(date)
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LocationDetailsViewController.hideKeyboard(_:)))
        gestureRecognizer.cancelsTouchesInView = false
        
        tableView.addGestureRecognizer(gestureRecognizer)
        
        // USE NOTIFICATIONS TO HIDE ALERTS ACTION SHEETS AND PICKER WHEN APP GOES BACKGROUND
        listenForBackgroundNotification()
        
        
        
        
        
        
    }
    
    deinit {
        print("*** deinit \(self)")
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }

   
    // MARK: - HELPER METHODS
    
    func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView)
        
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        
        descriptionTextView.resignFirstResponder()
    }
    
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        
        var line = ""
        
        line.addText(placemark.subThoroughfare)
        line.addText(placemark.thoroughfare, withSeparator: " ")
        
        line.addText(placemark.locality, withSeparator: ", ")
        
        line.addText(placemark.administrativeArea, withSeparator: ", ")
        line.addText(placemark.postalCode, withSeparator: " ")
        line.addText(placemark.country, withSeparator: ", ")
        
        return line
        
    }
    
    func formatDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    
    
    func showImage(image: UIImage) {
        imageView.image = image
        imageView.hidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        addPhotoLabel.hidden = true
    }
    
    // MARK: - NOTIFICATIONS
    
    
    // !!!IMPORTANT!!! HIG
    // HIDING ALERTS, ACTIONS SHEETS, PICKERS WHEN APP GOES TO BACKGROUND
    
    func listenForBackgroundNotification() {
        
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] _ in
            
            if let strongSelf = self {
                
                if strongSelf.presentedViewController != nil {
                    strongSelf.dismissViewControllerAnimated(false, completion: nil)
                }
                
                strongSelf.descriptionTextView.resignFirstResponder()
            }
        
        }
    }
    
    
    
    
    // MARK: - WEATHER METHODS
    
    func getCurrentWeatherData() -> Void {
        
        let userLocation = "\(coordinate.latitude),\(coordinate.longitude)"
        
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = NSURL(string: "\(userLocation)", relativeToURL:baseURL)
        
        
        let sharedSession = NSURLSession.sharedSession()
        
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL!, completionHandler: { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if (error == nil) {
                
                let dataObject = NSData(contentsOfURL: location!)
                let weatherDictionary: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(dataObject!, options: [])) as! NSDictionary
                
                let currentWeather = CurrentWeather(weatherDictionary: weatherDictionary)
                let weeklyWeather = WeeklyWeather(weatherDictionary: weatherDictionary)
                
//                print(weatherDictionary)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    print("temperature = \(Fahrenheit2Celsius(currentWeather.temperature))")
                    print("humidity = \(currentWeather.humidity)")
                    
                    //7 day out look
                    
                    print("tempDayOne = \(Fahrenheit2Celsius(weeklyWeather.dayOneTemperatureMin))°/ \(Fahrenheit2Celsius(weeklyWeather.dayOneTemperatureMax))°")
                    
                    print("tempDayTwo = \(Fahrenheit2Celsius(weeklyWeather.dayTwoTemperatureMin))°/ \(Fahrenheit2Celsius(weeklyWeather.dayTwoTemperatureMax))°")
                    
                    print("dayOneTime = \(weeklyWeather.dayOneTime!)")
                    print("dayTwoTime = \(weeklyWeather.dayTwoTime!)")
                    print("dayThreeTime = \(weeklyWeather.dayThreeTime!)")
                    
                    
                })
                
                
                
            } else {
                
                let networkIssueController = UIAlertController(title: "NO API KEY", message: "Hello! Looks like you forgot to add the API KEY", preferredStyle: .Alert)
                let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                networkIssueController.addAction(okButton)
                let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                networkIssueController.addAction(cancelButton)
                self.presentViewController(networkIssueController, animated: true, completion: nil)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    
                })
            }
            
        })
        
        downloadTask.resume()
        
    }

    
    
    
    


    // MARK: - ACTIONS

    @IBAction func done() {
//        dismissViewControllerAnimated(true, completion: nil)
        
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        
        let location: Location
        
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
            
        } else {
            
            hudView.text = "Tagged"
            
            location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext) as! Location
            location.photoID = nil
        }
        
        
        location.locationDescription    = descriptionTextView.text
        location.category               = categoryName
        location.latitude               = coordinate.latitude
        location.longitude              = coordinate.longitude
        location.date                   = date
        location.placemark              = placemark
        
        
        if let image = image { // 1
            if !location.hasPhoto {
                
                location.photoID = Location.nextPhotoID()
            }
            // 2
            if let data = UIImageJPEGRepresentation(image, 0.5) { // 3
                do {
                    try data.writeToFile(location.photoPath,
                                         options: .DataWritingAtomic)
                    
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }
        
        
        
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        
//         ** Close VC after 0.6 sec
        afterDelay(0.6) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerViewController
            
            controller.selectedCategoryName = categoryName
            
        } else if segue.identifier == "ShowLocation" {
            let controller = segue.destinationViewController as! MapLocationViewController
            
            controller.locationToEdit = locationToEdit
            
        }
        
    }
    
    // MARK: - Unwind Segue handler
    
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
        
        let controller = segue.sourceViewController as! CategoryPickerViewController
        
        categoryName = controller.selectedCategoryName
        
        categoryLabel.text = categoryName
        
    }
    
    
    
    
    // MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch (indexPath.section, indexPath.row) {
        
        case (0, 0):
            return 88
            
        case (1, _):
            if imageView.hidden {
                
                return 44
                
            } else {
                
                var ratio = CGFloat()
                
                if let location = locationToEdit {
                    
                    if location.hasPhoto {
                        
                        if let image = location.photoImage {
                            
                            ratio = image.size.height / image.size.width
                        }
                    }
                    
                } else {
                    
                    ratio = image!.size.height / image!.size.width
                }
                
                
                if ratio < 1.0 {
                    return 260 * ratio
                } else {
                    return 260
                }
                
            }
            
        case (2, 2):
            return addressLabel.frame.size.height + 40
            
        default:
            return 44
            
            
        }
        
        
        
        /*
        if indexPath.section == 0 && indexPath.row == 0 {
            return 88
        
        } else if indexPath.section == 1 {
            
            if imageView.hidden {
                
                return 44
                
            } else {
                
                let ratio = image!.size.height / image!.size.width
                
                if ratio < 1.0 {
                    return 260 * ratio
                } else {
                    return 260
                }
                
            }
        
        
        } else if indexPath.section == 2 && indexPath.row == 2 {
            
//            addressLabel.frame.size = CGSize(width: view.bounds.width - 115, height: 10000)
//            addressLabel.sizeToFit()
//            addressLabel.frame.origin.x  = view.bounds.size.width - addressLabel.frame.size.width - 15
            

            return addressLabel.frame.size.height + 40
            
        } else {
            return 44
        }
        */
        
    }
    
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 {
            
            return indexPath
            
        } else {
            
            return nil
        }
        
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            pickPhoto()
        }
        
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor = UIColor.blackColor()
        
        if let textLabel = cell.textLabel {
            
            textLabel.textColor = UIColor.whiteColor()
            
            textLabel.highlightedTextColor = textLabel.textColor
            
        }
        
        if let detailLabel = cell.detailTextLabel {
            
            detailLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
            
            detailLabel.highlightedTextColor = detailLabel.textColor
        }
        
        let selectionView = UIView(frame: CGRect.zero)
        
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        
        cell.selectedBackgroundView = selectionView
        
        
        
        if indexPath.row == 2 {
            let addressLabel = cell.viewWithTag(100) as! UILabel
            addressLabel.textColor = UIColor.whiteColor()
            addressLabel.highlightedTextColor = addressLabel.textColor
        }
        
    }
    
    
    
    
    
    
    





}



// MARK: - UIImagePickerControllerDelegate

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func pickPhoto() {
        
        if true || UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        
        }
    }
    
    func showPhotoMenu() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: { _ in self.takePhotoWithCamera() })
        
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default, handler: { _ in self.choosePhotoFromLibrary() })
        
        alertController.addAction(chooseFromLibraryAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func takePhotoWithCamera() {
        
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        
        imagePicker.sourceType = .Camera
        
        imagePicker.delegate = self
        
        imagePicker.allowsEditing = true
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    func choosePhotoFromLibrary() {
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor

        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        
//        if let image = image {
//            showImage(image)
//        }
        
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    
    
    

}
















