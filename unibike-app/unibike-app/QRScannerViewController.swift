//
//  QRScannerViewController.swift
//  unibike-app
//
//  Created by Giyu Tomioka on 9/21/24.
//

import UIKit
import AVFoundation
import CoreImage

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var bikeIdTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!

        override func viewDidLoad() {
            super.viewDidLoad()
            setupCamera()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            // Restart capture session when the view appears
            if captureSession?.isRunning == false {
                captureSession.startRunning()
            }
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            // Stop capture session when the view disappears
            if captureSession?.isRunning == true {
                captureSession.stopRunning()
            }
        }

        func setupCamera() {
            captureSession = AVCaptureSession()
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                failed()
                return
            }
            
            let videoInput: AVCaptureDeviceInput
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                failed()
                return
            }

            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                failed()
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            } else {
                failed()
                return
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = cameraView.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            cameraView.layer.addSublayer(previewLayer)

            captureSession.startRunning()
        }

        func failed() {
            let alert = UIAlertController(title: "Camera Error", message: "Your device does not support scanning a code from the camera. Would you like to select an image from your photo library instead?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.captureSession = nil
            }))
            
            alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { action in
                self.presentImagePicker()
            }))
            
            present(alert, animated: true)
            captureSession = nil
        }

        // QR Code detection
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            captureSession.stopRunning()

            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject, let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                bikeScanned(bikeId: stringValue)
            }
        }

        // Function to handle scanned bike ID
        func bikeScanned(bikeId: String) {
            print("Bike ID Scanned: \(bikeId)")
            performSegue(withIdentifier: "startRentingBike", sender: bikeId)
        }

        // Manual input submit action
        @IBAction func submitBikeId(_ sender: UIButton) {
            if let bikeId = bikeIdTextField?.text, !bikeId.isEmpty {
                print("Bike ID entered: \(bikeId)")
                performSegue(withIdentifier: "startRentingBike", sender: bikeId)
            } else {
                print("No bike ID entered. Continuing the flow...")
            }
        }

        // Present the image picker
        @IBAction func presentImagePicker() {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                present(imagePicker, animated: true)
            }
        }

        // Handle the picked image
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true, completion: nil)
            
            if let image = info[.originalImage] as? UIImage {
                detectQRCode(in: image)
            }
        }

        // Detect QR code from the selected image
        func detectQRCode(in image: UIImage) {
            guard let ciImage = CIImage(image: image) else { return }
            
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            
            if let features = detector?.features(in: ciImage) as? [CIQRCodeFeature] {
                for feature in features {
                    if let qrCode = feature.messageString {
                        print("QR Code from image: \(qrCode)")
                        bikeScanned(bikeId: qrCode)
                        return
                    }
                }
                print("No QR code found in the image")
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }

        // Pass the bike ID to the next ViewController
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "startRentingBike" {
                if let nextVC = segue.destination as? BikeRentingViewController, let bikeId = sender as? String {
                    nextVC.bikeId = bikeId
                }
            }
        }
    }
