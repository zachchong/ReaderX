//
//  ReadViewController.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 25/07/2021.
//

import Foundation
import UIKit
import DropDown
import RealmSwift
import MicrosoftCognitiveServicesSpeech
import AVFoundation
import Firebase
import StoreKit

class ReadViewController: UIViewController {
    
    //speech recognition
    var sub: String!
    var region: String!
    
    //speech synthesis
    var player: AVAudioPlayer?
    var playerPronounce: AVPlayer?
    var userChoosenLanguage = "Default"
    
    //speech synthesis
    var speechController = SpeechSynthesisManager()
    var mute = false
    
    //speech recognition
    let menu: DropDown = {
        let menu = DropDown()
        menu.dataSource = ["Select Languages","Default","English","Chinese"]
        menu.cellNib = UINib(nibName: "DropDownCell", bundle: nil)
        menu.customCellConfiguration = {index,title,cell in
            
            guard let cell = cell as? MenuCell else {
                return
            }
            if index == 0{
                cell.isUserInteractionEnabled = false
                cell.view.backgroundColor = UIColor(red: 205/255.0, green: 240/234.0, blue: 1.0, alpha: 1)
                
            } else if index == 1{
                cell.view.backgroundColor = UIColor(cgColor: CGColor(red: 190/255.0, green: 174/255.0, blue: 226/255.0, alpha: 1))
            } else if index == 2{
                cell.view.backgroundColor = UIColor(cgColor: CGColor(red: 247/255.0, green: 219/255.0, blue: 240/255.0, alpha: 1))
            } else {
                cell.view.backgroundColor = UIColor(cgColor: CGColor(red: 249/255.0, green: 248/255.0, blue: 249/255.0, alpha: 1))
            }
            
        }
        return menu
        
    }()
    
    //dictionary
    var ENurl = "https://api.dictionaryapi.dev/api/v2/entries/en_GB/"
    var audioURL = String()
    var dataManagerR = DictionaryAPIManager()
    var BCTranslatorManagerR = BCTranslatorAPIManager()
    var wordLists : [Word]?
    var i = 0
    var readerWordArray : [ReaderWord]?
    var BCAvailable = true
    var vocab = String()
    var status = String()
    
    var timeString = String()
    
    
    
    //dictionary
    
    
    @IBOutlet weak var statusLabel: UILabel!
    
    var timer:Timer = Timer()
    var count:Int = 0
    var timerCounting = false
    
    @IBOutlet weak var endStartButton: UIButton!
    
    @IBOutlet weak var selectLanguageButton: UIButton!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var muteButton: UIButton!
    
    @IBOutlet weak var selectLanguageBarItem: UIBarButtonItem!
    
    @IBOutlet weak var readingTableView: UITableView!
    
    //realm
    let realm = try! Realm()
    var documentsArray : Results<DocumentObject>?
    var wordsArray : Results<WordObject>?
    let date = Date()
    let formatter = DateFormatter()
    var currentDocument : DocumentObject?
    
    //MARK:- View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mute = UserDefaults.standard.bool(forKey: "mute")
        if mute == true{
            muteButton.setImage(UIImage(systemName: "speaker.slash"), for: .normal)
        } else {
            muteButton.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
        }
        
//        speechSynthesisManager.delegate = self
        // speech recognition
        sub = "40bb36e2f97a4fe382950cb445114b94"
        region = "southeastasia"
        // speech recognition
        
        //dictionary delegate
        dataManagerR.delegate = self
        BCTranslatorManagerR.delegate = self
        
        DropDown.appearance().cornerRadius = 20
        
        menu.anchorView = selectLanguageBarItem
        menu.selectionAction = { index, title in
            if index != 0 {
                self.selectLanguageButton.setTitle(title, for: .normal)
            }
            if index == 1 {
                self.userChoosenLanguage = "Default"
            } else if index == 2{
                self.userChoosenLanguage = "English"
            } else {
                self.userChoosenLanguage = "Chinese"
            }
            
            self.userChoosenLanguage = title
        }
        
