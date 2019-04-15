//
//  RiderViewController.swift
//  Uber
//
//  Created by Ricardo Hui on 15/4/2019.
//  Copyright © 2019 Ricardo Hui. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase
class RiderViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var map: MKMapView!
    // README: need to import MapKit
    
    @IBOutlet var callAnUberButton: UIButton!
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var uberHasBeenCalled  = false
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        // README: basic set up for location
        // Do any additional setup after loading the view.
        
        if let email = Auth.auth().currentUser?.email{
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                self.callAnUberButton.setTitle("Cancel Uber", for: .normal)
                Database.database().reference().child("RideRequests").removeAllObservers()
            }
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            userLocation = center
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            map.setRegion(region, animated: true)
            map.removeAnnotations(map.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "Your location"
            map.addAnnotation(annotation)
        }
    }
    
    
    @IBAction func callUberTapped(_ sender: Any) {
        if let email = Auth.auth().currentUser?.email{
            if uberHasBeenCalled{
                uberHasBeenCalled = false
                callAnUberButton.setTitle("Call an Uber", for: .normal)
                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                    snapshot.ref.removeValue()
                    Database.database().reference().child("RideRequests").removeAllObservers()
                }
            }else{
                
                let riderRequestDictionary: [String: Any] = ["email":email, "lat": userLocation.latitude, "lon":userLocation.longitude]
                Database.database().reference().child("RideRequests").childByAutoId().setValue(riderRequestDictionary)
                uberHasBeenCalled = true
                callAnUberButton.setTitle("Cancel Uber", for: .normal)
                
            }
            
        }
    }
    @IBAction func logoutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
        
        
    }
    
}
