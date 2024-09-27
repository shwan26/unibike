//
//  DetailCollectionViewCell.swift
//  unibike-app
//
//  Created by Naw Tulip on 27/9/2567 BE.
//

import UIKit

class DetailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Additional customization if needed
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
    }
}

