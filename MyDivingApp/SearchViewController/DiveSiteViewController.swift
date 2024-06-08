//
//  DiveSiteViewController.swift
//  MyDivingApp
//
//  Created by aman on 25/4/2024.
//

import UIKit
import MapKit

/*
 This view controller is responsable for viewing the map view for the selected location.
 */

class DiveSiteViewController: UIViewController {
    
    var currentSite: DiveSites?
    var isFirstViewApperance = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = currentSite?.name
        
        ocean.text = "Ocean: " + (currentSite?.ocean)!
        ocean.allowsEditingTextAttributes = false
        ocean.borderStyle = .none
        
        guard let latitude = Double((currentSite?.latitude)!) else {return}
        guard let longitude = Double((currentSite?.longitude)!) else {return}
        
        let mapAnnotation = LocationAnnotation(title: (currentSite?.name)!, subtitle: (currentSite?.region)!, lat: latitude , long: longitude)
        
        if isFirstViewApperance {
            self.mapView.addAnnotation(mapAnnotation)
            isFirstViewApperance = false
        }
        
        focusOn(annotation: mapAnnotation)
        
    }
    

    func focusOn(annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    
    @IBOutlet weak var ocean: UITextField!
    @IBOutlet weak var mapView: MKMapView!
 
    
}
