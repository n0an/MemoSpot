//
//  LocationCell.swift
//  MyLocations
//
//  Created by nag on 18.06.16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var weatherImageView: UIImageView!

    
    
    // MARK: - HELPER METHODS

    func configureForLocation(location: Location) {
        
        if location.locationDescription.isEmpty {
            
            descriptionLabel.text = NSLocalizedString("NO_DESCRIPTION", comment: "")
            
        } else {
            
            descriptionLabel.text = location.locationDescription
        }
        
        if let placemark = location.placemark {
            
            var text = ""
            
            text.addText(placemark.subThoroughfare)
            
            text.addText(placemark.thoroughfare, withSeparator: " ")
            
            text.addText(placemark.locality, withSeparator: ", ")
            
            
            addressLabel.text = text
            
            
        } else {
            
            addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }
        
        photoImageView.image = imageForLocation(location)
    }
    
    
    
    
    func imageForLocation(location: Location) -> UIImage {
        
        if location.hasPhoto, let image = location.photoImage {
            
            let processedImage = image.resizedImageWithBounds(CGSize(width: 52, height: 52))
            
            return processedImage
            
        }
        
        return UIImage(named: "No Photo")!
        
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // !!!IMPORTANT!!!
        // CUSTOMIZE CELL COLORS
        backgroundColor = UIColor.blackColor()
        descriptionLabel.textColor = UIColor.whiteColor()
        descriptionLabel.highlightedTextColor = descriptionLabel.textColor
        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        addressLabel.highlightedTextColor = addressLabel.textColor
        
        // !!!IMPORTANT!!!
        // CUSTOMIZE TABLEVIEW CELL SELECTION COLOR
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        selectedBackgroundView = selectionView
        
        
        photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
        
        photoImageView.clipsToBounds = true
        
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
