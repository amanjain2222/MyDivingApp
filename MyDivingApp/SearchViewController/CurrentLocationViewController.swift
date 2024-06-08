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


class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate, DatabaseListener, UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        previousSearchedlocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! searchedLocationTableViewCell
        let location = previousSearchedlocations[indexPath.row]
        cell.locationName.text = location.location
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = previousSearchedlocations[indexPath.row]
        delegate?.UpdateCurrentLocation(location.location)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let divelocation = previousSearchedlocations[indexPath.row]
//            divelocation.location = previousSearchedlocations[indexPath.row]
            databaseController?.deleteLocation(location: divelocation)
        
        
        }
        
    }
    
    
    var listenerType: ListenerType = .diveLocations
    
    func onAuthenticationChange(ifSucessful: Bool) {
        
    }
    
    func onAllLogsChange(change: DatabaseChange, logs: [diveLogs]) {
        
    }
    
    func onUserLogsChange(change: DatabaseChange, logs: [diveLogs]) {
        
    }
    
    func onChatChange(change: DatabaseChange, userChannels: [Channel]) {
        
    }
    
    func onLocationChange(change: DatabaseChange, locations: [DiveLocations]) {
//        var divelocations: [String] = []
//        for location in locations{
//            divelocations.append(location.location!)
//        }
        previousSearchedlocations = locations
        recentLocationsTableView.reloadData()
        
        
    }
    
    func onLogsChange(change: DatabaseChange, logs: [Logs]) {
        
    }
    
    var previousSearchedlocations: [DiveLocations] = []
//
//    var latitude: Double?
//    var longitude: Double?
//    
//    
//    var latitudinalMeters: CLLocationDistance = 50000
//    var longitudinalMeters: CLLocationDistance = 50000
    
    
//    var locationManager: CLLocationManager = CLLocationManager()
//    var currentLocation: CLLocationCoordinate2D?
    
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.coreDatabaseController
        
        
        
        
        recentLocationsTableView.delegate = self
        recentLocationsTableView.dataSource = self
//
//        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        locationManager.distanceFilter = 10
//        locationManager.delegate = self
//        
//        let authorisationStatus = locationManager.authorizationStatus 
//        
//        if authorisationStatus != .authorizedWhenInUse {
//            useCurrentLocationButton.isHidden = true
//            if authorisationStatus == .notDetermined {
//                locationManager.requestWhenInUseAuthorization()
//            }
//        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //locationManager.startUpdatingLocation()
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //locationManager.stopUpdatingLocation()
        databaseController?.removeListener(listener: self)
    }
    
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        if manager.authorizationStatus == .authorizedWhenInUse {
//            useCurrentLocationButton.isHidden = false
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        currentLocation = locations.last?.coordinate
//    }
    
    weak var delegate: UpdateLoctionDelegate?
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
//    @IBOutlet weak var useCurrentLocationButton: UIButton!
//    
    
//    @IBAction func useCurrentLocation(_ sender: Any) {
//        
//        if let currentLocation = currentLocation { 
//            latitude = currentLocation.latitude
//            longitude = currentLocation.longitude
//            
//            
//            let region = MKCoordinateRegion(center: currentLocation, latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
//            
//            let corners = getCorners(of: region)
//            print(latitude,longitude,region.span.latitudeDelta,region.span.longitudeDelta)
//            print(corners.northEast, corners.northWest, corners.southEast, corners.southWest)
//        }
//        else {
//            print("error fetching current location")
//        }
//    }
//    
//    func getCorners(of region: MKCoordinateRegion) -> (northWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D, southWest: CLLocationCoordinate2D, southEast: CLLocationCoordinate2D) {
//        let center = region.center
//        let latitudinalMeters = region.span.latitudeDelta
//        let longitudinalMeters = region.span.longitudeDelta
//
//        let northWest = CLLocationCoordinate2D(latitude: center.latitude + latitudinalMeters, longitude: center.longitude - longitudinalMeters)
//        let northEast = CLLocationCoordinate2D(latitude: center.latitude + latitudinalMeters, longitude: center.longitude + longitudinalMeters)
//        let southWest = CLLocationCoordinate2D(latitude: center.latitude - latitudinalMeters, longitude: center.longitude - longitudinalMeters)
//        let southEast = CLLocationCoordinate2D(latitude: center.latitude - latitudinalMeters, longitude: center.longitude + longitudinalMeters)
//
//        return (northWest, northEast, southWest, southEast)
//    }
//    
    @IBOutlet weak var CurrentLocation: UITextField!
    
    @IBAction func CloseButton(_ sender: Any) {
        delegate?.UpdateCurrentLocation(CurrentLocation.text)
        dismiss(animated: true)
    }
    
    
    @IBOutlet weak var recentLocationsTableView: UITableView!
    
    
    
    
}
