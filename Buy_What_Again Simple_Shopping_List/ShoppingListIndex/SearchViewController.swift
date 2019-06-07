//
//  SearchViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 28/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import UIKit
import GooglePlaces

class SearchViewController: UISearchController {
    
    var resultsViewController: GMSAutocompleteResultsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchResultsUpdater = resultsViewController! as! UISearchResultsUpdating

        // Do any additional setup after loading the view.
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
