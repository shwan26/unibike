//
//  RidingGuideViewController.swift
//  unibike-app
//
//  Created by Naw Tulip on 27/9/2567 BE.
//

import UIKit

class RidingGuideViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var selectedCategory: String?
    
    // Sample data
    var steps = [
        ("Locate a Bike Station", "step1.jpg"),
        ("Select Rental Option", "step2.jpg"),
        ("Scan ID", "step3.jpg"),
        ("Choose Bike", "step4.jpg"),
        ("Confirm Rental", "step5.jpg")
    ]
    
    var tips = [
        ("Registration", "Register with the bike rental service in advance for a smoother experience."),
        ("Safety Gear", "Always wear a helmet and appropriate safety gear.")
    ]
    
    var thingsToAvoid = [
        ("Ignoring Issues", "Don’t ignore any mechanical problems with the bike; report them immediately."),
        ("Riding Without Payment", "Ensure your payment is confirmed before taking the bike.")
    ]

    var details: [(String, String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Configure the flow layout for horizontal scrolling
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: 300) // Customize cell size
        layout.minimumLineSpacing = 10 // Spacing between cells
        collectionView.collectionViewLayout = layout
        
        // Load the corresponding details
        if let category = selectedCategory {
            switch category {
            case "Steps to Rent a Bike":
                details = steps
            case "Tips":
                details = tips
            case "Things to Avoid":
                details = thingsToAvoid
            default:
                break
            }
        }

        // Optional: Enable paging
        collectionView.isPagingEnabled = true
    }

    // MARK: - CollectionView DataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return details.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCell", for: indexPath) as! DetailCollectionViewCell
        let detail = details[indexPath.row]
        cell.titleLabel.text = detail.0
        cell.imageView.image = UIImage(named: detail.1) // Ensure images are added to the project
        return cell
    }
}

