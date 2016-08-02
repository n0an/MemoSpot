//
//  FirstViewController.swift
//  MyLocations
//
//  Created by nag on 14.06.16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreLocation

import CoreData

import QuartzCore

import AudioToolbox

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    
    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var longitudeTextLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    
    // MARK: - ATTRIBUTES
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    
    var updatingLocation = false
    var lastLocationError: NSError?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    
    var timer: NSTimer?
    
    var managedObjectContext: NSManagedObjectContext!
    
    
    var logoVisible = false
    
    lazy var logoButton: UIButton = {
        
        let button = UIButton(type: .Custom)
        button.setBackgroundImage(UIImage(named: "Logo5"), forState: .Normal)
        button.sizeToFit()
        
        button.addTarget(self, action: #selector(CurrentLocationViewController.getLocation), forControlEvents: .TouchUpInside)
        
        button.center.x = CGRectGetMidX(self.view.bounds)
        button.center.y = 220
        
        return button
    
    }()
    
    
    var soundID: SystemSoundID = 0
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels()
        
        configureGetButton()
        
        loadSoundEffect("Sound.caf")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let name = "MemoSpot~\(title)"
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
    }
    
    
    
    // MARK: - HELPER METHODS
    
    func showLocationServicesDeniedAlert() {
        
        let alert = UIAlertController(title: NSLocalizedString("LOCATION_SERVICES_DENIED_ALERT_TITLE", comment: ""), message: NSLocalizedString("", comment: "LOCATION_SERVICES_DENIED_ALERT_MESSAGE"), preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alert.addAction(okAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func updateLabels() {
        
        if let location = location {
            
            latitudeTextLabel.hidden = false
            longitudeTextLabel.hidden = false
            
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.hidden = false
            messageLabel.text = ""
            
            if let placemark = placemark {
                addressLabel.text = stringFromPlacemark(placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = NSLocalizedString("ADDRESSLABEL_TEXT_SEARCHING", comment: "")
            } else if lastGeocodingError != nil {
                addressLabel.text = NSLocalizedString("ADDRESSLABEL_TEXT_ERROR1", comment: "")
            } else {
                addressLabel.text = NSLocalizedString("ADDRESSLABEL_TEXT_ERROR2", comment: "")
            }
            
        } else {
            
            latitudeTextLabel.hidden = true
            longitudeTextLabel.hidden = true
            
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.hidden = true
            messageLabel.text = NSLocalizedString("MESAGGE_LABEL_TAPTO", comment: "")
            
            
            let statusMessage: String
            if let error = lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                    statusMessage = NSLocalizedString("STATUSMESSAGE_ERROR_DISABLED", comment: "")
                } else {
                    statusMessage = NSLocalizedString("STATUSMESSAGE_ERROR_GETTING", comment: "")
                }
                
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = NSLocalizedString("STATUSMESSAGE_ERROR_DISABLED", comment: "")
            } else if updatingLocation {
                statusMessage = NSLocalizedString("STATUSMESSAGE_SEARCHING", comment: "")
            } else {
                statusMessage = ""
                
                showLogoView()
            }
            
            messageLabel.text = statusMessage
            
        }
        
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            updatingLocation = true
            
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(CurrentLocationViewController.didTimeOut), userInfo: nil, repeats: false)
        }
    }
    
    func stopLocationManager() {
        
        if updatingLocation {
            
            if let timer = timer {
                timer.invalidate()
            }
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
        
    }
    
    func configureGetButton() {
        
        let spinnerTag = 1000
        
        if updatingLocation {
            getButton.setTitle(NSLocalizedString("BUTTON_STOP_SEARCH", comment: ""), forState: .Normal)
            
            if view.viewWithTag(spinnerTag) == nil {
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
                
                spinner.center = messageLabel.center
                
                spinner.center.y += spinner.bounds.size.height/2 + 40
                spinner.startAnimating()
                spinner.tag = spinnerTag
                
                containerView.addSubview(spinner)
            }
            
        } else {
            getButton.setTitle(NSLocalizedString("BUTTON_GET_LOCATION", comment: ""), forState: .Normal)
            
            if let spinner = view.viewWithTag(spinnerTag) {
                spinner.removeFromSuperview()
            }
        }
        
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        
        var line1 = ""
        
        line1.addText(placemark.subThoroughfare)
        line1.addText(placemark.thoroughfare, withSeparator: " ")
        
        var line2 = ""
        
        line2.addText(placemark.locality)
        line2.addText(placemark.administrativeArea, withSeparator: " ")
        line2.addText(placemark.postalCode, withSeparator: " ")
        
        line1.addText(line2, withSeparator: "\n")
        
        return line1
        
    }
    

    
    func didTimeOut() {
        
        if location == nil {
            stopLocationManager()
            
            
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            
            updateLabels()
            
            configureGetButton()
        }
    }
    
    
    func showLogoView() {
        
        if !logoVisible {
            logoVisible = true
            
            containerView.hidden = true
            
            view.addSubview(logoButton)
        }
    }
    
    func hideLogoView() {
        
        if !logoVisible {
            return
        }
        
        logoVisible = false
        containerView.hidden = false
        
        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 8 + containerView.bounds.size.height / 2

        let centerX = CGRectGetMidX(view.bounds)
        
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.removedOnCompletion = false
        panelMover.fillMode = kCAFillModeForwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(CGPoint: containerView.center)
        panelMover.toValue = NSValue(CGPoint: CGPoint(x: centerX, y: containerView.center.y))
        panelMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        panelMover.delegate = self
        containerView.layer.addAnimation(panelMover, forKey: "panelMover")
        
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.removedOnCompletion = false
        logoMover.fillMode = kCAFillModeForwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(CGPoint: logoButton.center)
        logoMover.toValue = NSValue(CGPoint: CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.addAnimation(logoMover, forKey: "logoMover")
        
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.removedOnCompletion = false
        logoRotator.fillMode = kCAFillModeForwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * M_PI
        logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.addAnimation(logoRotator, forKey: "logoRotator")
        
        
        
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }
    
    
    
    // MARK: - ACTIONS
    @IBAction func getLocation() {
        
        // Get user permission to share location
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .Denied || authStatus == .Restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        if logoVisible {
            hideLogoView()
        }
        
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            
            startLocationManager()
        }
        
        
        
        updateLabels()
        
        configureGetButton()
        
    }
    
    
    // MARK: - NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "TagLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let controller = navigationController.topViewController as! LocationDetailsViewController
            
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            
            controller.managedObjectContext = managedObjectContext
            
        }
        
    }
    
  
    
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
        
        configureGetButton()
        
    }
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.last!
        
        
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 { // Caching location
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distanceFromLocation(location)
        }
        
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            
            lastLocationError = nil
            location = newLocation
            updateLabels()
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                
                stopLocationManager()
                configureGetButton()
            }
            
            if distance > 0 {
                performingReverseGeocoding = false
            }
            
            if !performingReverseGeocoding {
                
                
                performingReverseGeocoding = true
                
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) in
                    
                    
                    self.lastLocationError = error
                    
                    if error == nil, let p = placemarks where !p.isEmpty {
                        
                        if self.placemark == nil {
                            
                            self.playSoundEffect()
                            
                        }
                        
                        self.placemark = p.last!
                        
                    } else {
                        self.placemark = nil
                    }
                    
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                    
                })
                
            }
            
            
        } else if distance < 1.0 {
            
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            
            if timeInterval > 10 {
                
                
                stopLocationManager()
                
                updateLabels()
                
                configureGetButton()
            }
            
            
        }
        
 
        
    }
    
    
  
    func loadSoundEffect(name: String) {
        
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: nil) {
            
            let fileURL = NSURL.fileURLWithPath(path, isDirectory: false)
            
            let error = AudioServicesCreateSystemSoundID(fileURL, &soundID)
            
            if error != kAudioServicesNoError {
            }
        }
    }
    
    
    func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
        
    }
    
    func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID)
        
    }
    
    
    
    
    


}




