        readingTableView.dataSource = self
        readingTableView.delegate = self
        
        readingTableView.register(UINib(nibName: "ReadTableViewCell", bundle: nil), forCellReuseIdentifier: "ReadReusableCell")
        
        selectLanguageButton.layer.cornerRadius = 20
        selectLanguageButton.layer.masksToBounds = true
        
    }
    
    @objc func timerCounter() -> Void{
        count = count + 1
        let time = secondsToHoursMinutesSeconds(seconds: count)
        timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        navigationBar.topItem?.title = timeString
        if count == UserDefaults.standard.integer(forKey: "ReadingGoal")*60 {
            playSound(file: "success")
        }
    }
    
    func secondsToHoursMinutesSeconds(seconds:Int) -> (Int,Int,Int){
        return ((seconds / 3600),((seconds % 3600) / 60),((seconds % 3600) % 60))
    }
    
    func makeTimeString(hours:Int,minutes:Int,seconds:Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += " : "
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        return timeString
    }

    
    //MARK:- Start / End Button
    @IBAction func endButtonClicked(_ sender: UIButton) {
        
        if timerCounting == false{
            
            Analytics.logEvent("StartReadingTapped", parameters: nil)
            
            UIApplication.shared.isIdleTimerDisabled = true
            
            //menu deacticate
            selectLanguageButton.isUserInteractionEnabled = false
            
            //start reading
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
            
            //speech recognition
            DispatchQueue.global(qos: .userInitiated).async {
                self.recognizeFromMic()
            }
            //speech recognition
            self.timerCounting = true
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
            endStartButton.setTitle("End", for: .normal)
            endStartButton.setTitleColor(UIColor.red, for: .normal)
        } else {
            
            Analytics.logEvent("ReadingEnd", parameters: ["ReadingTime":timeString])
            
            UIApplication.shared.isIdleTimerDisabled = false
            
            let alert = UIAlertController(title: "End Reading", message: "Are you sure you would like to end the Reading", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                //nothing
            }))
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                self.timerCounting = false
                UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey:"GoalLeft")-((self.count-(self.count%60))/60), forKey: "GoalLeft")
                if UserDefaults.standard.integer(forKey: "GoalLeft") < 0 {
                    UserDefaults.standard.setValue(0, forKey: "GoalLeft")
                }
                
                if self.count >= 8{
                    guard let scene = self.view.window?.windowScene else {
                        return
                    }
                    if #available(iOS 14.0, *) {
                        SKStoreReviewController.requestReview(in: scene)
                    } else {
                        return
                    }
                    
                }
                self.selectLanguageButton.isUserInteractionEnabled = true
                self.count = 0
                self.timer.invalidate()
                self.navigationBar.topItem?.title = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
                self.endStartButton.setTitle("Start", for: .normal)
                self.endStartButton.setTitleColor(UIColor.green, for: .normal)
                //end session
                self.statusLabel.text = "Well Done!"
                self.readerWordArray = nil
                self.wordLists = nil
                self.BCAvailable = true
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func save(document: DocumentObject) {
        do {
            try realm.write {
                realm.add(document)
            }
        } catch {
            print("Error saving data, \(error)")
        }
    }
    
    
    @IBAction func selectLanguages(_ sender: UIButton) {
        menu.show()
    }
    
    //MARK:- speech recognition
    func recognizeFromMic() {
        var speechConfig: SPXSpeechConfiguration?
        do {
            try speechConfig = SPXSpeechConfiguration(subscription: sub, region: region)
        } catch {
            print("error \(error) happened")
            speechConfig = nil
        }
        speechConfig?.speechRecognitionLanguage = "en-US"
        
        let audioConfig = SPXAudioConfiguration()
        
        let reco = try! SPXSpeechRecognizer(speechConfiguration: speechConfig!, audioConfiguration: audioConfig)
        
        reco.addRecognizingEventHandler() {reco, evt in
            print("intermediate recognition result: \(evt.result.text ?? "(no result)")")
            self.updateLabel(text: evt.result.text, color: .gray)
        }
        
        updateLabel(text: "Listening ...", color: .gray)
        
        let result = try! reco.recognizeOnce()
        print("recognition result: \(result.text ?? "(no result)")")
        if result.text != ""{
            if var textRecognised = result.text {
                if textRecognised.last == "."{
                    textRecognised = String(textRecognised.dropLast())
                }
                textRecognised = textRecognised.lowercased()
                vocab = textRecognised
                updateLabel(text: textRecognised, color: .white)
                print(textRecognised)
                searchDictionary(vocab: textRecognised)
            }
        } else{
            if timerCounting == true{
                DispatchQueue.global(qos: .userInitiated).async {
                    self.recognizeFromMic()
                }
            }
        }
    }
    
    func updateLabel(text: String?, color: UIColor) {
        DispatchQueue.main.async {
            self.statusLabel.text = text
            self.statusLabel.textColor = color
        }
    }
    
    func searchDictionary(vocab:String){
        ENurl = ENurl + vocab
        BCTranslatorManagerR.performRequest(text: vocab)
        dataManagerR.performRequest(url: self.ENurl)
    }
    
    //MARK:- Play Sound
    func playSound(file:String) {

        let url = Bundle.main.url(forResource: file, withExtension: "mp3")!

            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }

                player.prepareToPlay()
                player.play()

            } catch let error as NSError {
                print(error.description)
            }
    }
    
    //MARK:- Animation
    func animatedImages(for name: String) -> [UIImage] {
        
        var i = 0
        var images = [UIImage]()
        
        while let image = UIImage(named: "\(name)/\(i)") {
            images.append(image)
            i += 1
        }
        return images
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.readerWordArray!.count-1, section: 0)
            self.readingTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    
    @IBAction func muteButtonClicked(_ sender: UIButton) {
        if mute == true{
            UserDefaults.standard.setValue(false, forKey: "mute")
            mute = false
            muteButton.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
        } else {
            UserDefaults.standard.setValue(true, forKey: "mute")
            mute = true
            muteButton.setImage(UIImage(systemName: "speaker.slash"), for: .normal)
        }
    }
    

}

