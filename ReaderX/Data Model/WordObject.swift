//
//  Word.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 25/07/2021.
//

import Foundation
import RealmSwift

class WordObject : Object {
    @objc dynamic var vocab : String = ""
    @objc dynamic var zh_CN : String = ""
    @objc dynamic var en : String = ""
    @objc dynamic var pronunciationURL : String = ""
    @objc dynamic var dateCreated: Date?
    var parentDocument = LinkingObjects(fromType: DocumentObject.self , property: "wordList")
}
