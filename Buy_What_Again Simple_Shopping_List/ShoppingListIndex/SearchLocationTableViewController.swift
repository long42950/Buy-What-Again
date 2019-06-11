//
//  SearchLocationTableViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 27/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import UIKit
import GooglePlaces

class SearchLocationTableViewController: UITableViewController, UISearchBarDelegate {
    
    let CELL_NAME = "locationCell"
    
    var indicator = UIActivityIndicatorView()
    var addresses = [String]()
    
    var placesClient = GMSPlacesClient()
    private let token = GMSAutocompleteSessionToken.init()
    let filter = GMSAutocompleteFilter()

    override func viewDidLoad() {
        super.viewDidLoad()

        let searchController = UISearchController(searchResultsController: nil);
        searchController.searchBar.delegate = self as! UISearchBarDelegate
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find your shop"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
        
        indicator.style = UIActivityIndicatorView.Style.gray
        indicator.center = self.tableView.center
        self.view.addSubview(indicator)
        
        let _ = UIApplication.shared.delegate as! AppDelegate
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.count > 0 else {
            return;
        }
        
        //indicator.startAnimating()
        //indicator.backgroundColor = UIColor.white
        
            //https://maps.googleapis.com/maps/api/place/details/json?key=AIzaSyClbus3OOrycPW8bHq-7BUwbUK6uTYdjFc&placeid=ChIJOZG7315OqEcRVs8ZP5sx0mQ
            //https://maps.googleapis.com/maps/api/place/findplacefromtext/json?key=AIzaSyClbus3OOrycPW8bHq-7BUwbUK6uTYdjFc&input=McDonald%2C%2079%20Blackburn%20Road%2C%20Doncaster%20East&inputtype=textquery
        //[0]    String    "ChIJOZG7315OqEcRVs8ZP5sx0mQ"
        //TODO - auto query places address
        placesClient.findAutocompletePredictions(fromQuery: searchText, bounds: nil, boundsMode: GMSAutocompleteBoundsMode.bias, filter: filter, sessionToken: token, callback: {(results, error) in
            if let error = error {
                print("Autocomplete error: \(error)")
                return
            }
            if let results = results {
                self.addresses = []
                for result in results {
                    self.addresses.append(result.placeID)
                }
            }
            
        })
        
        self.tableView.reloadData()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return addresses.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue))!

        //TODO - fill in text label with address from address array
        let address = addresses[indexPath.row]
        placesClient.fetchPlace(fromPlaceID: address, placeFields: fields, sessionToken: nil, callback: {(place: GMSPlace?, error: Error?) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            if let place = place {
                cell.textLabel?.text = place.name
                //print(place)
            }
        })

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO - show location on map
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewLocationSegue" {
            let destination = segue.destination as! MapViewController
            let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.coordinate.rawValue))!
            
            //TODO - fill in text label with address from address array
            destination.text = addresses[tableView.indexPathForSelectedRow!.row]
            

        }
    }
 
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
