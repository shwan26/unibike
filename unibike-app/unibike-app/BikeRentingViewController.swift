import UIKit
import UserNotifications
import HealthKit

class BikeRentingViewController: UIViewController {

    // UI Components
    @IBOutlet weak var bikeIdLabel: UILabel!
    @IBOutlet weak var startDateTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var calorieBurnLabel: UILabel!        // Added label for calories
    @IBOutlet weak var ridingStatusLabel: UILabel!       // Added label for riding status

    // Variables
    var bikeId: String?
    var timer: Timer?
    var startDate: Date?
    var isLocked = true
    var isTracking = false

    // HealthKit Properties
    let healthStore = HKHealthStore()
    var calorieBurned: Double = 0.0
    var workoutStartDate: Date?
    var activeEnergyUnit = HKUnit.kilocalorie()
    var duration: TimeInterval = 0
    var userWeight: Double = 70.0 // Default
    var healthTimer: Timer?

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

        // Request HealthKit Authorization
        requestHealthKitAuthorization()

        // Fetch User's Weight
        fetchUserWeight()

        // Initialize UI elements
        updateUIForLockState()
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
            // Lock the bike and stop the HealthKit workout
            lockButton.setTitle("Unlock", for: .normal)
            lockButton.tintColor = .green
            stopTracking()
        } else {
            // Unlock the bike and start the HealthKit workout
            lockButton.setTitle("Lock", for: .normal)
            lockButton.tintColor = .red
            startTracking()
        }

        // Update the UI for lock/unlock state
        updateUIForLockState()
    }

    // Return button action
    @IBAction func returnButtonTapped(_ sender: UIButton) {
        stopTracking() // Ensure workout stops
        saveCyclingWorkout() // Save the workout session
        
        // Calculate the rental cost and show the alert
        let totalDuration = Date().timeIntervalSince(startDate ?? Date())
        let cost = calculateRentalCost(for: totalDuration)
        showRentalAlert(with: totalDuration, cost: cost)
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

        // Trigger the notification after 1 hour (3600 seconds)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)

        // Create the request
        let request = UNNotificationRequest(identifier: "BikeRentalNotification", content: content, trigger: trigger)

        // Schedule the notification
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request, withCompletionHandler: nil)
    }

    // HealthKit - Start tracking the cycling workout
    func startTracking() {
        isTracking = true
        calorieBurned = 0.0
        workoutStartDate = Date()
        startHealthTimer()
    }

    // HealthKit - Stop tracking the cycling workout
    func stopTracking() {
        isTracking = false
        healthTimer?.invalidate()
        healthTimer = nil
    }

    // HealthKit - Start the timer to simulate calorie burn and update duration
    func startHealthTimer() {
        healthTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCaloriesAndDuration), userInfo: nil, repeats: true)
    }

    @objc private func updateCaloriesAndDuration() {
        if let start = workoutStartDate {
            duration = Date().timeIntervalSince(start)
        }
        calculateCaloriesBurned() // Simulate calorie burn per second
        updateCalorieLabel()      // Update the calorie burn label
    }

    // Calculate calories burned based on user's weight and time spent cycling
    private func calculateCaloriesBurned() {
        let caloriesPerSecondPerKg = 0.0023 // Moderate cycling: kcal burned per kg per second
        let seconds = duration // Duration is in seconds
        calorieBurned = userWeight * caloriesPerSecondPerKg * seconds
    }

    // Update UI based on lock/unlock state
    private func updateUIForLockState() {
        if isLocked {
            ridingStatusLabel.text = "Stopped"
            calorieBurnLabel.text = "0 kcal"  // Reset calorie display when stopped
        } else {
            ridingStatusLabel.text = "Riding"
            updateCalorieLabel()             // Show the calorie burn in real-time
        }
    }

    // Update the calorie burn label
    private func updateCalorieLabel() {
        calorieBurnLabel.text = String(format: "%.2f kcal", calorieBurned)
    }

    // Fetch the user's weight from HealthKit
    private func fetchUserWeight() {
        guard let weightType = HKSampleType.quantityType(forIdentifier: .bodyMass) else { return }

        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { (query, results, error) in
            if let result = results?.first as? HKQuantitySample {
                let weightInKg = result.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                self.userWeight = weightInKg
                print("User weight: \(weightInKg) kg")
            } else {
                print("No weight data available or error: \(String(describing: error))")
            }
        }

        healthStore.execute(query)
    }

    // HealthKit - Save the cycling workout to HealthKit
    private func saveCyclingWorkout() {
        guard let startDate = workoutStartDate else { return }

        let workout = HKWorkout(activityType: .cycling,
                                start: startDate,
                                end: Date(),
                                duration: duration,
                                totalEnergyBurned: HKQuantity(unit: activeEnergyUnit, doubleValue: calorieBurned),
                                totalDistance: nil, // If tracking distance, provide here
                                metadata: nil)

        healthStore.save(workout) { (success, error) in
            if success {
                print("Cycling workout saved successfully!")
            } else {
                print("Error saving workout: \(String(describing: error?.localizedDescription))")
            }
        }
    }

    // Request HealthKit Authorization
    private func requestHealthKitAuthorization() {
        let typesToShare: Set = [HKObjectType.workoutType(), HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!]
        let typesToRead: Set = [HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if !success {
                print("Authorization failed: \(String(describing: error?.localizedDescription))")
            }
        }
    }

    // Calculate the rental cost based on time spent
    private func calculateRentalCost(for duration: TimeInterval) -> Double {
        let minutes = Int(duration) / 60

        if minutes >= 60 {
            return 35.0 // 1 hour or more
        } else if minutes >= 30 {
            return 20.0 // 30 minutes or more but less than 1 hour
        } else {
            return 5.0  // Less than 30 minutes
        }
    }

    // Show an alert with the rental cost and time
    private func showRentalAlert(with duration: TimeInterval, cost: Double) {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60

        let alert = UIAlertController(title: "Rental Summary",
                                      message: "Duration: \(minutes) minutes \(seconds) seconds\nCost: \(cost) Baht",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // Stop the timer and clear the notification when the view is dismissed
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        healthTimer?.invalidate()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
