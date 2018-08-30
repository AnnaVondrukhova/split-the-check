//
//  Alerts.swift
//  SplitTheCheck
//
//  Created by Anya on 29/08/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import Foundation
import UIKit

class Alerts {
    
    //алерт с ошибкой
    static func showErrorAlert(VC: UIViewController, message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel, handler: {(action: UIAlertAction) in
            //Если алерт возник при сканировании чека, дополнительно снова запускаем работу камеры
            if (VC as? ScanViewController) != nil {
                let scanVC = VC as! ScanViewController
                scanVC.videoPreviewLayer?.isHidden = false
                scanVC.qrCodeFrameView?.isHidden = false
                scanVC.captureSession?.startRunning()
            }
        })
        alert.addAction(action)
        VC.present(alert, animated: true, completion: nil)
    }
    
    static func authErrorAlert(VC: UIViewController, message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        
        let actionCancel = UIAlertAction(title: "Oтмена", style: .cancel, handler: {(action: UIAlertAction) in
            //Если алерт возник при сканировании чека, дополнительно снова запускаем работу камеры
            if (VC as? ScanViewController) != nil {
                let scanVC = VC as! ScanViewController
                scanVC.videoPreviewLayer?.isHidden = false
                scanVC.qrCodeFrameView?.isHidden = false
                scanVC.captureSession?.startRunning()
            }
        })
        
        //если выбираем "ОК", то сбрасываем UserDefaults/isLoggedIn и переходим на страницу логина
        let actionOk = UIAlertAction(title: "ОК", style: .default, handler: {(action: UIAlertAction) in
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            VC.present(nextViewController, animated:true, completion:nil)
        })
        alert.addAction(actionOk)
        alert.addAction(actionCancel)
        VC.present(alert, animated: true, completion: nil)
    }

    
}
