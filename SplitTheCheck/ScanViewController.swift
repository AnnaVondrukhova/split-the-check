//
//  ViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 25/12/2017.
//  Copyright © 2017 Anna Zhulidova. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation
import RealmSwift

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

//    @IBOutlet weak var resultQRcode: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var waitingLabel: UILabel!
    @IBOutlet weak var waitingView: UIView!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    var token: NotificationToken?
    var storedChecks: Results<QrStringInfoObject>?
    var addedString: QrStringInfoObject?
    var qrString = ""
    
    let requestResult = RequestService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        qrString = "t=20180128T163700&s=3222.80&fn=8710000100599785&i=40518&fp=2860351511&n=1"
        qrString = "t=20180902T154200&s=2412.30&fn=9286000100156559&i=12259&fp=2970651064&n=1"
//        qrString = "t=20180126T185600&s=1576.00&fn=8710000100961732&i=20194&fp=2759156229&n=1"
//        qrString = "t=20180729T100900&s=2402.30&fn=8710000101834587&i=66815&fp=1196724422&n=1"
        
        print ("scan view controller did load")
        activityIndicator.hidesWhenStopped = true
        waitingView.layer.cornerRadius = 10
        waitingView.layer.opacity = 0.8
        
        
//        //проверяем, что такого чека еще нет в базе
//        do {
//            let realm = try Realm()
//
//            let user = realm.object(ofType: User.self, forPrimaryKey: UserDefaults.standard.string(forKey: "user"))
//            print ("qrString = \(qrString)")
//            let realmQrString = user?.checks.filter("qrString = %@", qrString).isEmpty
//            print (realmQrString)
//            //если есть, выдаем ошибку
//            if !realmQrString! {
//                activityIndicator.stopAnimating()
//                waitingLabel.isHidden = true
//                waitingView.isHidden = true
//                showDuplicateAlert(qrString: self.qrString)
//            }
//                //если нет, добавляем строку в базу и пробуем загрузить данные
//            else {
//                RequestService.loadData(receivedString: qrString)
//                RealmServices.getStringFromRealm(VC: self)
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false

        //запускаем камеру
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        //var error: NSError?
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input as AVCaptureInput)

            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)

            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)

            activityIndicator.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
            view.bringSubview(toFront: waitingView)
            view.bringSubview(toFront: waitingLabel)
            view.bringSubview(toFront: activityIndicator)
            waitingLabel.isHidden = true
            waitingView.isHidden = true

            captureSession?.startRunning()
            print ("Capture session started running")
        } catch let error {
            print("\(error.localizedDescription)")
        }

        //вызываем зеленую рамку
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubview(toFront: qrCodeFrameView!)

    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
        }
        captureSession?.stopRunning()
        qrCodeFrameView?.isHidden = true
        print ("got metadataObjects: \(metadataObjects)")

        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        //если засекли qr-код, то пытаемся получить по нему данные
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds


            if (metadataObj.stringValue != nil) && (metadataObj.stringValue?.range(of: "&fn=") != nil)  && (metadataObj.stringValue?.range(of: "&fp=") != nil) && (metadataObj.stringValue?.range(of: "&i=") != nil) {
                qrString = metadataObj.stringValue!
                activityIndicator.startAnimating()
                waitingLabel.isHidden = false
                waitingView.isHidden = false
                print("started activity indicator")

                //проверяем, что такого чека еще нет в базе
                do {
                    let realm = try Realm()

                    let user = realm.object(ofType: User.self, forPrimaryKey: UserDefaults.standard.string(forKey: "user"))
                    print ("qrString = \(qrString)")
                    let realmQrString = user!.checks.filter("qrString = %@", qrString).isEmpty
                    //если есть, выдаем ошибку
                    if !realmQrString {
                        activityIndicator.stopAnimating()
                        waitingLabel.isHidden = true
                        waitingView.isHidden = true
                        showDuplicateAlert(qrString: self.qrString)
                    }
                    //если нет, добавляем строку в базу и пробуем загрузить данные
                    else {
                        RequestService.loadData(receivedString: qrString)
                        RealmServices.getStringFromRealm(VC: self)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                Alerts.showErrorAlert(VC: self, message: "Неправильный формат QR-кода")
            }


        }
    }

    
    //алерт при сканировании с информацией о том, что такой чек уже существует
    func showDuplicateAlert (qrString: String) {
        let alert = UIAlertController(title: "Ошибка", message: "Чек уже отсканирован", preferredStyle: .alert)
        
        let actionCancel = UIAlertAction(title: "Oтмена", style: .cancel, handler: {(action: UIAlertAction) in
            self.videoPreviewLayer?.isHidden = false
            self.qrCodeFrameView?.isHidden = false
            self.captureSession?.startRunning()
        })
        //если выбираем "Перейти к чеку", то пытаемся загрузить данные
        let actionOk = UIAlertAction(title: "Перейти к чеку", style: .default, handler: {(action: UIAlertAction) in
            self.activityIndicator.startAnimating()
            self.waitingLabel.isHidden = false
            self.waitingView.isHidden = false
            print("started activity indicator in showDuplicateAlert")
            RealmServices.getStringInfo(VC: self, token: self.token, qrStringInfo: qrString)
        })
        
        alert.addAction(actionOk)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "qrResult" {
            print("performing segue qrResult")
            let controller = segue.destination as! CheckInfoViewController
            controller.parentString = addedString!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
        print ("scanView disappears")
        token = nil
    }
    deinit {
        token?.invalidate()
    }
}

