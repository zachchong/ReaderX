//
//  flashCardViewController.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 09/08/2021.
//

import Foundation
import UIKit
import RealmSwift
import AVFoundation

class FlashCardViewController: UIViewController{
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var questionNumber: UILabel!
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var frontView: UIView!
    
    var wordArray : Results<WordObject>?
    var currentQuestion = 0
    
    @IBOutlet weak var chinese: UILabel!
    @IBOutlet weak var english: UILabel!
    @IBOutlet weak var vocabulary: UILabel!
    
    //audio
    var player: AVAudioPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backView.layer.cornerRadius = 10
        frontView.layer.cornerRadius = 10
        backView.layer.masksToBounds = true
        frontView.layer.masksToBounds = true
        
        let tapFront = UITapGestureRecognizer(target: self, action: #selector(self.handleTapFront(_:)))
        let tapBack = UITapGestureRecognizer(target: self, action: #selector(self.handleTapBack(_:)))
        
        frontView.addGestureRecognizer(tapFront)
        backView.addGestureRecognizer(tapBack)
        
        questionNumber.text = "\(currentQuestion + 1)/\(wordArray?.count ?? 0)"
        loadCard()
        
    }
    
    @objc func handleTapFront(_ sender: UITapGestureRecognizer) {
        playSoundEffect(resource: "flip")
        UIView.transition(from: frontView, to: backView, duration: 0.5, options: [.transitionFlipFromLeft,.showHideTransitionViews], completion: nil)
      }
    
    @objc func handleTapBack(_ sender: UITapGestureRecognizer) {
        playSoundEffect(resource: "flip")
        UIView.transition(from: backView, to: frontView, duration: 0.5, options: [.transitionFlipFromLeft,.showHideTransitionViews], completion: nil)
      }
    

    @IBAction func nextButtonClicked(_ sender: UIButton) {
        
        if let wordCount = wordArray?.count{
            if currentQuestion == wordCount - 1 {
                questionNumber.text = "The End"
                return
            }
            playSoundEffect(resource: "next")
            UIView.transition(from: backView, to: frontView, duration: 0.5, options: [.transitionFlipFromBottom,.showHideTransitionViews], completion: nil)
            currentQuestion += 1
            questionNumber.text = "\(currentQuestion + 1)/\(wordArray?.count ?? 0)"
            loadCard()
        }
    }
    
    @IBAction func backButtonCliked(_ sender: UIButton) {
        
        if currentQuestion == 0 {
            return
        }
        playSoundEffect(resource: "next")
        UIView.transition(from: backView, to: frontView, duration: 0.5, options: [.transitionFlipFromTop,.showHideTransitionViews], completion: nil)
        currentQuestion -= 1
        questionNumber.text = "\(currentQuestion + 1)/\(wordArray?.count ?? 0)"
        loadCard()
    }
    
    func loadCard(){
        vocabulary.text = wordArray?[currentQuestion].vocab
        chinese.text = wordArray?[currentQuestion].zh_CN
        english.text = wordArray?[currentQuestion].en
    }
    
    func playSoundEffect(resource:String) {

        let url = Bundle.main.url(forResource: resource, withExtension: "mp3")!

            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }

                player.prepareToPlay()
                player.play()

            } catch let error as NSError {
                print(error.description)
            }
    }
    
    
}
