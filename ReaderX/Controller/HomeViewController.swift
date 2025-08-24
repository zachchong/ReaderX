//
//  ViewController.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 24/07/2021.
//

import UIKit
import Network
import RealmSwift
import Firebase

class HomeViewController: DocumentTableViewController{

    @IBOutlet weak var greetingLabel: UILabel!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var seeAllButton: UIButton!
    
    @IBOutlet weak var documentTableView: UITableView!
    
    @IBOutlet weak var guideButton: UIButton!
    
    @IBOutlet weak var readingGoalLabel: UILabel!
    
    let realm = try! Realm()
    
    var documentArray : Results<DocumentObject>?
    var wordArray : Results<WordObject>?
    var document : DocumentObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        seeAllButton.layer.cornerRadius = 5
        seeAllButton.layer.masksToBounds = true
        
        monitorNetwork()
        
        loadDocument()
        
        documentTableView.dataSource = self
        documentTableView.delegate = self
        
//        updateNameManager.delegate = self
        
        let currentTime =  Calendar.current.component(.hour, from: Date())
        
        switch currentTime {
        case 5..<12 : greetingLabel.text = "Good Morning,"
        case 13..<17 : greetingLabel.text = "Good Afternoon,"
        default: greetingLabel.text = "Good Evening,"
        }
        
        documentTableView.register(UINib(nibName: "DocumentTableViewCell", bundle: nil), forCellReuseIdentifier: "DocumentReusableCell")
        
        name.text = UserDefaults.standard.string(forKey: "Name")
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let result = formatter.string(from: date)
        
        if UserDefaults.standard.string(forKey: "CurrentDate") != result{
            UserDefaults.standard.setValue(result, forKey: "CurrentDate")
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "ReadingGoal"), forKey: "GoalLeft")
        }
        
        name.text = UserDefaults.standard.string(forKey: "Name")
        
        if UserDefaults.standard.integer(forKey: "GoalLeft") <= 1 {
            readingGoalLabel.text = "Today's Goal  \(UserDefaults.standard.integer(forKey: "GoalLeft")) minute left"
        } else {
            readingGoalLabel.text = "Today's Goal  \(UserDefaults.standard.integer(forKey: "GoalLeft")) minutes left"
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if Core.shared.isNewUser(){
            let vc = storyboard?.instantiateViewController(identifier: "welcome") as! WelcomeViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
    }
    
    //MARK:- Network Checking
    
    func monitorNetwork() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = {path in
            
            if path.status != .satisfied{
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "No Internet Connection", message: "Please check your Internet connection.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                print("No Internet Connection")
            } else {
                print("Internet Connected")
            }
            
        }
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        documentTableView.reloadData()
    }
    
    func loadDocument(){
        documentArray = realm.objects(DocumentObject.self).sorted(byKeyPath: "date", ascending: false)
        documentTableView.reloadData()
    }
    
    func loadWord(index:Int){
        wordArray = documentArray?[index].wordList.sorted(byKeyPath: "vocab", ascending: true)
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
            cell.title.text = "No Documments Added"
            cell.date.text = ""
            cell.numberOfWord.text = ""
            cell.flashCardButton.isHidden = true
            
        } else {
            cell.flashCardButton.isHidden = false
            document = documentArray?[indexPath.row]
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

    @IBAction func seeAllButtonClicked(_ sender: UIButton) {
        
        if let tabBarController = self.parent as? UITabBarController {
            tabBarController.selectedIndex = 2
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if documentArray?.count == 0{
            let alert = UIAlertController(title: "Create Your First Document", message: "Document will be created automatically once you search a word or start reading.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            documentTableView.deselectRow(at: indexPath, animated: true)
        } else {
            performSegue(withIdentifier: "goToList", sender: self)
            documentTableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToList" {
            
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
    
    @IBAction func guideButtonClicked(_ sender: UIButton) {
        
        let vc = storyboard?.instantiateViewController(identifier: "guide") as! GuideViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
        
    }
    
    
}

extension HomeViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        Analytics.logEvent("searchDictionary", parameters: nil)
        performSegue(withIdentifier: "goToDictionary", sender: self)
    }
    
}

extension HomeViewController: GoToFlashCardDelegate{
    
    func goToFlashCard(indexPath:Int) {
        Analytics.logEvent("FlashCardTapped", parameters: nil)
        if wordArray?.count == 0 || wordArray == nil{
            return
        } 
        loadWord(index: indexPath)
        performSegue(withIdentifier: "goToFlashCard", sender: self)
    }
    
}

//extension HomeViewController: UpdateName{
//
//    func updateName() {
//        name.text = UserDefaults.standard.string(forKey: "Name")
//    }
//
//
//}

class Core{
    
    static let shared = Core()
    
    func isNewUser() -> Bool{
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }
    
    func setIsNotNewUser(){
        UserDefaults.standard.set(true, forKey: "isNewUser")
    }
}


