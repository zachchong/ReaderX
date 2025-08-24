//
//  UITabBarController.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 13/08/2021.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //tab bar
        let prominentTabBar = self.tabBar as! ProminentTabBar
            prominentTabBar.prominentButtonCallback = prominentTabTaped
        
    }
    
    func prominentTabTaped() {
        selectedIndex = (tabBar.items?.count ?? 0)/2
    }

}
