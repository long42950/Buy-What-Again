//
//  ListBarController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 3/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import UIKit

class ListBarController: UITabBarController {
    
    @IBOutlet weak var listTabBar: UITabBar!
    
    override func awakeFromNib() {
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        listTabBar.items![2].title = "Shopping List"
        
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
