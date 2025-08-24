//
//  NotesViewController.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 25/07/2021.
//

import Foundation
import UIKit
import RealmSwift
import Firebase

class NotesViewController: DocumentTableViewController {
    
    @IBOutlet weak var documentTableView: UITableView!
    
    let realm = try! Realm()
    
    var documentArray : Results<DocumentObject>?
    var wordArray : Results<WordObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDocument()
        
        documentTableView.dataSource = self
        documentTableView.delegate = self
        
        documentTableView.register(UINib(nibName: "DocumentTableViewCell", bundle: nil), forCellReuseIdentifier: "DocumentReusableCell")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        documentTableView.reloadData()
    }
    
    func loadDocument(){
        documentArray = realm.objects(DocumentObject.self).sorted(byKeyPath: "date", ascending: true)
        documentTableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if documentArray?.count == 0 {
            return 1
        } else {
            return documentArray!.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentReusableCell", for: indexPath) as! DocumentTableViewCell
        cell.delegate = self
        cell.index = indexPath.row
        cell.view2B.layer.cornerRadius = 20
        cell.view2B.layer.masksToBounds = true
        if documentArray?.count == 0 {
            cell.title.text = "No Documments Found."
            cell.date.text = ""
            cell.numberOfWord.text = ""
            cell.flashCardButton.isHidden = true
            
        } else {
            let document = documentArray?[indexPath.row]
            cell.title.text = document?.title
            cell.date.text = document?.date
            wordArray = document?.wordList.sorted(byKeyPath: "vocab", ascending: true)
            if let wordCount = wordArray?.count {
                if wordCount > 1{
                    cell.numberOfWord.text = "\(wordCount) words"
                } else {
                    cell.numberOfWord.text = "\(wordCount) word"
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if documentArray?.count == 0{
            let alert = UIAlertController(title: "Create Document", message: "Document will be created automatically once you search a word or start reading.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            documentTableView.deselectRow(at: indexPath, animated: true)
        } else {
            performSegue(withIdentifier: "goToList", sender: self)
            documentTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToList"{
            let destinationVC  = segue.destination as! ListViewController
            
            if let indexPath = documentTableView.indexPathForSelectedRow {
                destinationVC.selectedDocument = documentArray?[indexPath.row]
            }
        }
        
        if segue.identifier == "goToFlashCard" {
            let destinationVC  = segue.destination as! FlashCardViewController
            destinationVC.wordArray = wordArray
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            do {
                try realm.write{
                    if let deleteDocument = documentArray?[indexPath.row]{
                        realm.delete(deleteDocument.wordList)
                        realm.delete(deleteDocument)
                        documentTableView.reloadData()
                    }
                }
            } catch {
                print("Error deleting document\(error)")
            }
        }
    }
    
    func loadWord(index:Int){
        wordArray = documentArray?[index].wordList.sorted(byKeyPath: "vocab", ascending: true)
    }


}

extension NotesViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        documentArray = documentArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "date", ascending: false)
        documentTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadDocument()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        loadDocument()
        searchBar.text = ""
    }
    
}

extension NotesViewController: GoToFlashCardDelegate{
    
    func goToFlashCard(indexPath:Int) {
        Analytics.logEvent("FlashCardTapped", parameters: nil)
        if wordArray?.count == 0 || wordArray == nil{
            return
        } 
        loadWord(index: indexPath)
        performSegue(withIdentifier: "goToFlashCard", sender: self)
    }
    
}


