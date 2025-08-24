//
//  DictionaryAPI.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 26/07/2021.
//

import Foundation
import UIKit
import AVFoundation

protocol dataManagerDelegate{
    func didUpdateData(_ dataManager: DictionaryAPIManager, data:[Word], url:String)
    func didFailWithError(error: Error)
}

struct DictionaryAPIManager {
    
    var delegate: dataManagerDelegate?
    
    func performRequest(url:String){
        
        let replacedURL = url.replacingOccurrences(of: " ", with: "%20")
        
        if let url = URL(string: replacedURL){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    print(error!)
                    return
                }
                if let data = data {
                    
                    if let (words,url) = parseJSON(data) {
                        if let words = words, let url = url {
                            delegate?.didUpdateData(self, data: words, url: "https:"+url)
                        }
                    }
                }
            }
            task.resume()
            
        }
    }
    
    func parseJSON(_ data:Data) -> ([Word]?,String?)?{
        let decoder = JSONDecoder()
        do {
            
            let decodedData = try decoder.decode([WordData].self, from: data)
            var audio = String()
            if decodedData.first?.phonetics.count != 0 {
                audio = decodedData.first!.phonetics[0].audio ?? ""
            }
            let meanings = decodedData.first!.meanings
            var words:[Word] = []
            var i = 0
            while i < meanings.count{
                let constant = decodedData.first!.meanings[i]
                words.append(Word(partOfSpeech: constant.partOfSpeech ?? "", definition: constant.definitions[0].definition, example: constant.definitions[0].example ?? "", chinese: ""))
                i += 1
            }
            
            return (words,audio)
            
            
        } catch {
            delegate?.didFailWithError(error: error)
            return (nil,nil)
        }
    }
    
}
