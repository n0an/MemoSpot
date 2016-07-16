//
//  CalendarViewController.swift
//  MyLocations
//
//  Created by Anton Novoselov on 16/07/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var showButton: UIBarButtonItem!
    
    @IBOutlet weak var fsCalendar: FSCalendar!

    
    
    // MARK: - PROPERTIES
    
    let calend = ANConfigurator.sharedConfigurator.calendar
    
    var allDueDates: [NSDate] = []
    
    var selectedDate: NSDate!
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        fsCalendar.reloadData()
        
        if selectedDate == nil {
            showButton.enabled = false
        }
        
    }

    
    
    // MARK: - ACTIONS
    
    @IBAction func showButtonPressed(sender: UIBarButtonItem) {
        

        
    }
    

    // MARK: - NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
    }

    
    
   

}





// MARK: - FSCalendarDataSource

extension CalendarViewController: FSCalendarDataSource {
    
    
    
}

// MARK: - FSCalendarDelegate

extension CalendarViewController: FSCalendarDelegate {
    
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        
        selectedDate = date
        
        showButton.enabled = true
        
    }
    
}

















