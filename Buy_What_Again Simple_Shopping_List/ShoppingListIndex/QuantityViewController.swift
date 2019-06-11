//
//  QuantityViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 7/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces

class QuantityViewController: UIViewController, DatabaseListener, GMSAutocompleteViewControllerDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var unitSegment: UISegmentedControl!
    @IBOutlet weak var shopPicker: UIPickerView!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    var autocompleteViewController = GMSAutocompleteViewController()
    let fields = GMSPlaceField(rawValue: UInt(GMSPlaceField.formattedAddress.rawValue) | UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue) | UInt(GMSPlaceField.name.rawValue))
    var locationManager: CLLocationManager = CLLocationManager()
    var places: [GMSPlace] = []
    var currentLocation: CLLocationCoordinate2D?
    var annotations: [LocationAnnotation] = []
    var placesClient = GMSPlacesClient()
    var placeID: String?
    
    var shoppingList: ShoppingList?
    var item: Item?

    
    
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        autocompleteViewController.delegate = self as! GMSAutocompleteViewControllerDelegate
        autocompleteViewController.placeFields = self.fields!
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.distanceFilter = 10
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        
        self.mapView.showsUserLocation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        locationManager.stopUpdatingLocation()
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.addressTextView.text = "Address: " + place.formattedAddress!
        if (self.placeID != place.placeID) {
            self.placeID = place.placeID
            self.places = [place]
            self.updateMap(neariest: false)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //let location = locations.last!
        //currentLocation = location.coordinate
        
        //var newLocation = LocationAnnotation(newTitle: "Your Location", newSubtitle: "You are here", lat: currentLocation!.latitude, long: currentLocation!.longitude)
        //self.focusOn(annotation: newLocation)
        //self.mapView.addAnnotation(newLocation)

    }
    
    var listenerType = ListenerType.grocery
    
    func onShoppingListChange(change: DatabaseChange, shoppList: [ShoppingList]) {
        //not used
    }
    
    func onGroceriesListChange(change: DatabaseChange, groceriesList: [Grocery]) {
        //not used
    }
    
    func onItemListChange(change: DatabaseChange, itemList: [Item]) {
        //not used
    }
    
    @IBAction func onSearchNearShop(_ sender: Any) {
    }
    
    @IBAction func onSearchLocation(_ sender: Any) {
        self.present(self.autocompleteViewController, animated: true, completion: nil)
    }
    
    @IBAction func onAddGrocery(_ sender: Any) {
        let quantity = Float(self.quantityTextField.text!)
        if quantity != nil && quantity != 0{
            let _ = databaseController?.addGroceryToList(list: shoppingList!, quantity: quantity!, unit: unitSegment.titleForSegment(at: unitSegment.selectedSegmentIndex)!, item: item!)
            databaseController!.saveContext()
            
            navigationController?.popViewController(animated: true)
        }
        else {
            displayMessage(title: "Error", message: "Invalid quantity!")
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func updateMap(neariest: Bool) {
        
        if (mapView.annotations.count > 0) {
            mapView.removeAnnotations(mapView.annotations)
            self.annotations = []
        }
        for place in self.places {
            let location = place.coordinate
            let annotation = LocationAnnotation(newTitle: place.name ?? "your shop", newSubtitle: "", lat: location.latitude, long: location.longitude)
            self.annotations.append(annotation)
        }
        self.mapView.addAnnotations(self.annotations)
        if neariest, let _ = self.currentLocation {
            //TODO - focus on user location instead
        }
        else {
            self.focusOn(annotation: self.annotations[0])
        }
        
        
        
    }
    
    private func focusOn(annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    

}
