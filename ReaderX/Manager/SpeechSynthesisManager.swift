//
//  SpeechSyntheisisManager.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 06/08/2021.
//

import Foundation
import UIKit
import MicrosoftCognitiveServicesSpeech
import AVFoundation

protocol SpeechRecognitionDelegate {
    func callRecognizeSound()
}

struct SpeechSynthesisManager {
    
    var delegate: SpeechRecognitionDelegate?
    
    func synthesisSound(en:String,zh:String,language:String){
        if language == "Default"{
            firstTask { (success) -> Void in
                if success {
                   synthesisToSpeaker(lan: "en-GB", voice: "en-GB-LibbyNeural", text: en)
                    print("done speaking.")
                    delegate?.callRecognizeSound()
                }
            }
        } else if language == "English"{
            synthesisToSpeaker(lan: "en-GB", voice: "en-GB-LibbyNeural", text: en)
            delegate?.callRecognizeSound()
        } else {
            synthesisToSpeaker(lan: "zh-CN", voice:         "zh-CN-XiaoxiaoNeural", text: zh)
            delegate?.callRecognizeSound()
        }
        func firstTask(completion: (_ success: Bool) -> Void) {
            synthesisToSpeaker(lan: "zh-CN", voice: "zh-CN-XiaoxiaoNeural", text: zh)
            completion(true)
        }
    }
    
    func synthesisToSpeaker(lan:String,voice:String,text:String) {
        var speechConfig: SPXSpeechConfiguration?
        do {
            try speechConfig = SPXSpeechConfiguration(subscription: "40bb36e2f97a4fe382950cb445114b94", region: "southeastasia")
        } catch {
            print("error \(error) happened")
            speechConfig = nil
        }
        speechConfig?.speechSynthesisLanguage = lan
        speechConfig?.speechSynthesisVoiceName = voice
        
        do{
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Error playing sound through speaker!")
        }

        
        let synthesizer = try! SPXSpeechSynthesizer(speechConfig!)
        let result = try! synthesizer.speakText(text)
        if result.reason == SPXResultReason.canceled
        {
            let cancellationDetails = try! SPXSpeechSynthesisCancellationDetails(fromCanceledSynthesisResult: result)
            print("cancelled, detail: \(cancellationDetails.errorDetails!) ")
        }
//        let readManager = ReadViewController()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            DispatchQueue.global(qos: .userInitiated).async {
//                readManager.recognizeFromMic()
//            }
//        }
    }
}
