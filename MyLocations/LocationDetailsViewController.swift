//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Anton Novoselov on 16/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class LocationDetailsViewController: UITableViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!


    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

   
    // MARK: - HELPER METHODS


    // MARK: - ACTIONS

    @IBAction func done() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
