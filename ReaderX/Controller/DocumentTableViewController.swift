//
//  DocumentTableViewController.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 25/07/2021.
//

import Foundation
import UIKit

class DocumentTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentReusableCell", for: indexPath) as! DocumentTableViewCell
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToList", sender: self)
    }
    
    
}
