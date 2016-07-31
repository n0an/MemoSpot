//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Anton Novoselov on 16/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//



import UIKit
class CategoryPickerViewController: UITableViewController {
    
    // MARK: - ATTRIBUTES
    
    var selectedCategoryName = ""
    
    let categories = [ NSLocalizedString("CATEGORY_NO", comment: ""),
                       NSLocalizedString("CATEGORY_CITY", comment: ""),
                       NSLocalizedString("CATEGORY_INTERESTING_PLACE", comment: ""),
                       NSLocalizedString("CATEGORY_ARCHITECTURE", comment: ""),
                       NSLocalizedString("CATEGORY_INDUSTRIAL", comment: ""),
                       NSLocalizedString("CATEGORY_BUILDING", comment: ""),
                       NSLocalizedString("CATEGORY_CHURCH", comment: ""),
                       NSLocalizedString("CATEGORY_LANDSCAPE", comment: ""),
                       NSLocalizedString("CATEGORY_PARK", comment: ""),
                       NSLocalizedString("CATEGORY_FOREST", comment: ""),
                       NSLocalizedString("CATEGORY_MOUNTAIN", comment: ""),
                       ]
    
    var selectedIndexPath = NSIndexPath()
    
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White
        
        for i in 0..<categories.count {
            if categories[i] == selectedCategoryName {
                selectedIndexPath = NSIndexPath(forRow: i, inSection: 0)
                break
            }
        }

    }



    // MARK: - UNWIND NAVIGATION WITH PARAMETER PASSING BACK
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            
            if let indexPath = tableView.indexPathForCell(cell) {
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }

    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let categoryName = categories[indexPath.row]
        
        cell.textLabel!.text = categoryName
        
        if categoryName == selectedCategoryName {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    
    }


    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row != selectedIndexPath.row {
            
            if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
                
                newCell.accessoryType = .Checkmark
            }
            
            if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath) {
                
                oldCell.accessoryType = .None
                
            }
            
            selectedIndexPath = indexPath
        }
    
    
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor = UIColor.blackColor()
        
        if let textLabel = cell.textLabel {
            
            textLabel.textColor = UIColor.whiteColor()
            
            textLabel.highlightedTextColor = textLabel.textColor
            
        }
        
        let selectionView = UIView(frame: CGRect.zero)
        
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        
        cell.selectedBackgroundView = selectionView
        
        
        
    }





}







