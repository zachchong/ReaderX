//
//  DictionaryViewController.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 25/07/2021.
//

import Foundation
import UIKit
import RealmSwift

class DictionaryViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var historyTableView: UITableView!
    
    let realm = try! Realm()
    var historyArray : Results<WordObject>?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        searchBar.becomeFirstResponder()
        historyTableView.reloadData()
        searchBar.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyTableView.dataSource = self
        historyTableView.delegate = self
        
        historyTableView.register(UINib(nibName: "WordTableViewCell", bundle: nil), forCellReuseIdentifier: "HistoryReusableCell")
        
        loadWords()

    }
    
    func loadWords() {
        historyArray = realm.objects(WordObject.self).sorted(byKeyPath: "dateCreated", ascending: false)
        historyTableView.reloadData()
    }
    
}

extension DictionaryViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.count != 0 {
            performSegue(withIdentifier: "goToResult", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is ResultViewController {
            let vc = segue.destination as? ResultViewController
            if let text = searchBar.text {
                vc?.vocabulary = text
            }
            if let indexPath = historyTableView.indexPathForSelectedRow{
                
                if let text = historyArray?[indexPath.row].vocab{
                    vc?.vocabulary = text
                }
                
            }
        }
        
    }
    
    
}

//if segue.destination is ResultViewController {
//    let vc = segue.destination as? ResultViewController
//    if let indexPath = historyTableView.indexPathForSelectedRow{
//
//        if let text = historyArray?[indexPath.row].vocab{
//            vc?.vocabulary = text
//        }
//
//    }
//}

extension DictionaryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyArray?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryReusableCell", for: indexPath) as! WordTableViewCell
        cell.en.text = historyArray?[indexPath.row].en
        cell.zh_CN.text = historyArray?[indexPath.row].zh_CN
        cell.vocab.text = historyArray?[indexPath.row].vocab
        cell.audioURL = historyArray?[indexPath.row].pronunciationURL ?? ""
        
        return cell
    }


}

extension DictionaryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToResult", sender: self)
        historyTableView.deselectRow(at: indexPath, animated: true)
    }
    
}




