//
//  RidingHistoryViewController.swift
//  unibike-app
//
//  Created by Naw Tulip on 27/9/2567 BE.
//

import UIKit

class RidingHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    // Updated riding history data structure
        let ridingHistoryData: [(image: UIImage, title: String, detail: String, cost: String)] = [
            (UIImage(named: "history1")!, "Ride to Campus", "Rode from Station A to Campus", "30 Baht"),
            (UIImage(named: "history2")!, "Ride to Mall", "Rode from Station B to Mall", "40 Baht"),
            (UIImage(named: "history3")!, "Ride Home", "Rode from Campus to Home", "25 Baht")
        ]

        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.delegate = self
            tableView.dataSource = self
        }

        // MARK: - TableView DataSource Methods
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return ridingHistoryData.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryTableViewCell
            
            // Access the data using the tuple
            let entry = ridingHistoryData[indexPath.row]
            cell.titleLabel.text = entry.title
            cell.detailsLabel.text = entry.detail
            cell.costLabel.text = entry.cost
            cell.historyImageView.image = entry.image // Set the image
            
            return cell
        }
    }
