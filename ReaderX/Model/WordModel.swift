//
//  WordModel.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 26/07/2021.
//

import Foundation

struct WordData: Decodable {
    let phonetics: [Phonetics]
    let meanings: [Meanings]
}

struct Phonetics: Decodable {
    let audio: String?
}

struct Meanings: Decodable {
    let partOfSpeech: String?
    let definitions: [Definitions]
}

struct Definitions: Decodable {
    let definition: String
    let example: String?
}
