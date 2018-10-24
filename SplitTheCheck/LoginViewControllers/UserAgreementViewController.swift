//
//  UserAgreementViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 21/08/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit

class UserAgreementViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var policyText: UITextView!
    @IBOutlet var cancelBtn: UIView!
    
    var policyString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedDown))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        let pathToPolicy = Bundle.main.path(forResource: "policy", ofType: "txt")
        print (pathToPolicy!)

        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        do {
            policyString = try String(contentsOfFile: pathToPolicy!)
        } catch {
            print("Unable to open and use policy template file.")
        }
        
        let attributedString = NSMutableAttributedString(string: policyString)
        let range = policyString.range(of: "Политике конфиденциальности Сервиса ФНС")
        let index = policyString.distance(from: policyString.startIndex, to: (range?.lowerBound)!)
        let url = "https://www.gnivc.ru/inf_provision/konfmob/"
        
        attributedString.addAttributes([.link: url], range: NSMakeRange(index, 39))
        policyText.attributedText = attributedString
        policyText.isUserInteractionEnabled = true
        policyText.isEditable = false
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        policyText.setContentOffset(CGPoint.zero, animated: false)
        roundCorners([.topLeft, .topRight], radius: 10)
    }

    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.view.layer.mask = mask
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc func swipedDown () {
        dismiss(animated: true, completion: nil)
    }
    
//    @IBAction func cancelAction(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
//    }
    
}

class partialVC: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        let containerBounds = self.containerView?.bounds
        let origin = CGPoint(x: 0.0, y: 30)
        let size = CGSize(width: (containerBounds?.size.width)! , height: (containerBounds?.size.height)! - 30)
        // Applies the attributes
        let presentedViewFrame: CGRect = CGRect(origin: origin, size: size)
        return presentedViewFrame
    }
    

}
