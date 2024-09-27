//
//  SplashScreenViewController.swift
//  unibike-app
//
//  Created by Giyu Tomioka on 9/27/24.
//

import UIKit

class SplashScreenViewController: UIViewController {

    let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Image View for Animation
        imageView.image = UIImage(named: "icon")
        imageView.frame = self.view.bounds
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Animation - scale up then fade out
        UIView.animate(withDuration: 1.5, animations: {
            self.imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.imageView.alpha = 0
        }) { (completed) in
            // Move to the main view controller
            self.moveToMainViewController()
        }
    }

    private func moveToMainViewController() {
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController")
        UIApplication.shared.windows.first?.rootViewController = mainVC
    }
}
