//
//  ResultViewController.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 26/07/2021.
//

import Foundation
import UIKit
import AVFoundation
import RealmSwift

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
}

class ResultViewController: UIViewController{
    
    let realm = try! Realm()
    var documentsArray : Results<DocumentObject>?
    var wordsArray : Results<WordObject>?
    var currentDocument : DocumentObject?
    
    @IBOutlet weak var speakerButton: UIButton!
    var speakerButtonIsHidden = false
    
    @IBOutlet weak var resultTableView: UITableView!
    
    @IBOutlet weak var vocab: UILabel!
    
    var vocabulary = String()
    var wordLists : [Word]?
    var audioURL = String()
    var player : AVPlayer?
    var dataManager = DictionaryAPIManager()
    var BCTranslatorManager = BCTranslatorAPIManager()
    var status = ""
    var i = 0
    var BCAvailable = true
    
    let date = Date()
    let formatter = DateFormatter()
    
    var ENurl = "https://api.dictionaryapi.dev/api/v2/entries/en_GB/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vocab.text = vocabulary
        ENurl = ENurl + vocabulary
        
        speakerButton.isHidden = speakerButtonIsHidden
        
        resultTableView.dataSource = self
        
        dataManager.delegate = self
        BCTranslatorManager.delegate = self
        
        resultTableView.register(UINib(nibName: "ResultTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultReusableCell")

        BCTranslatorManager.performRequest(text: vocabulary)
        dataManager.performRequest(url: self.ENurl)
        
        formatter.dateFormat = "MMM dd,yyyy"
        let result = formatter.string(from: date)
        
        //MARK:- Write Document
        
        if realm.objects(DocumentObject.self).filter("date = '\(result)'").count == 0 {
            let newDocument = DocumentObject()
            newDocument.title = "ReaderX \(result)"
            newDocument.date = result
            newDocument.number = "\(wordsArray?.count ?? 0)"
            save(document: newDocument)
        }
        
        currentDocument = realm.objects(DocumentObject.self).filter("date = '\(result)'").first
        
    }
    
    //MARK:- Pronounciation
    
    @IBAction func pronunciation(_ sender: UIButton) {
        
        guard let url = URL.init(string: audioURL) else { return }
        let playerItem = AVPlayerItem.init(url: url)
        player = AVPlayer.init(playerItem: playerItem)
        player?.play()

    }
    
    //MARK:- Back Button Clicked
    
    
    @IBAction func backButtonClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Save method
    
    func save(document: DocumentObject) {
        do {
            try realm.write {
                realm.add(document)
            }
        } catch {
            print("Error saving data, \(error)")
        }
    }
    
}

//MARK:- TableViewDataSource

extension ResultViewController: UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if wordLists?.count == 0 {
            return 1
        } else {
            return wordLists?.count ?? 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultReusableCell", for: indexPath) as! ResultTableViewCell
        
        if wordLists?.count == 0{
            cell.partOfSpeech.text = ""
            cell.definition.text = ""
            cell.example.text = status
        } else {
            cell.partOfSpeech.text = wordLists?[indexPath.row].partOfSpeech.firstUppercased ?? ""
            cell.definition.text = wordLists?[indexPath.row].definition.firstUppercased ?? ""
            cell.example.text = wordLists?[indexPath.row].example?.firstUppercased ?? status
        }
       
        return cell
    }



}

//MARK:- DataManagerDelegate

extension ResultViewController: dataManagerDelegate{
    
    func didUpdateData(_ dataManager: DictionaryAPIManager, data: [Word], url: String) {
        DispatchQueue.main.async {
            while self.i < data.count{
                self.wordLists?.append(data[self.i])
                self.i += 1
            }
            self.resultTableView.reloadData()
            self.audioURL = url
            
            do {
                try self.realm.write {
                    
                    if self.currentDocument?.wordList.filter("vocab = '\(self.vocabulary)'").count == 0{
                        let newWord = WordObject()
                        if self.BCAvailable == true {
                            if let bc = self.wordLists?[0].definition{
                                newWord.zh_CN = bc
                            }
                            
                            newWord.en = self.wordLists?[1].definition ?? ""
                            
                        } else {
                            newWord.zh_CN = ""
                            newWord.en = self.wordLists?[0].definition ?? ""
                        }
                        newWord.vocab = self.vocabulary
                        newWord.pronunciationURL = self.audioURL
                        newWord.dateCreated = Date()
                            
                        self.currentDocument?.wordList.append(newWord)
                    }
                    
                }
            }catch {
                    print("Error saving object, \(error)")
                }
            
        
        }
    }
    
    func didFailWithError(error: Error) {
        print("Fail getting data,\(error)")
        DispatchQueue.main.async {
            self.status = "Sorry, No Definitions Found."
            self.resultTableView.reloadData()
        }
        
    }
    
    
}

extension ResultViewController: CNDataManagerDelegate{
    
    func BCdidFailWithError(error: Error) {
        print("Fail getting CN,\(error)")
        self.BCAvailable = false

    }
    
    func noBCTranslate(){
        self.wordLists = []
        self.BCAvailable = false
    }
    
    func didUpdateData(_ dataManager: BCTranslatorAPIManager, data: String) {
        DispatchQueue.main.async {
            self.wordLists = []
            self.wordLists?.append(Word(partOfSpeech: "Chinese(Simplified)", definition: data, example: "", chinese: ""))
        }
    }
    
}
