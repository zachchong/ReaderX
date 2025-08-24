//
//  bcTranslatorAPIManager.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 29/07/2021.
//

import Foundation

protocol CNDataManagerDelegate{
    func didUpdateData(_ dataManager: BCTranslatorAPIManager, data:String)
    func BCdidFailWithError(error: Error)
    func noBCTranslate()
}

struct BCTranslatorAPIManager {
    
    var delegate: CNDataManagerDelegate?
    
    func performRequest(text:String){
        
        let url = URL(string: "https://api.cognitive.microsofttranslator.com/dictionary/lookup?api-version=3.0&from=en&to=zh-Hans")
        
        guard url != nil else {
            print("Error creating url object")
            return
        }
        
        var request  = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        let header = [
            "Ocp-Apim-Subscription-Key": "f09521f9b3884e3c9f62971554c9b498",
            "Content-type": "application/json","Ocp-Apim-Subscription-Region":"southeastasia"
        ]
        
        request.allHTTPHeaderFields = header
        
        let jsonObject = ["Text":text] as [String : Any]
        
        do {
            let requestBody = try JSONSerialization.data(withJSONObject: jsonObject, options: .fragmentsAllowed)
            
            request.httpBody = requestBody
        } catch {
            print("Error creating the data object from json")
        }
        
        request.httpMethod = "POST"
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            
            if error != nil {
                print(error!)
                return
            }
            
            if let setData = data {
                
                if let chinese = parseJSON(setData){
                    delegate?.didUpdateData(self, data: chinese)
                } else {
                    delegate?.noBCTranslate()
                }
                
            }
        }
        
        dataTask.resume()
    }
    
    func parseJSON(_ data:Data) -> String? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(TranslateData.self, from: data)
            if decodedData.translations.count != 0 {
                let zh = decodedData.translations[0].normalizedTarget
                return zh
            } else {
                return nil
            }
        } catch{
            delegate?.BCdidFailWithError(error: error)
            return nil
        }
    }

}