//MARK:- TableView DataSource

extension ReadViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if readerWordArray?.count == 0 {
            return 1
        } else {
            return readerWordArray?.count ?? 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReadReusableCell", for: indexPath) as! ReadTableViewCell
        cell.vocab.text = readerWordArray?[indexPath.row].vocab.firstUppercased
        cell.zhCN.text = readerWordArray?[indexPath.row].zh_CN
        cell.en.text = readerWordArray?[indexPath.row].en.firstUppercased ?? "Yay, your reading partner is ready!"
        
        cell.view.layer.cornerRadius = 10
        cell.view.layer.masksToBounds = true
        
        cell.robotImage.animationImages = animatedImages(for: "PodcastPlaying")
        cell.robotImage.animationRepeatCount = 0
        cell.robotImage.animationDuration = 1
        cell.robotImage.image = cell.robotImage.animationImages?.first
        cell.robotImage.startAnimating()
        
        if userChoosenLanguage == "English" {
            cell.en.isHidden = false
            cell.zhCN.isHidden = true
        } else if userChoosenLanguage == "Chinese" {
            cell.zhCN.isHidden = false
            cell.en.isHidden = true
        } else if userChoosenLanguage == "Default" {
            cell.zhCN.isHidden = false
            cell.en.isHidden = false
        }
        
        return cell
    }
    
    
}

//MARK:- TableView Delegate

extension ReadViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if readerWordArray?.count == nil{
            readingTableView.deselectRow(at: indexPath, animated: true)
            return
        } else {
            Analytics.logEvent("ReadingCellTapped", parameters: nil)
            performSegue(withIdentifier: "goToResult", sender: self)
            readingTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is ResultViewController {
            let vc = segue.destination as? ResultViewController
            if let indexPath = readingTableView.indexPathForSelectedRow{
                
                if let text = readerWordArray?[indexPath.row].vocab{
                    vc?.vocabulary = text
                }
                
            }
            vc?.speakerButtonIsHidden = true
            
        }
        
    }
    
    
    
}

