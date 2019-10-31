//
//  CalendarViewController.swift
//  MyLocations
//
//  Created by Anton Novoselov on 16/07/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import FSCalendar

protocol CalendarViewControllerDelegate: class {
    
    func dateSelected(_ date:Date)
    
    
}

class CalendarViewController: UIViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var showButton: UIBarButtonItem!
    
    @IBOutlet weak var fsCalendar: FSCalendar!

    
    
    // MARK: - PROPERTIES
    
    let calend = ANConfigurator.sharedConfigurator.calendar
    
    var allDueDates: [Date] = []
    
    var selectedDate: Date!
    
    weak var delegate: CalendarViewControllerDelegate!
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        fsCalendar.reloadData()
        
        if selectedDate == nil {
            showButton.isEnabled = false
        }
        
    }

    // MARK: - HELPER METHODS
    
    func formatDate(_ date: Date) -> String {
        return ANConfigurator.sharedConfigurator.dateFormatter.string(from: date)
    }
    
    
    // MARK: - ACTIONS
    
    @IBAction func showButtonPressed(_ sender: UIBarButtonItem) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    
    

}





// MARK: - FSCalendarDataSource

extension CalendarViewController: FSCalendarDataSource {
    
    
    
}

// MARK: - FSCalendarDelegate

extension CalendarViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        
        selectedDate = date
        
        showButton.isEnabled = true
        
        delegate.dateSelected(selectedDate)
        
    }
    
}

















