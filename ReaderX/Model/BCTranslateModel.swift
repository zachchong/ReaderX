//
//  BCTranslateModel.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 29/07/2021.
//

import Foundation

struct TranslateData: Decodable {
    let translations : [Translation]
}

struct Translation: Decodable {
    let normalizedTarget : String
}
