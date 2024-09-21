//
//  ViewController.swift
//  unibike-app
//
//  Created by Giyu Tomioka on 9/21/24.


import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()

    var hasCenteredOnUser = false // To track if the map has already centered on the user

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up MapView delegate
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        // Request location permission
        setupLocationServices()
        
        // Center on Assumption University
        let assumptionUniversityLocation = CLLocationCoordinate2D(latitude: 13.6116, longitude: 100.8379)
        let region = MKCoordinateRegion(center: assumptionUniversityLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load stations and add annotations to map
        if let stations = loadStationsFromJSON() {
            addStationsToMap(stations: stations)
        }
    }
    
    func setupLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Request location authorization
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Prompt the user to enable location services in settings
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services in Settings to use this feature.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            print("User location is nil")
            return
        }
        
        if !hasCenteredOnUser {
            let userLocation = location.coordinate
            let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            hasCenteredOnUser = true
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            // Show an alert when location is denied
            let alert = UIAlertController(title: "Location Access Denied", message: "Please enable location permissions in Settings.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

        
        // Handle errors
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to find user's location: \(error.localizedDescription)")
        }

     
        
        // Add stations to the map
        func addStationsToMap(stations: [Station]) {
            for station in stations {
                let annotation = MKPointAnnotation()
                annotation.title = station.name
                annotation.subtitle = "Bikes available: \(station.bike)" // Show the number of bikes in the callout
                annotation.coordinate = CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude)
                mapView.addAnnotation(annotation)
            }
        }
        
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil // Use default blue dot for user location
        }
        
        let identifier = "StationAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            // SF Symbol for bicycle
            let bikeIcon = UIImage(systemName: "bicycle.circle.fill")
            annotationView?.image = bikeIcon
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }

    
    
    }

