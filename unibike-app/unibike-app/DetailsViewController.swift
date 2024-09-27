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
    }
    
    // MARK: - Actions
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        // Basic input validation
                if let firstName = firstNameTextField.text, !firstName.isEmpty,
                   let lastName = lastNameTextField.text, !lastName.isEmpty,
                   let email = emailTextField.text, !email.isEmpty,
                   let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty {
                    
                    // Here you can perform any update operation you need, e.g., saving the data
                    
                    let alert = UIAlertController(title: "Success", message: "Successfully updated", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Error", message: "All fields must be filled in", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
            }
        }
