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
    
    var selectedIndexPath = IndexPath()
    
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.black
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .white
        
        for i in 0..<categories.count {
            if categories[i] == selectedCategoryName {
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            }
        }

    }



    // MARK: - UNWIND NAVIGATION WITH PARAMETER PASSING BACK
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            
            if let indexPath = tableView.indexPath(for: cell) {
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }

    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let categoryName = categories[indexPath.row]
        
        cell.textLabel!.text = categoryName
        
        if categoryName == selectedCategoryName {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    
    }


    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row != selectedIndexPath.row {
            
            if let newCell = tableView.cellForRow(at: indexPath) {
                
                newCell.accessoryType = .checkmark
            }
            
            if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
                
                oldCell.accessoryType = .none
                
            }
            
            selectedIndexPath = indexPath
        }
    
    
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = UIColor.black
        
        if let textLabel = cell.textLabel {
            
            textLabel.textColor = UIColor.white
            
            textLabel.highlightedTextColor = textLabel.textColor
            
        }
        
        let selectionView = UIView(frame: CGRect.zero)
        
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        
        cell.selectedBackgroundView = selectionView
        
        
        
    }





}







