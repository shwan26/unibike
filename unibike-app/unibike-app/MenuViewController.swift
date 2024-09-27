//
//  MenuViewController.swift
//  unibike-app
//
//  Created by Naw Tulip on 27/9/2567 BE.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Array to hold titles for the menu items
        let menuItems = ["My Profile", "Riding History", "Riding Guide"]

        override func viewDidLoad() {
            super.viewDidLoad()
            // Set delegate and dataSource for the TableView
            tableView.delegate = self
            tableView.dataSource = self
        }

        // MARK: - TableView DataSource Methods
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // Return the number of menu items
            return menuItems.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // Check the index and dequeue the appropriate cell
            switch indexPath.row {
            case 0: // "My Profile"
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
                cell.textLabel?.text = menuItems[indexPath.row]
                return cell
            case 1: // "Riding History"
                let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
                cell.textLabel?.text = menuItems[indexPath.row]
                return cell
            case 2: // "Riding Guide"
                let cell = tableView.dequeueReusableCell(withIdentifier: "GuideCell", for: indexPath)
                cell.textLabel?.text = menuItems[indexPath.row]
                return cell
            default:
                fatalError("Unexpected indexPath")
            }
        }

        // MARK: - TableView Delegate Method
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after tapping
            
            // No segue performance here, to be set up in the storyboard
        }
    }
