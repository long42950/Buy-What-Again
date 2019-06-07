//
//  SearchViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 28/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import UIKit
import GooglePlaces

class SearchViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // Present the Autocomplete view controller when the textField is tapped.
    @IBAction func textFieldTapped(_ sender: Any) {
        textField.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self as! GMSAutocompleteViewControllerDelegate
        present(acController, animated: true, completion: nil)
    }
    
}

extension SearchViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Get the place name from 'GMSAutocompleteViewController'
        // Then display the name in textField
        print(place.name)
        textField.text = place.name
        // Dismiss the GMSAutocompleteViewController when something is selected
        dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Handle the error
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Dismiss when the user canceled the action
        dismiss(animated: true, completion: nil)
    }
    
}
