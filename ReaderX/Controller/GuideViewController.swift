//
//  GuideViewController.swift
//  ReaderX
//
//  Created by Chong Zhuang Hong on 15/08/2021.
//

import UIKit

class GuideViewController: UIViewController {

    let scrollView = UIScrollView()

    @IBOutlet weak var holderView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configuare()
    }

    private func configuare() {
        scrollView.frame = holderView.bounds
        holderView.addSubview(scrollView)

        let titleText = ["Smartest Reading Partner Ever!","Spell it!","Tap it!","Make Revision Easier!","Convert to PDF and Print!","Practice Makes Perfect!"]
        let messageText = ["Ask, listen, and continue reading without typing a word.","Find a word even if you don't know how it's pronounced.","Further understanding, pratical example sentences and more.","All the vocabulary will be saved automatically.","Handy notes in seconds.","Flash card available."]

        for x in 0..<6{
            let pageView = UIView(frame: CGRect(x: CGFloat(x) * holderView.frame.size.width, y: 0, width: holderView.frame.size.width, height: holderView.frame.size.height))
            scrollView.addSubview(pageView)

            let title = UILabel(frame: CGRect(x: 10, y: 10, width: pageView.frame.size.width - 20, height: 90))

            let message = UILabel(frame: CGRect(x: 10, y: 90, width: pageView.frame.size.width - 20, height: 90))

            let image = UIImageView(frame: CGRect(x: 5, y: 230, width: pageView.frame.size.width - 10, height: pageView.frame.size.height - 330 ))

            let button = UIButton(frame: CGRect(x: 90, y: pageView.frame.size.height-70, width: pageView.frame.size.width - 180, height: 50))

            title.textAlignment = .center
            title.textColor = .systemOrange
            title.numberOfLines = 0
            title.font = UIFont(name: "Helvetica-Bold", size: 32)
            pageView.addSubview(title)
            title.text = titleText[x]

            message.textAlignment = .center
            message.numberOfLines = 0
            message.font = UIFont(name: "Helvetica-Bold", size: 23)
            pageView.addSubview(message)
            message.text = messageText[x]

            image.contentMode = .scaleAspectFit
            image.image = UIImage(named: "guide\(x+1)")
            pageView.addSubview(image)

            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 20
            button.layer.masksToBounds = true
            button.backgroundColor = .purple
            button.setTitle("Next", for: .normal)
            if x == 5{
                button.setTitle("Get Started", for: .normal)
            }
            button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
            button.tag = x+1
            pageView.addSubview(button)
            
            if x == 2{
                image.animationImages = animatedImages(for: "guide3")
                image.animationRepeatCount = 0
                image.animationDuration = 3
                image.image = image.animationImages?.first
                image.startAnimating()

            }
        }

        scrollView.contentSize = CGSize(width: holderView.frame.size.width * 6, height: 0)
        scrollView.isPagingEnabled = true
        
    }
    
    @objc func didTapButton(_ button: UIButton){
        
        guard button.tag < 6 else {
            dismiss(animated: true, completion: nil)
            return
        }
        //scroll to next page
        scrollView.setContentOffset(CGPoint(x: holderView.frame.size.width * CGFloat(button.tag), y: 0), animated: true)
    }
    
    //MARK:- Animation
    func animatedImages(for name: String) -> [UIImage] {
        
        var i = 0
        var images = [UIImage]()
        
        while let image = UIImage(named: "\(name)/\(i)") {
            images.append(image)
            i += 1
        }
        return images
    }

}
