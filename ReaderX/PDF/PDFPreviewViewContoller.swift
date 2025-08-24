//
//  PDFPreviewViewContoller.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 11/08/2021.
//

import Foundation
import PDFKit

class PDFPreviewViewController: UIViewController {
    
    public var documentData: Data?
    @IBOutlet weak var pdfView: PDFView!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let data = documentData {
      pdfView.document = PDFDocument(data: data)
      pdfView.autoScales = true
    }
  }
    
    @IBAction func backButtonClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonClicked(_ sender: UIBarButtonItem) {
        let vc = UIActivityViewController(
            activityItems: [documentData!],
          applicationActivities:nil
        )
        present(vc, animated: true, completion: nil)
    }
    
    
}

