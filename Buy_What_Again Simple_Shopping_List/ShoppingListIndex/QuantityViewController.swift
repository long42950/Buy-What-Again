//
//  QuantityViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 7/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

//Copyright 2019 Google
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

import UIKit
import MapKit
import GooglePlaces

class QuantityViewController: UIViewController, DatabaseListener, GMSAutocompleteViewControllerDelegate, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    
    
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
    var address: String?
    
    var shoppingList: ShoppingList?
    var item: Item?
    var shopList: [Shop] = []
    
    var isEdit: Bool = false
    var currentGrocery: Grocery?

    
    
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
        
        self.shopPicker.delegate = self
        self.shopPicker.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        locationManager.startUpdatingLocation()
        
        //Fill the details of a Grocery when the user wants to view or edit the Grocery
        if let grocery = self.currentGrocery {
            self.navigationItem.title = grocery.name
            self.quantityTextField.text = "\(grocery.quantity)"
            if grocery.unit == "Kg" {
                self.unitSegment.selectedSegmentIndex = 0
            }
            else {
                self.unitSegment.selectedSegmentIndex = 1
            }
            self.addressTextView.text = "Address: "
            if let address = grocery.shopAddress, let placeId = grocery.shopPlaceId {
                self.placeID = placeId
                self.addressTextView.text = "Address: \(address)"
                self.updateMap(neariest: true)
            }
            
            if let shop = grocery.shops {
                for row in 0..<self.shopList.count {
                    if shop.name == self.shopList[row].name {
                        self.shopPicker.selectRow(row+1, inComponent: 0, animated: true)
                    }
                }
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        locationManager.stopUpdatingLocation()
    }
    
    //Record the details of a user selected location
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.addressTextView.text = "Address: " + place.formattedAddress!
        if (self.placeID != place.placeID) {
            self.placeID = place.placeID
            self.places = [place]
            self.address = place.formattedAddress!
            self.updateMap(neariest: false)
        }
        dismiss(animated: true, completion: nil)
    }
    
    //display error when occur
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        self.displayMessage(title: "ERROR", message: error.localizedDescription)
    }
    
    //dismiss the UI control from Google's place autocomplete
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //not used
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.shopList.count + 1
    }
    
    //Fill the UIPicker with shops from the Shop list
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row == 0 ? "Select A Shop" : self.shopList[row - 1].name
    }
    
    var listenerType = ListenerType.shop
    
    func onShoppingListChange(change: DatabaseChange, shoppList: [ShoppingList]) {
        //not used
    }
    
    func onGroceriesListChange(change: DatabaseChange, groceriesList: [Grocery]) {
        //not used
    }
    
    func onItemListChange(change: DatabaseChange, itemList: [Item]) {
        //not used
    }
    
    //Fetch the Shop list from CoreData
    func onShopListChange(change: DatabaseChange, shopList: [Shop]) {
        self.shopList = shopList
        
    }
    
    func onKeyChange(change: DatabaseChange, key: [BackupKey]) {
        //not used
    }
    
    //Search the neariest shop away from the user, the user must first select a preferred shop
    @IBAction func onSearchNearShop(_ sender: Any) {
        var fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.formattedAddress.rawValue))!
        //Locate the user
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
            (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList[0].place
                let selectedRow = self.shopPicker.selectedRow(inComponent: 0)
                if selectedRow == 0 {
                    DispatchQueue.main.async {
                        self.displayMessage(title: "Warning", message: "You have not select a preferred shop!")
                    }
                    return
                }
                //Complete the url for fetching nearby shop
                var searchString = "\(self.shopList[selectedRow-1].name!), \(place.formattedAddress!)"
                searchString = searchString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                searchString = searchString.replacingOccurrences(of: ",", with: "%2C", options: .literal, range: .none)
                searchString = searchString.replacingOccurrences(of: "&", with: "%26", options: .literal, range: .none)
                let jsonString = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?key=AIzaSyClbus3OOrycPW8bHq-7BUwbUK6uTYdjFc&input=\(searchString)&inputtype=textquery"
                print(jsonString)
                let jsonURL = URL(string: jsonString)
                let request = URLRequest(url: jsonURL!)
                let task = URLSession.shared.dataTask(with: request) {
                    (data, response, error) in
                    
                    if let error = error {
                        self.displayMessage(title: "Error", message: error.localizedDescription)
                        return
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        print("\(data!)")
                        let candidateData = try decoder.decode(CandidateData.self, from: data!)
                        if candidateData.status! == "ZERO_RESULTS" {
                            DispatchQueue.main.async {
                                self.displayMessage(title: "Sorry", message: "What you're looking for doesn't exist near your location.")
                            }
                            
                        }
                        //If at least one location returned, record the first location's details
                        if let placeIDs = candidateData.placeIDs {
                            if placeIDs.count > 0 {
                                self.placeID = placeIDs[0].placeID
                            }
                        } else {
                            self.placeID = nil
                        }
                        self.updateMap(neariest: true)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
                task.resume()
            }
        })
    }
    
    //Present the Google's auto complete's UI control
    @IBAction func onSearchLocation(_ sender: Any) {
        self.present(self.autocompleteViewController, animated: true, completion: nil)
    }
    
    //Add or edit a grocery to the list, a quantity is needed and bought grocery cannot be modified
    @IBAction func onAddGrocery(_ sender: Any) {
        let quantity = Float(self.quantityTextField.text!)
        let selectedRow = self.shopPicker.selectedRow(inComponent: 0)
        var shop: Shop?
        if selectedRow != 0 {
            shop = self.shopList[selectedRow-1]
        }
        if quantity != nil && quantity != 0 {
            
            if let grocery = self.currentGrocery {
                if grocery.isBought {
                    DispatchQueue.main.async {
                        self.displayMessage(title: "Error", message: "You cannot edit bought grocery!")
                    }
                    return
                    
                }
                let name = self.navigationItem.title!
                let unit = self.unitSegment.titleForSegment(at: unitSegment.selectedSegmentIndex)!
                let shopPlaceId = self.placeID
                let shopAddress = self.address
                let _ = databaseController?.editGrocery(name: name, quantity: quantity!, unit: unit, shopPlaceId: shopPlaceId, shopAddress: shopAddress, preferShop: shop, grocery: grocery)
                databaseController!.saveContext()
                
                navigationController?.popViewController(animated: true)
                return
            }
            let _ = databaseController?.addGroceryToList(list: shoppingList!, quantity: quantity!, unit: unitSegment.titleForSegment(at: unitSegment.selectedSegmentIndex)!, item: item!, shopPlaceId: self.placeID, shopAddress: self.address , preferShop: shop)
            databaseController!.saveContext()
            
            navigationController?.popViewController(animated: true)
        }
        else {
            displayMessage(title: "Error", message: "Invalid quantity!")
        }
        
    }
    
    //Show user a message with the alert message box
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //When an address is recorded from the user's action, focus the map to the address with basic details
    private func updateMap(neariest: Bool) {
        if (mapView.annotations.count > 0) {
            mapView.removeAnnotations(mapView.annotations)
            self.annotations = []
        }
        
        if neariest {
            if let placeID = self.placeID {
                let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.coordinate.rawValue) | UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.formattedAddress.rawValue))!
                placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil, callback: {
                    (place, error) in
                    if let place = place {
                        self.addressTextView.text = "Address: \(place.formattedAddress!)"
                        self.address = place.formattedAddress
                        let annotation = LocationAnnotation(newTitle: place.name ?? "neariest shop", newSubtitle: "", lat: place.coordinate.latitude, long: place.coordinate.longitude)
                        self.annotations.append(annotation)
                        self.mapView.addAnnotations(self.annotations)
                        
                        self.focusOn(annotation: self.annotations[0])
                    }
                    
                    if let error = error {
                        print("\(error.localizedDescription)")
                        return
                    }
                })
                
            }
        } else {
            for place in self.places {
                let location = place.coordinate
                let annotation = LocationAnnotation(newTitle: place.name ?? "your shop", newSubtitle: "", lat: location.latitude, long: location.longitude)
                self.annotations.append(annotation)
                self.mapView.addAnnotations(self.annotations)
                
                self.focusOn(annotation: self.annotations[0])
            }
        }
        
        
        
        
    }
    
    //Auto-zoom into a location
    private func focusOn(annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    

}
