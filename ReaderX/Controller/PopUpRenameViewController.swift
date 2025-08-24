//
//  popUpRenameViewController.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 31/07/2021.
//

import Foundation
import UIKit
import RealmSwift

protocol UpdateDataDelegate {
    func updateTitle()
}

class PopUpRenameViewController: UIViewController{
    
    @IBOutlet weak var popUpView: UIView!
    
    @IBOutlet weak var textField: UITextField!
    
    let realm = try! Realm()
    var selectedDocument : DocumentObject?
    
    var delegate : UpdateDataDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.becomeFirstResponder()
        textField.delegate = self
        
        popUpView.layer.cornerRadius = 10
        popUpView.layer.masksToBounds = true
    }
    

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        
        searchBarDone()
        
    }
    
    func searchBarDone(){
        if let newTitle = textField.text{
            
            do{
                try realm.write{
                    selectedDocument?.title = newTitle
                }
                
            } catch {
                print("Error update title, \(error)")
            }
            
        }
        
        self.dismiss(animated: true, completion: nil)
        delegate?.updateTitle()
    }
    
    
}

extension PopUpRenameViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        searchBarDone()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 20
    }
}
