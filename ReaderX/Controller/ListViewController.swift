//
//  ListViewController.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 25/07/2021.
//

import Foundation
import UIKit
import RealmSwift
import Firebase

class ListViewController: UIViewController {
    
    //pdf
    
    
    //pdf

    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var wordTableView: UITableView!
    
    let realm = try! Realm()
    var wordArray : Results<WordObject>?
    var selectedDocument : DocumentObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.topItem?.title = selectedDocument?.title
        wordTableView.dataSource = self
        wordTableView.delegate = self
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ListViewController.tapped))
        navigationBar.addGestureRecognizer(recognizer)
        
        wordTableView.register(UINib(nibName: "WordTableViewCell", bundle: nil), forCellReuseIdentifier: "WordReusableCell")
        
        loadWords()
        
        //pdf

        //pdf
    
    }
    
    @objc private func tapped(){
        performSegue(withIdentifier: "popUpRename", sender: self)
    }
    
    @IBAction func backButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func pdfButtonClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToPDF", sender: self)
    }
    
    
    @IBAction func flashCardButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToFlashCard", sender: self)
    }
    
    
    @objc func clickOnButton() {
        print("titleClicked")

    }
    
    func loadWords() {
        wordArray = selectedDocument?.wordList.sorted(byKeyPath: "vocab", ascending: true)
        wordTableView.reloadData()
    }
    
}

extension ListViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordReusableCell", for: indexPath) as! WordTableViewCell
        cell.en.text = wordArray?[indexPath.row].en
        cell.zh_CN.text = wordArray?[indexPath.row].zh_CN
        cell.vocab.text = wordArray?[indexPath.row].vocab
        cell.audioURL = wordArray?[indexPath.row].pronunciationURL ?? ""
        
        return cell
    }
    
    
}

extension ListViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToResult", sender: self)
        wordTableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is ResultViewController {
            let vc = segue.destination as? ResultViewController
            if let indexPath = wordTableView.indexPathForSelectedRow{
                
                if let text = wordArray?[indexPath.row].vocab{
                    vc?.vocabulary = text
                }
                
            }
        }
        
        if segue.destination is PopUpRenameViewController {
            let vc = segue.destination as? PopUpRenameViewController
            vc?.selectedDocument = selectedDocument
            vc?.delegate = self
        }
        
        if segue.destination is FlashCardViewController {
            if wordArray?.count == 0{
                return
            }
            Analytics.logEvent("FlashCardTapped", parameters: nil)
            let vc = segue.destination as? FlashCardViewController
            vc?.wordArray = wordArray
        }
        
        if segue.identifier == "goToPDF" {
            Analytics.logEvent("PDFTapped", parameters: nil)
            guard
              let vc = segue.destination as? PDFPreviewViewController,
                let title = selectedDocument?.title,
                let wordArray = wordArray,
                let date = selectedDocument?.date
              else {
                return
            }

            let pdfCreator = PDFCreator(
              title: title,
              wordArray: wordArray,
                date: date
            )
            vc.documentData = pdfCreator.createFlyer()
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            do {
                try realm.write{
                    if let deleteWord = wordArray?[indexPath.row]{
                        realm.delete(deleteWord)
                        wordTableView.reloadData()
                    }
                }
            } catch {
                print("Error deleting document\(error)")
            }
        }
    }
    
}

extension ListViewController: UpdateDataDelegate{
    
    func updateTitle() {
        navigationBar.topItem?.title = selectedDocument?.title
    }
    
}
