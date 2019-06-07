//
//  MapViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 6/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GooglePlaces

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationTextField: UITextField!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var text: String?
    var placesClient = GMSPlacesClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.distanceFilter = 10
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()

        // Do any additional setup after loading the view.
        
        mapView.showsUserLocation = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //let location = locations.last!
        //currentLocation = location.coordinate
        
        //var newLocation = LocationAnnotation(newTitle: "Your Location", newSubtitle: "You are here", lat: currentLocation!.latitude, long: currentLocation!.longitude)
        //self.focusOn(annotation: newLocation)
        //self.mapView.addAnnotation(newLocation)
        
        if let text = text {
            let fields = GMSPlaceField(rawValue: UInt(GMSPlaceField.coordinate.rawValue))!
            placesClient.fetchPlace(fromPlaceID: text, placeFields: fields, sessionToken: nil, callback: {(place: GMSPlace?, error: Error?) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                if let place = place {
                    var newLocation = LocationAnnotation(newTitle: "Shop", newSubtitle: "yourShop", lat: place.coordinate.latitude, long: place.coordinate.longitude)
                    self.focusOn(annotation: newLocation)
                    self.mapView.addAnnotation(newLocation)
                }
            })
        }
    }
    
    @IBAction func showMe(_ sender: Any) {
        
        
        
        if let currentLocation = currentLocation {
            var newLocation = LocationAnnotation(newTitle: "Your Location", newSubtitle: "You are here", lat: currentLocation.latitude, long: currentLocation.longitude)
            self.mapView.addAnnotation(newLocation)
            self.focusOn(annotation: newLocation as MKAnnotation)
        }
    }
    
    func focusOn(annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
        }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
