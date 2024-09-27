//
//  DetailsViewController.swift
//  unibike-app
//
//  Created by Naw Tulip on 27/9/2567 BE.
//

import UIKit

class DetailsViewController: UIViewController {
    
    // MARK: - Outlets for UI Elements
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField! // Phone number text field

    // MARK: - View Lifecycle
    override func viewDidLoad() {
           super.viewDidLoad()
           
           // Load existing data when the view loads
           loadUserData()
       }
       
       // MARK: - Load User Data
       func loadUserData() {
           // Retrieve data from UserDefaults
           firstNameTextField.text = UserDefaults.standard.string(forKey: "firstName")
           lastNameTextField.text = UserDefaults.standard.string(forKey: "lastName")
           emailTextField.text = UserDefaults.standard.string(forKey: "email")
           phoneNumberTextField.text = UserDefaults.standard.string(forKey: "phoneNumber")
       }
       
       // MARK: - Save User Data
       func saveUserData(firstName: String, lastName: String, email: String, phoneNumber: String) {
           // Save the data to UserDefaults
           UserDefaults.standard.set(firstName, forKey: "firstName")
           UserDefaults.standard.set(lastName, forKey: "lastName")
           UserDefaults.standard.set(email, forKey: "email")
           UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
           
           // Show success message
           let alert = UIAlertController(title: "Success", message: "Details successfully updated", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(alert, animated: true, completion: nil)
       }

       // MARK: - Actions
       @IBAction func updateButtonTapped(_ sender: UIButton) {
           // Basic input validation
           if let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty {
               
               // Save the data
               saveUserData(firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber)
           } else {
               // Show error message if any field is empty
               let alert = UIAlertController(title: "Error", message: "All fields must be filled in", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               present(alert, animated: true, completion: nil)
           }
       }
   }
