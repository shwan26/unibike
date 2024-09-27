//
//  RidingGuideViewController.swift
//  unibike-app
//
//  Created by Naw Tulip on 27/9/2567 BE.
//

import UIKit

class RidingGuideViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var steps = [
        ("Locate a Bike Station", "step1.jpg"),
        ("Select Rental Option", "step2.jpg"),
        ("Scan ID", "step3.jpg"),
        ("Choose Bike", "step4.jpg"),
        ("Confirm Rental", "step5.jpg")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return steps.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCell", for: indexPath) as! DetailCollectionViewCell
        let step = steps[indexPath.row]
        cell.titleLabel.text = step.0
        cell.imageView.image = UIImage(named: step.1) // Make sure the images are in your Assets
        return cell
    }
}
