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
    
    var timer: Timer?
    
    var managedObjectContext: NSManagedObjectContext!
    
    
    var logoVisible = false
    
    lazy var logoButton: UIButton = {
        
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "Logo5"), for: UIControl.State())
        button.sizeToFit()
        
        button.addTarget(self, action: #selector(CurrentLocationViewController.getLocation), for: .touchUpInside)
        
        button.center.x = self.view.bounds.midX
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let name = "MemoSpot~\(title)"
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        
    }
    
    
    
    // MARK: - HELPER METHODS
    
    func showLocationServicesDeniedAlert() {
        
        let alert = UIAlertController(title: NSLocalizedString("LOCATION_SERVICES_DENIED_ALERT_TITLE", comment: ""), message: NSLocalizedString("", comment: "LOCATION_SERVICES_DENIED_ALERT_MESSAGE"), preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func updateLabels() {
        
        if let location = location {
            
            latitudeTextLabel.isHidden = false
            longitudeTextLabel.isHidden = false
            
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
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
            
            latitudeTextLabel.isHidden = true
            longitudeTextLabel.isHidden = true
            
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = NSLocalizedString("MESAGGE_LABEL_TAPTO", comment: "")
            
            
            let statusMessage: String
            if let error = lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.Code.denied.rawValue {
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
            
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(CurrentLocationViewController.didTimeOut), userInfo: nil, repeats: false)
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
            getButton.setTitle(NSLocalizedString("BUTTON_STOP_SEARCH", comment: ""), for: UIControl.State())
            
            if view.viewWithTag(spinnerTag) == nil {
                let spinner = UIActivityIndicatorView(style: .white)
                
                spinner.center = messageLabel.center
                
                spinner.center.y += spinner.bounds.size.height/2 + 40
                spinner.startAnimating()
                spinner.tag = spinnerTag
                
                containerView.addSubview(spinner)
            }
            
        } else {
            getButton.setTitle(NSLocalizedString("BUTTON_GET_LOCATION", comment: ""), for: UIControl.State())
            
            if let spinner = view.viewWithTag(spinnerTag) {
                spinner.removeFromSuperview()
            }
        }
        
    }
    
    func stringFromPlacemark(_ placemark: CLPlacemark) -> String {
        
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
    

    
    @objc func didTimeOut() {
        
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
            
            containerView.isHidden = true
            
            view.addSubview(logoButton)
        }
    }
    
    func hideLogoView() {
        
        if !logoVisible {
            return
        }
        
        logoVisible = false
        containerView.isHidden = false
        
        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 8 + containerView.bounds.size.height / 2

        let centerX = view.bounds.midX
        
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = CAMediaTimingFillMode.forwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(cgPoint: containerView.center)
        panelMover.toValue = NSValue(cgPoint: CGPoint(x: centerX, y: containerView.center.y))
        panelMover.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        panelMover.delegate = self as! CAAnimationDelegate
        containerView.layer.add(panelMover, forKey: "panelMover")
        
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode = CAMediaTimingFillMode.forwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(cgPoint: logoButton.center)
        logoMover.toValue = NSValue(cgPoint: CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        logoButton.layer.add(logoMover, forKey: "logoMover")
        
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = CAMediaTimingFillMode.forwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * M_PI
        logoRotator.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        logoButton.layer.add(logoRotator, forKey: "logoRotator")
        
        
        
    }
    
    
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
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
        
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .denied || authStatus == .restricted {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TagLocation" {
            let navigationController = segue.destination as! UINavigationController
            
            let controller = navigationController.topViewController as! LocationDetailsViewController
            
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            
            controller.managedObjectContext = managedObjectContext
            
        }
        
    }
    
  
    
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        if error._code == CLError.Code.locationUnknown.rawValue {
            return
        }
        
        lastLocationError = error as NSError
        
        stopLocationManager()
        updateLabels()
        
        configureGetButton()
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.last!
        
        
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 { // Caching location
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distance(from: location)
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
                    
                    
                    self.lastLocationError = error as! NSError
                    
                    if error == nil, let p = placemarks, !p.isEmpty {
                        
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
            
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            
            if timeInterval > 10 {
                
                
                stopLocationManager()
                
                updateLabels()
                
                configureGetButton()
            }
            
            
        }
        
 
        
    }
    
    
  
    func loadSoundEffect(_ name: String) {
        
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            
            let fileURL = URL(fileURLWithPath: path, isDirectory: false)
            
            let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
            
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




















