//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Anton Novoselov on 16/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

import CoreData

// * PRIVATE GLOBAL PROPERTY


private let dateFormatter: DateFormatter = {
    
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    
    
    
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
    
    @IBOutlet weak var favoriteMapView: MKMapView!

    
    // MARK: - PROPERTIES
    
    var weather: WeeklyWeather!
    
    var locationToEdit: Location? {
        
        didSet {
            
            if let location = locationToEdit {
                
                descriptionText = location.locationDescription
                
                categoryName = location.category
                
                date = location.date as Date
                
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                
                placemark = location.placemark
                
            }
            
        }
    }
    
    var descriptionText = ""

    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    
    var categoryName = NSLocalizedString("CATEGORY_NAME_NO", comment: "")
    
    var managedObjectContext: NSManagedObjectContext!

    var date = Date()
    
    
    var image: UIImage? {
        didSet {
            
            if let image = image {
                
                imageView.image = image
                imageView.isHidden = false

                addPhotoLabel.isHidden = true
            }
            
        }
    }
    
    var observer: AnyObject!
    
    let latitudeDelta = 0.005
    let longitudeDelta = 0.005
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        
        // TableView colors changing
        tableView.backgroundColor = UIColor.black
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .white
        
        descriptionTextView.textColor = UIColor.white
        descriptionTextView.backgroundColor = UIColor.black
        
        addPhotoLabel.textColor = UIColor.white
        addPhotoLabel.highlightedTextColor = addPhotoLabel.textColor
        
        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        
        addressLabel.highlightedTextColor = addressLabel.textColor
        
        
        
        if let location = locationToEdit {
            title = NSLocalizedString("TITLE_EDIT", comment: "")
            
            if location.hasPhoto {
                
                if let image = location.photoImage {
                    
                    showImage(image)
                }
            }
            
            favoriteMapView.isUserInteractionEnabled = true
            
            let mapTapGesture = UITapGestureRecognizer(target: self, action: #selector(LocationDetailsViewController.mapViewTapped(_:)))
            favoriteMapView.addGestureRecognizer(mapTapGesture)

            
        } else {
            favoriteMapView.isUserInteractionEnabled = false
        }
        
        descriptionTextView.text = descriptionText
        
        categoryLabel.text = categoryName

        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark)
            
        } else {
            addressLabel.text = NSLocalizedString("ADDRESSLABEL_NO_FOUND", comment: "")
        }
        
        dateLabel.text = formatDate(date)
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LocationDetailsViewController.hideKeyboard(_:)))
        gestureRecognizer.cancelsTouchesInView = false
        
        tableView.addGestureRecognizer(gestureRecognizer)
        
        // USE NOTIFICATIONS TO HIDE ALERTS ACTION SHEETS AND PICKER WHEN APP GOES BACKGROUND
        listenForBackgroundNotification()
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        let name = "MemoSpot~\(title)"
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        
        
        
        
        let span = MKCoordinateSpan.init(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        
        let region = MKCoordinateRegion.init(center: coordinate, span: span)
        
        favoriteMapView.setRegion(region, animated: false)
        
        
        
        
        
        
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(observer)
    }

   
    // MARK: - GESTURE RECOGNIZERS
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        
 
        
        let indexPath = tableView.indexPathForRow(at: point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        
        descriptionTextView.resignFirstResponder()
    }
    
    @objc func mapViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        
        performSegue(withIdentifier: "ShowLocation", sender: nil)
        
    }
    
    
    // MARK: - HELPER METHODS

    func stringFromPlacemark(_ placemark: CLPlacemark) -> String {
        
        var line = ""
        
        line.addText(placemark.subThoroughfare)
        line.addText(placemark.thoroughfare, withSeparator: " ")
        
        line.addText(placemark.locality, withSeparator: ", ")
        
        line.addText(placemark.administrativeArea, withSeparator: ", ")
        line.addText(placemark.postalCode, withSeparator: " ")
        line.addText(placemark.country, withSeparator: ", ")
        
        return line
        
    }
    
    func formatDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    
    
    func showImage(_ image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        addPhotoLabel.isHidden = true
    }
    
    
    
    
    
    // MARK: - NOTIFICATIONS
    
    func listenForBackgroundNotification() {
        
        observer = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
            
            if let strongSelf = self {
                
                if strongSelf.presentedViewController != nil {
                    strongSelf.dismiss(animated: false, completion: nil)
                }
                
                strongSelf.descriptionTextView.resignFirstResponder()
            }
        
        }
    }
    
    
    


    // MARK: - ACTIONS

    @IBAction func done() {
        
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        
        let location: Location
        
        if let temp = locationToEdit {
            hudView.text = NSLocalizedString("HUDVIEW_UPDATED", comment: "")
            location = temp
            
        } else {
            
            hudView.text = NSLocalizedString("HUDVIEW_TAGGED", comment: "")
            
            location = NSEntityDescription.insertNewObject(forEntityName: "Location", into: managedObjectContext) as! Location
            location.photoID = nil
        }
        
        
        location.locationDescription    = descriptionTextView.text
        location.category               = categoryName
        location.latitude               = coordinate.latitude
        location.longitude              = coordinate.longitude
        location.date                   = date
        location.placemark              = placemark
        
        
        if let image = image {
            if !location.hasPhoto {
                
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            
            if let data = image.jpegData(compressionQuality: 0.5) { // 3
                do {
                    try data.write(to: URL(fileURLWithPath: location.photoPath),
                                         options: .atomic)
                    
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
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            
            controller.selectedCategoryName = categoryName
            
        } else if segue.identifier == "ShowLocation" {
            let controller = segue.destination as! MapLocationViewController
            
            controller.locationToEdit = locationToEdit
            
            
        } else if segue.identifier == "ShowWeather" {
            
            let controller = segue.destination as! WeatherViewController
            
            controller.locationToEdit = locationToEdit
            
            
        }
        
    }
    
    
    
    // MARK: - Unwind Segue handler
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        
        let controller = segue.source as! CategoryPickerViewController
        
        categoryName = controller.selectedCategoryName
        
        categoryLabel.text = categoryName
        
    }
    
    
    
    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch (indexPath.section, indexPath.row) {
        
        case (0, 0):
            return 88
            
        case (1, _):
            if imageView.isHidden {
                
                return 44
                
            } else {
                
                var ratio = CGFloat()
                
                if let location = locationToEdit {
                    
                    if location.hasPhoto {
                        
                        if let image = location.photoImage {
                            
                            ratio = image.size.height / image.size.width
                        }
                        
                    } else {
                        
                        ratio = image!.size.height / image!.size.width
                        
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
            
        case (2, 0):
            return 88
            
        case (3, 2):
            return addressLabel.frame.size.height + 40
            
        default:
            return 44
            
            
        }
        
        
        
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if locationToEdit == nil {
            
            if (indexPath.section == 2 && indexPath.row == 0) || (indexPath.section == 2 && indexPath.row == 1) {
                return nil
            }
            
            
        }
        
        if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 {
            
            return indexPath
            
        } else {
            
            return nil
        }
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
            
        } else if indexPath.section == 1 && indexPath.row == 0 {
            pickPhoto()
            
        } else if indexPath.section == 2 && indexPath.row == 0 {
            
            if locationToEdit != nil {
                performSegue(withIdentifier: "ShowLocation", sender: nil)
            }
            
            
            
        } else if indexPath.section == 2 && indexPath.row == 1 {

            if locationToEdit != nil {
                performSegue(withIdentifier: "ShowWeather", sender: nil)

            }
            
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = UIColor.black
        
        if let textLabel = cell.textLabel {
            
            textLabel.textColor = UIColor.white
            
            textLabel.highlightedTextColor = textLabel.textColor
            
        }
        
        if let detailLabel = cell.detailTextLabel {
            
            detailLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
            
            detailLabel.highlightedTextColor = detailLabel.textColor
        }
        
        let selectionView = UIView(frame: CGRect.zero)
        
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        
        cell.selectedBackgroundView = selectionView
        
        
        
        if indexPath.section == 3 && indexPath.row == 2 {
            let addressLabel = cell.viewWithTag(100) as! UILabel
            addressLabel.textColor = UIColor.white
            addressLabel.highlightedTextColor = addressLabel.textColor
        }
        
        if indexPath.section == 2 && indexPath.row == 1 {
            let weatherLabel = cell.viewWithTag(101) as! UILabel
            weatherLabel.textColor = UIColor.white
            weatherLabel.highlightedTextColor = weatherLabel.textColor
        }
        
    }
    
    
    

}





// MARK: - UIImagePickerControllerDelegate

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func pickPhoto() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        
        }
    }
    
    func showPhotoMenu() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("CAMERA_ALERT_CANCEL_ACTION", comment: ""), style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: NSLocalizedString("CAMERA_ALERT_PHOTO_ACTION", comment: ""), style: .default, handler: { _ in self.takePhotoWithCamera() })
        
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibraryAction = UIAlertAction(title: NSLocalizedString("CAMERA_ALERT_LIBRARY_ACTION", comment: ""), style: .default, handler: { _ in self.choosePhotoFromLibrary() })
        
        alertController.addAction(chooseFromLibraryAction)
        
        let addPhotoCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1))
        
        alertController.popoverPresentationController?.sourceView = addPhotoCell?.contentView
        
        alertController.popoverPresentationController?.permittedArrowDirections = [.down]

        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func takePhotoWithCamera() {
        
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        
        imagePicker.sourceType = .camera
        
        imagePicker.delegate = self
        
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func choosePhotoFromLibrary() {
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor

        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage

        
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    

}

















// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