//MARK:- DictionaryAPI

extension ReadViewController: dataManagerDelegate{
    
    func didUpdateData(_ dataManager: DictionaryAPIManager, data: [Word], url: String) {
        DispatchQueue.main.async {
            
            if self.readerWordArray == nil {
                self.readerWordArray = []
            }
            
            while self.i < data.count{
                self.wordLists?.append(data[self.i])
                self.i += 1
            }
            self.audioURL = url
            
            if self.audioURL != "" {
                self.playPronounce()
            }


            if self.BCAvailable == true{
                
                if let bc = self.wordLists?[0].definition{
                    let newWord = ReaderWord(en: self.wordLists?[1].definition ?? self.status, vocab: self.vocab, pronounceURL: self.audioURL, zh_CN: bc, dateCreated: Date())
                    self.readerWordArray?.append(newWord)
                }
                
            } else {
                
                if self.wordLists?.count == 0{
                    return
                }
                
                let newWord = ReaderWord(en: self.wordLists?[0].definition ?? self.status, vocab: self.vocab, pronounceURL: self.audioURL, zh_CN: "", dateCreated: Date())
                self.readerWordArray?.append(newWord)
                
            }
            self.readingTableView.reloadData()
            self.scrollToBottom()
            self.refresh()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                if self.mute == true{
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.recognizeFromMic()
                    }
                    return
                }
                
                self.speechController.delegate = self
                self.speechController.synthesisSound(en: self.readerWordArray?.last?.en ?? "", zh: self.readerWordArray?.last?.zh_CN ?? "", language: self.userChoosenLanguage)
            }
            
            do{
                
                try self.realm.write{
                    if self.currentDocument?.wordList.filter("vocab = '\(self.vocab)'").count == 0 {
                        let newWord = WordObject()
                        newWord.dateCreated = self.readerWordArray?.last?.dateCreated
                        newWord.en = self.readerWordArray?.last?.en ?? "No definition found."
                        newWord.zh_CN = self.readerWordArray?.last?.zh_CN ?? ""
                        newWord.pronunciationURL = self.readerWordArray?.last?.pronounceURL ?? ""
                        newWord.vocab = self.readerWordArray?.last?.vocab ?? ""
                        self.currentDocument?.wordList.append(newWord)
                    }
                }
                
            } catch {
                print("Error saving object, \(error)")
            }
            
        }
    }
    
    //MARK:- play pronounce
    
    func playPronounce(){
        guard let url = URL.init(string: audioURL) else { return }
        let playerItem = AVPlayerItem.init(url: url)
        playerPronounce = AVPlayer.init(playerItem: playerItem)
        playerPronounce?.play()
    }

    
    func refresh() {
        self.ENurl = "https://api.dictionaryapi.dev/api/v2/entries/en_GB/"
        self.BCAvailable = true
        self.i = 0
    }
    
    func didFailWithError(error: Error) {
        print("Fail getting data,\(error)")
        DispatchQueue.main.async {
            self.playSound(file: "tryagain")
            self.refresh()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            DispatchQueue.global(qos: .userInitiated).async {
                self.recognizeFromMic()
            }
        }
    }
    
    
}

extension ReadViewController: CNDataManagerDelegate{
    
    func didUpdateData(_ dataManager: BCTranslatorAPIManager, data: String) {
        DispatchQueue.main.async {
            self.wordLists = []
            self.wordLists?.append(Word(partOfSpeech: "Chinese(Simplified)", definition: data, example: "", chinese: ""))
        }
    }
    
    func BCdidFailWithError(error: Error) {
        print("Fail getting CN,\(error)")
        self.BCAvailable = false
    }
    
    func noBCTranslate() {
        self.wordLists = []
        self.BCAvailable = false
    }
    
    
}

extension ReadViewController: SpeechRecognitionDelegate{
    func callRecognizeSound(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            DispatchQueue.global(qos: .userInitiated).async {
                self.recognizeFromMic()
            }
        }
    }
}
