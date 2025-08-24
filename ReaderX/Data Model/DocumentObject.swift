//
//  document.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 25/07/2021.
//

import Foundation
import RealmSwift

class DocumentObject : Object {
    @objc dynamic var title : String = ""
    @objc dynamic var date : String = ""
    let wordList = List<WordObject>()
    @objc dynamic var number : String = ""
}


