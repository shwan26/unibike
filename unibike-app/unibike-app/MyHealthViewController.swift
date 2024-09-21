//
//  MyHealthViewController.swift
//  uni-bike
//
//  Created by Giyu Tomioka on 9/21/24.
//

import UIKit
import HealthKit

class MyHealthViewController: UIViewController {

    @IBOutlet weak var calorieBurnLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    
    let healthStore = HKHealthStore()
    var isTracking = false
    var calorieBurned: Double = 0.0
    var timer: Timer?
    var workoutStartDate: Date?
    var activeEnergyUnit = HKUnit.kilocalorie()
    var duration: TimeInterval = 0
    var userWeight: Double = 70.0 // Default

    override func viewDidLoad() {
        super.viewDidLoad()
        requestHealthKitAuthorization()
        fetchUserWeight()
        updateUI()
    }

    @IBAction func startStopButtonTapped() {
        if isTracking {
            stopTracking()
        } else {
            startTracking()
        }
        updateUI()
    }
       

    private func updateUI() {
        if isTracking {
            startStopButton.setTitle("Stop Today", for: .normal)
        } else {
            startStopButton.setTitle("Start Today", for: .normal)
        }
        calorieBurnLabel.text = "\(Int(calorieBurned)) kcal"
        durationLabel.text = formatTime(duration)
    }

    private func startTracking() {
        isTracking = true
        calorieBurned = 0.0
        workoutStartDate = Date()
        startTimer()
    }

    private func stopTracking() {
        isTracking = false
        timer?.invalidate()
        timer = nil
        saveCyclingWorkout()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCaloriesAndDuration), userInfo: nil, repeats: true)
    }

    @objc private func updateCaloriesAndDuration() {
        if let start = workoutStartDate {
            duration = Date().timeIntervalSince(start)
        }
        calculateCaloriesBurned() // Simulate calorie burn per second
        updateUI()
    }
    
    // Calculate calories burned based on user's weight and time spent cycling
    private func calculateCaloriesBurned() {
        let caloriesPerSecondPerKg = 0.0023 // Moderate cycling: kcal burned per kg per second
        let seconds = duration // Duration is in seconds
        calorieBurned = userWeight * caloriesPerSecondPerKg * seconds
    }

    private func requestHealthKitAuthorization() {
        let typesToShare: Set = [HKObjectType.workoutType(), HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!]
        let typesToRead: Set = [HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if !success {
                print("Authorization failed: \(String(describing: error?.localizedDescription))")
            }
        }
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

    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
