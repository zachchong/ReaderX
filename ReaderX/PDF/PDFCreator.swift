//
//  PDFCreator.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 11/08/2021.
//

import UIKit
import PDFKit
import RealmSwift

class PDFCreator: NSObject {
    
    let title: String
    let wordArray: Results<WordObject>
    let date: String
    
    init(title:String,wordArray:Results<WordObject>,date:String) {
        self.title = title
        self.wordArray = wordArray
        self.date = date
    }
    
    var wordBody = String()
    var index = 0
    var currentCGFLoat = CGFloat()
    
    func createFlyer() -> Data {
      // 1
      let pdfMetaData = [
        kCGPDFContextCreator: "ReaderX",
        kCGPDFContextAuthor: "ReaderX.com",
        kCGPDFContextTitle: title
      ]
      let format = UIGraphicsPDFRendererFormat()
      format.documentInfo = pdfMetaData as [String: Any]

      // 2
      let pageWidth = 8.3 * 72.0
        let pageHeight = 11.7 * 72.0
      let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

      // 3
      let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
      // 4
      let data = renderer.pdfData { (context) in
        // 5
        context.beginPage()
        // 6
        let titleBottom = addTitle(pageRect: pageRect)
        while index != wordArray.count {
            if currentCGFLoat < 620{
                if currentCGFLoat == 0 {
                    currentCGFLoat = titleBottom + 36.0
                } else {
                    currentCGFLoat += 55.0
                }
                
                addBodyText(pageRect: pageRect, textTop: currentCGFLoat)
                
                if wordArray[index].en.count >= 40{
                    currentCGFLoat += 30.0
                }
                index += 1
                
            } else {
                context.beginPage()
                currentCGFLoat = 0
                if currentCGFLoat == 0 {
                    currentCGFLoat = titleBottom + 36.0
                } else {
                    currentCGFLoat += 55.0
                }
                
                addBodyText(pageRect: pageRect, textTop: currentCGFLoat)
        
                if wordArray[index].en.count >= 40{
                    currentCGFLoat += 30.0
                }
                index += 1
            }
        }
      }

      return data
    }
    
    func addTitle(pageRect: CGRect) -> CGFloat{
      // 1
      let titleFont = UIFont.systemFont(ofSize: 25.0, weight: .bold)
      // 2
      let titleAttributes: [NSAttributedString.Key: Any] =
        [NSAttributedString.Key.font: titleFont]
      // 3
      let attributedTitle = NSAttributedString(
        string: title,
        attributes: titleAttributes
      )
      // 4
      let titleStringSize = attributedTitle.size()
      // 5
      let titleStringRect = CGRect(
        x: (pageRect.width - titleStringSize.width) / 2.0,
        y: 36,
        width: titleStringSize.width,
        height: titleStringSize.height
      )
      // 6
      attributedTitle.draw(in: titleStringRect)
      // 7
      return titleStringRect.origin.y + titleStringRect.size.height
    }
    
    func addBodyText(pageRect: CGRect, textTop: CGFloat) {
        
        //set wordBody
        wordBody = "\(index + 1). \(wordArray[index].vocab) \(wordArray[index].zh_CN) - \(wordArray[index].en)"
        
        let textFont = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
      // 1
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = .natural
      paragraphStyle.lineBreakMode = .byWordWrapping
      // 2
      let textAttributes = [
        NSAttributedString.Key.paragraphStyle: paragraphStyle,
        NSAttributedString.Key.font: textFont
      ]
      let attributedText = NSAttributedString(
        string: wordBody,
        attributes: textAttributes
      )
      // 3
      let textRect = CGRect(
        x: 10,
        y: textTop,
        width: pageRect.width - 20,
        height: pageRect.height - textTop - pageRect.height / 6.0
      )
      attributedText.draw(in: textRect)
    }
    
}
