//
//  BikeRentingViewController.swift
//  unibike-app
//
//  Created by Giyu Tomioka on 9/21/24.
//

import UIKit
import UserNotifications

class BikeRentingViewController: UIViewController {
    
    // UI Components
    @IBOutlet weak var bikeIdLabel: UILabel!
    @IBOutlet weak var startDateTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var returnButton: UIButton!

    // Variables
    var bikeId: String?
    var timer: Timer?
    var startDate: Date?
    var isLocked = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Back button
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backAction))
        navigationItem.leftBarButtonItem = backButton

        // Set bike ID
        if let bikeId = bikeId {
            bikeIdLabel.text = "Bike \(bikeId)"
        }

        // Set the start date and time to real-time
        startDate = Date()
        if let startDate = startDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            startDateTimeLabel.text = "Start Time: \(dateFormatter.string(from: startDate))"
        }

        // Start the timer to calculate duration
        startDurationTimer()

        // Set up local notification for renting duration
        setupLocalNotification()
    }

    // Action to go back to the previous screen
    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }

    // Start the timer to update the duration label
    func startDurationTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateDurationLabel), userInfo: nil, repeats: true)
    }

    // Update the duration label based on the time difference
    @objc func updateDurationLabel() {
        if let startDate = startDate {
            let currentTime = Date()
            let duration = currentTime.timeIntervalSince(startDate)

            let hours = Int(duration) / 3600
            let minutes = (Int(duration) % 3600) / 60
            let seconds = Int(duration) % 60

            durationLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }

    // Action for the lock/unlock button
    @IBAction func lockButtonTapped(_ sender: UIButton) {
        isLocked.toggle()
        if isLocked {
            lockButton.setTitle("Unlock", for: .normal)
            lockButton.tintColor = .green
        } else {
            lockButton.setTitle("Lock", for: .normal)
            lockButton.tintColor = .red
        }
    }

    // Return button action
    @IBAction func returnButtonTapped(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }

    // Setup local notification for rental duration updates
    func setupLocalNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                self.scheduleNotification()
            }
        }
    }

    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Bike Rental Ongoing"
        content.body = "You have been renting a bike for over an hour!"

        // Trigger the notification after 1 hour
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)

        // Create the request
        let request = UNNotificationRequest(identifier: "BikeRentalNotification", content: content, trigger: trigger)

        // Schedule the notification
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request, withCompletionHandler: nil)
    }

    // Stop the timer and clear the notification when the view is dismissed
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
