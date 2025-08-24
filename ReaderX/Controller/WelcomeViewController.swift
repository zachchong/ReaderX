//
//  WelcomeViewController.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 14/08/2021.
//

import UIKit
import UserNotifications

class WelcomeViewController: UIViewController {

    @IBOutlet weak var holderView: UIView!
    
    let scrollView = UIScrollView()
    
    var nameTextField = UITextField()
    var goalTextField = UITextField()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configuare()
    }
    
    private func configuare() {
        scrollView.frame = holderView.bounds
        holderView.addSubview(scrollView)
        
        let titleText = ["Welcome!","Let us know more about you.","Notification","Last!"]
        let messageText = ["Let's start your new reading journey.","What is your name?","Let's develop reading as a hobby!","Set your daily reading goal."]
        
        for x in 0..<4{
            let pageView = UIView(frame: CGRect(x: CGFloat(x) * holderView.frame.size.width, y: 0, width: holderView.frame.size.width, height: holderView.frame.size.height))
            scrollView.addSubview(pageView)
            
            let title = UILabel(frame: CGRect(x: 10, y: 10, width: pageView.frame.size.width - 20, height: 90))
            
            let message = UILabel(frame: CGRect(x: 10, y: 90, width: pageView.frame.size.width - 20, height: 90))
            
            let image = UIImageView(frame: CGRect(x: 10, y: 250, width: pageView.frame.size.width - 20, height: pageView.frame.size.height - 330 - 70))
            
            let button = UIButton(frame: CGRect(x: 90, y: pageView.frame.size.height-70, width: pageView.frame.size.width - 180, height: 50))
            
            if x == 1 {
                image.contentMode = .scaleAspectFit
                nameTextField = UITextField(frame: CGRect(x: 20, y: 180, width: pageView.frame.size.width - 40, height: 45))
                nameTextField.placeholder = "Name"
                nameTextField.font = UIFont.systemFont(ofSize: 20)
                nameTextField.borderStyle = UITextField.BorderStyle.roundedRect
                nameTextField.autocorrectionType = UITextAutocorrectionType.no
                nameTextField.keyboardType = UIKeyboardType.default
                nameTextField.returnKeyType = UIReturnKeyType.done
                nameTextField.clearButtonMode = UITextField.ViewMode.whileEditing
                nameTextField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
                nameTextField.textAlignment = .center
                nameTextField.delegate = self
                pageView.addSubview(nameTextField)
            }
            
            if x == 3{
                
                goalTextField = UITextField(frame: CGRect(x: 20, y: 200, width: pageView.frame.size.width - 40, height: 45))
                goalTextField.placeholder = "Minute(s)"
                goalTextField.font = UIFont.systemFont(ofSize: 20)
                goalTextField.borderStyle = UITextField.BorderStyle.roundedRect
                goalTextField.autocorrectionType = UITextAutocorrectionType.no
                goalTextField.keyboardType = UIKeyboardType.default
                goalTextField.returnKeyType = UIReturnKeyType.done
                goalTextField.clearButtonMode = UITextField.ViewMode.whileEditing
                goalTextField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
                goalTextField.textAlignment = .center
                goalTextField.delegate = self
                pageView.addSubview(goalTextField)
                
            }
            
            title.textAlignment = .center
            title.textColor = .systemOrange
            title.numberOfLines = 0
            title.font = UIFont(name: "Helvetica-Bold", size: 32)
            pageView.addSubview(title)
            title.text = titleText[x]
            
            message.textAlignment = .center
            message.numberOfLines = 0
            message.font = UIFont(name: "Helvetica-Bold", size: 32)
            pageView.addSubview(message)
            message.text = messageText[x]
            
            image.contentMode = .scaleAspectFit
            image.image = UIImage(named: "welcome\(x)")
            pageView.addSubview(image)
            
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 20
            button.layer.masksToBounds = true
            button.backgroundColor = .purple
            button.setTitle("Next", for: .normal)
            if x == 3{
                button.setTitle("Get Started", for: .normal)
            }
            button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
            button.tag = x+1
            pageView.addSubview(button)
        }
        
        scrollView.contentSize = CGSize(width: holderView.frame.size.width * 4, height: 0)
        scrollView.isPagingEnabled = true
        
    }
    
    @objc func didTapButton(_ button: UIButton){
        
        if button.tag == 3{
            
            //
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
              UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
              )
            
            //
            
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert,.sound,.badge]) { granted, error in
                if let error = error {
                    print(error)
                }
            }
            let content = UNMutableNotificationContent()
            content.title = "Your reading partner is waiting for you!"
            content.body = "Spend 10 minutes and read with me. Tap Me Now!"
            content.sound = UNNotificationSound.default
            
            let date = Date().addingTimeInterval(70)
            
            let dateComponents = Calendar.current.dateComponents([.hour,.minute,.second], from: date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let uuidString = UUID().uuidString
            
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print(error)
                }
            }
        }
        
        guard button.tag < 4 else {
            Core.shared.setIsNotNewUser()
            dismiss(animated: true, completion: nil)
            return
        }
        //scroll to next page
        scrollView.setContentOffset(CGPoint(x: holderView.frame.size.width * CGFloat(button.tag), y: 0), animated: true)
    }
    
//    func dismiss(){
//        Core.shared.setIsNotNewUser()
//        dismiss(animated: true, completion: nil)
//    }
    
    

}

extension WelcomeViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField{
            if textField.text?.count != 0 {
                UserDefaults.standard.set(textField.text,forKey: "Name")
                textField.resignFirstResponder()
            }
        } else if textField == goalTextField{
            if textField.text?.count != 0 {
                UserDefaults.standard.setValue(Int(textField.text!), forKey: "ReadingGoal")
                textField.resignFirstResponder()
            }
        }
        return true
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == goalTextField{
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
                let compSepByCharInSet = string.components(separatedBy: aSet)
                let numberFiltered = compSepByCharInSet.joined(separator: "")
                return string == numberFiltered
        } else {
            return true
        }
    }
    
}
