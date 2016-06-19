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
    

    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let location = locationToEdit {
            title = "Edit Location"
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
        
        var text = ""
        
        if let s = placemark.subThoroughfare {
            text += s + " "
        }
        
        if let s = placemark.thoroughfare {
            text += s
        }
        
        if let s = placemark.locality {
            text += s + " "
        }
        
        if let s = placemark.administrativeArea {
            text += s + " "
        }
        
        if let s = placemark.postalCode {
            text += s
        }
        
        if let s = placemark.country {
            text += s
        }
        
        return text
        
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
        }
        
        
        location.locationDescription    = descriptionTextView.text
        location.category               = categoryName
        location.latitude               = coordinate.latitude
        location.longitude              = coordinate.longitude
        location.date                   = date
        location.placemark              = placemark
        
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
                
                let ratio = image!.size.height / image!.size.width
                
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
        
        if indexPath.section == 0 || indexPath.section == 1 {
            
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
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.sourceType = .Camera
        
        imagePicker.delegate = self
        
        imagePicker.allowsEditing = true
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
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
















