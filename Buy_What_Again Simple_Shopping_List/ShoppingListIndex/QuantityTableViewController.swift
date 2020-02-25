//
//  QuantityTableViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Long Lee on 20/2/2020.
//  Copyright © 2020 Chak Lee. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces

class QuantityTableViewController: UITableViewController, DatabaseListener, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate, GMSAutocompleteViewControllerDelegate {
    
    
    
    
    weak var amountTextCell: UITableViewCell?
    weak var selectionCell: UITableViewCell?
    weak var pickerCell: UITableViewCell?
    weak var streetTextCell: UITableViewCell?
    weak var suburbTextCell: UITableViewCell?
    weak var stateTextCell: UITableViewCell?
    weak var postcodeTextCell: UITableViewCell?
    weak var button1Cell: UITableViewCell?
    weak var button2Cell: UITableViewCell?
    weak var mapCell: UITableViewCell?
    

    var shoppingList: ShoppingList?
    var item: Item?
    var shopList: [Shop] = []
    
    var isEdit: Bool = false
    var currentGrocery: Grocery?
    
    weak var databaseController: DatabaseProtocol?
    
    
    //Variables and Constant for Maps
    let fields = GMSPlaceField(rawValue: UInt(GMSPlaceField.formattedAddress.rawValue) | UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue) | UInt(GMSPlaceField.name.rawValue))
    var locationManager: CLLocationManager = CLLocationManager()
    var places: [GMSPlace] = []
    var currentLocation: CLLocationCoordinate2D?
    var annotations: [LocationAnnotation] = []
    var placesClient = GMSPlacesClient()
    var placeID: String?
    var address: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.distanceFilter = 10
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        databaseController?.removeListener(listener: self)
        locationManager.stopUpdatingLocation()
    }
    
    //MARK: - Google Map setup
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if (self.placeID != place.placeID) {
            self.placeID = place.placeID
            self.places = [place]
            self.address = place.formattedAddress!
            self.updateMap(neariest: false)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        self.displayMessage(title: "ERROR", message: error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard
            let coordinate: CLLocationCoordinate2D = manager.location?.coordinate
            else {
                return
    
            }
        self.foucsOn(coordinate: coordinate)
    }
    
    func searchNearByShop() {
        
        var fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.formattedAddress.rawValue))!
        
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
            (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                self.displayMessage(title: "Where are you?", message: "We cannot locate your current position. Please ensure allow location access is on for this app in Settings.")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList[0].place
                let cell = self.pickerCell as! PickerTableViewCell
                let selectedRow = cell.pickerRef.selectedRow(inComponent: 0)
                if selectedRow == 0 {
                    DispatchQueue.main.async {
                    self.displayMessage(title: "Warning", message: "You have not select a preferred shop!")
                    }
                    return
                }
                
                //Disable search button
                let bCell = self.button1Cell as! ButtonTableViewCell
                bCell.buttonRef.isEnabled = false
                
                //Reset map annotation
                if let ref = self.mapCell {
                    let mapView = ref as! MapTableViewCell
                    let map = mapView.mapRef!
                    if (map.annotations.count > 0) {
                        print(map.annotations)
                        map.removeAnnotations(map.annotations)
                        self.annotations = []
                    }
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
                        //print("\(data!)")
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
                    } catch let error {
                        print(error.localizedDescription)
                    }
                    self.updateMap(neariest: true)
                }
                task.resume()
                
                
                //Re-Enable search button
                bCell.buttonRef.isEnabled = true
            }
        })
    }
    
    //When an address is recorded from the user's action, focus the map to the address with basic details
    private func updateMap(neariest: Bool) {
        if let ref = self.mapCell {
            let mapView = ref as! MapTableViewCell
            let map = mapView.mapRef!

            if neariest {
                if let placeID = self.placeID {
                    let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.coordinate.rawValue) | UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.formattedAddress.rawValue))!
                    placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil, callback: {
                        (place, error) in
                        if let place = place {
                            self.address = place.formattedAddress
                            let annotation = LocationAnnotation(newTitle: place.name ?? "neariest shop", newSubtitle: "", lat: place.coordinate.latitude, long: place.coordinate.longitude)
                            self.annotations.append(annotation)
                            map.addAnnotations(self.annotations)

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
                    map.addAnnotations(self.annotations)

                    self.focusOn(annotation: self.annotations[0])
                }
            }
        }
    }


    //Auto-zoom into a location
    private func focusOn(annotation: MKAnnotation) {
        if let ref = self.mapCell {
            let mapView = ref as! MapTableViewCell
            let map = mapView.mapRef!
            map.selectAnnotation(annotation, animated: true)

            let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            map.setRegion(map.regionThatFits(zoomRegion), animated: true)
        }
    }
    
    private func foucsOn(coordinate: CLLocationCoordinate2D) {
        if let ref = self.mapCell {
            let mapView = ref as! MapTableViewCell
            let map = mapView.mapRef!
            let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            map.setRegion(map.regionThatFits(zoomRegion), animated: true)
        }
    }
    
    // MARK: - Picker view setup and data source
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.shopList.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row == 0 ? "Select A Shop" : self.shopList[row - 1].name
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //MARK: - Database controller setup
    
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
    
    @IBAction func onAddGrocery(_ sender: Any) {
        let amountCellRef = self.amountTextCell as! TextTableViewCell
        let selectionCellRef = self.selectionCell as! SelectionTableViewCell
        let pickerCellRef = self.pickerCell as! PickerTableViewCell
        let streetCellRef = self.streetTextCell as! TextTableViewCell
        let suburbCellRef = self.suburbTextCell as! TextTableViewCell
        let stateCellRef = self.stateTextCell as! TextTableViewCell
        let postcodeCellRef = self.postcodeTextCell as! TextTableViewCell
        
        let quantity = Float(amountCellRef.textRef.text!)
        let unit = selectionCellRef.decisionRef.text
        let selectedRow = pickerCellRef.pickerRef.selectedRow(inComponent: 0)
        var shop: Shop?
        if (selectedRow != 0) {
            shop = self.shopList[selectedRow - 1] as! Shop
        }
        
        if (quantity != nil) && (quantity != 0) {
            
            let name = self.navigationItem.title!
            let unit = selectionCellRef.decisionRef.text!
            let shopPlaceId = self.placeID
            let shopAddress = self.address
            
            //If the user is here to edit a picked grocery
            if let grocery = self.currentGrocery {
                if grocery.isBought {
                    DispatchQueue.main.async {
                        self.displayMessage(title: "Error", message: "You cannot edit bought grocery!")
                    }
                    return
                }
                
                let _ = databaseController?.editGrocery(name: name, quantity: quantity!, unit: unit, shopPlaceId: shopPlaceId, shopAddress: shopAddress, preferShop: shop, grocery: grocery)
                databaseController!.saveContext()
                
                navigationController?.popViewController(animated: true)
                return
            }
            let _ = databaseController?.addGroceryToList(list: shoppingList!, quantity: quantity!, unit: unit, item: item!, shopPlaceId: shopPlaceId, shopAddress: shopAddress, preferShop: shop)
            databaseController?.saveContext()
            
            navigationController?.popViewController(animated: true)
            
        }
        else {
            displayMessage(title: "Error", message: "You must enter a sufficient amount and must be larger than 0!")
            amountCellRef.textRef.attributedPlaceholder = NSAttributedString(string: "Amount",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemRed])
        }
    }
    

    // MARK: - Table view setup and data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 6
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var currentCell = indexPath.row
         if (indexPath.section != 0) {
             var previousCell = 0
             for section in 0...indexPath.section - 1 {
                 previousCell += self.tableView.numberOfRows(inSection: section)
             }
             currentCell += previousCell
         }
        switch currentCell {
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "selectionCell", for: indexPath) as! SelectionTableViewCell
                cell.selectionRef.text = "Unit"
                cell.decisionRef.text = "kg"
                cell.accessoryType = .disclosureIndicator
                
                self.selectionCell = cell
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell", for: indexPath) as! PickerTableViewCell
                cell.pickerRef.delegate = self
                cell.pickerRef.dataSource = self

                self.pickerCell = cell
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as! ButtonTableViewCell
                cell.buttonRef.setTitle("Search Nearby Shop", for: .normal)
                cell.quantityTableViewControllerRef(self)
            
                self.button2Cell = cell
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as! MapTableViewCell
                cell.mapRef.showsUserLocation = true
                
                self.mapCell = cell
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as! ButtonTableViewCell
                cell.buttonRef.setTitle("Find it yourself", for: .normal)
                cell.quantityTableViewControllerRef(self)
                
                self.button1Cell = cell
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! TextTableViewCell
                switch currentCell {
                    case 6:
                        cell.textRef.placeholder = "Street"
                        self.streetTextCell = cell
                    case 7:
                        cell.textRef.placeholder = "Suburb"
                        self.suburbTextCell = cell
                    case 8:
                        cell.textRef.placeholder = "State"
                        self.stateTextCell = cell
                    case 9:
                        cell.textRef.placeholder = "Postcode"
                        self.postcodeTextCell = cell
                    default:
                        cell.textRef.placeholder = "Amount"
                        self.amountTextCell = cell
                }

                return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "Quantity"
            case 1:
                return "Preferred Shop (Optional)"
            case 2:
                return "Shop Location (Optional)"
            default:
                return "Error"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        

       var currentCell = indexPath.row
        if (indexPath.section != 0) {
            var previousCell = 0
            for section in 0...indexPath.section - 1 {
                previousCell += self.tableView.numberOfRows(inSection: section)
            }
            currentCell += previousCell
        }
        
        switch currentCell {
            case 2:
                return 216
            case 4:
                return 335
            default:
                return tableView.rowHeight
        }
    }
    
    //Show user a message with the alert message box
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }


}