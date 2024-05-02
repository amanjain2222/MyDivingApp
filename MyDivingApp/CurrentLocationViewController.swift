//
//  CurrentLocationViewController.swift
//  MyDivingApp
//
//  Created by aman on 28/4/2024.
//

import UIKit

import MapKit

protocol UpdateLoctionDelegate: AnyObject
{
    func UpdateCurrentLocation(_ Location: String?)
}


class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    var latitude: Double?
    var longitude: Double?
    
    weak var locationDelegate: NewLocationDelegate?
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        
        let authorisationStatus = locationManager.authorizationStatus 
        
        if authorisationStatus != .authorizedWhenInUse {
            useCurrentLocationButton.isHidden = true
            if authorisationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            useCurrentLocationButton.isHidden = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last?.coordinate
    }
    
    weak var delegate: UpdateLoctionDelegate?
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBOutlet weak var useCurrentLocationButton: UIButton!
    
    
    @IBAction func useCurrentLocation(_ sender: Any) {
        
        if let currentLocation = currentLocation { 
            latitude = currentLocation.latitude
            longitude = currentLocation.longitude
            
            print(latitude,longitude)
        }
        else {
            print("error fetching current location")
        }
    }
    
    @IBOutlet weak var CurrentLocation: UITextField!
    
    @IBAction func CloseButton(_ sender: Any) {
        delegate?.UpdateCurrentLocation(CurrentLocation.text)
        dismiss(animated: true)
    }
}
