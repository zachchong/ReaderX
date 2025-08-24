//
//  SettingsViewController.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 25/08/2021.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var currentNameLabel: UILabel!
    
    @IBOutlet weak var currentGoalLabel: UILabel!
    
    @IBOutlet weak var newNameTextField: UITextField!
    
    @IBOutlet weak var newGoalTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newNameTextField.delegate = self
        newGoalTextField.delegate = self
        newNameTextField.returnKeyType = .done
        newGoalTextField.returnKeyType = .done
        
        currentNameLabel.text = UserDefaults.standard.string(forKey: "Name")
        currentGoalLabel.text = String(UserDefaults.standard.integer(forKey: "ReadingGoal"))+" minute(s)"

        
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        if newNameTextField.text?.count != 0{
            UserDefaults.standard.set(newNameTextField.text,forKey: "Name")
        }
        if newGoalTextField.text?.count != 0{
            UserDefaults.standard.setValue(Int(newGoalTextField.text!), forKey: "ReadingGoal")
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "ReadingGoal"), forKey: "GoalLeft")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SettingsViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == newNameTextField{
//            if textField.text?.count != 0 {
//                UserDefaults.standard.set(textField.text,forKey: "Name")
//                textField.resignFirstResponder()
//            }
//        } else if textField == newGoalTextField{
//            if textField.text?.count != 0 {
//                UserDefaults.standard.setValue(Int(textField.text!), forKey: "ReadingGoal")
//                textField.resignFirstResponder()
//            }
//        }
        textField.resignFirstResponder()
        return true
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == newGoalTextField{
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
                let compSepByCharInSet = string.components(separatedBy: aSet)
                let numberFiltered = compSepByCharInSet.joined(separator: "")
                return string == numberFiltered
        } else {
            return true
        }
    }
    
}
