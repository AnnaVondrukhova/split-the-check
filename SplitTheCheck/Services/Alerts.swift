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
            //Если алерт возник при сканировании чека, дополнительно прекращаем работу камеры
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

    
}
