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

class scanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

//    @IBOutlet weak var resultQRcode: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    var token: NotificationToken?
    var storedChecks: Results<QrStringInfoObject>?
    var addedString = QrStringInfoObject()
    
    let requestResult = RequestService()

    //    var qrString = "t=20180105T155500&s=2226.73&fn=8710000100911559&i=14618&fp=3957131101&n=1"
    //  var qrString = "t=20180105T155500&s=2226.73&fn=8710000100599785&i=38218&fp=1962650997&n=1"
    //    var qrString = "t=20180105T155500&s=2226.73&fn=8710000101875181&i=38489&fp=75246098&n=1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ("scan view controller did load")
    }

//    func saveCheckItems(checkItems: [CheckInfo], qrString: String) {
//        do {
//            let realm = try Realm()
//            guard let qrString = realm.object(ofType: QrStringInfo.self, forPrimaryKey: qrString) else {return}
//            let oldCheckItems = qrString.checkItems
//            realm.beginWrite()
//            realm.delete(oldCheckItems)
//            qrString.checkItems.append(objectsIn: checkItems)
//            try realm.commitWrite()
//        } catch {
//            print (error)
//        }
//    }
    
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
        print ("got metadataObjects: \(metadataObjects)")

        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        //если засекли qr-код, то пытаемся получить по нему данные
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds
            
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            if metadataObj.stringValue != nil {
                let qrString = metadataObj.stringValue!
                
                //проверяем, что такого чека еще нет в базе
                do {
                    let realm = try Realm()

                    let realmQrString = realm.objects(QrStringInfoObject.self).filter("qrString = %@", qrString).isEmpty
                    //если есть, выдаем ошибку
                    if !realmQrString {
                        activityIndicator.stopAnimating()
                        activityIndicator.isHidden = true
                        showDuplicateAlert(qrString: qrString)
                    }
                    //если нет, пробуем загрузить данные
                    else {
                        RequestService.loadData(receivedString: qrString)
                        getStringFromRealm()
                        print("got string from realm")
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            videoPreviewLayer?.isHidden = true
            qrCodeFrameView?.isHidden = true
            self.captureSession?.stopRunning()
            
        }
    }
    
    //Нотификация о добавлении данных в базу.
    //если была добавлена строка, записываем ее в addedString. Если есть ошибка, выдаем алерт с ошибкой.
    //если ошибки нет, передаем полученную строку на ResultViewController и переходим туда
    func getStringFromRealm() {
        guard let realm = try? Realm() else {return}
        storedChecks = realm.objects(QrStringInfoObject.self)
        token = storedChecks?.observe {[weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial (let results):
                print ("initial results: \(results)")
            case .update(_, _, let insertions, let modifications):
                print("insertions: \(insertions)")
                print("modifications: \(modifications)")
                if insertions != [] {
                    self?.addedString = (self?.storedChecks![insertions[0]])!
                }
                else if modifications != [] {
                    self?.addedString = (self?.storedChecks![modifications[0]])!
                }
                else {
                    print ("no insertions or modifications")
                }
                
                if self?.addedString.error != nil {
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.isHidden = true
                    self?.showErrorAlert((self?.addedString.error!)!)
                    //!!ВОПРОС!! Переходить ли на страницу со списком чеков?
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.performSegue(withIdentifier: "qrResult", sender: nil)
                    print("segue performed")
                }
            case .error(let error):
                print(error)
            }
        }
    }
    
    //алерт с ошибкой о загрузке данных
    func  showErrorAlert(_ error: String) {
        let alert = UIAlertController(title: "Ошибка", message: error, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel, handler: {(action: UIAlertAction) in
            self.videoPreviewLayer?.isHidden = false
            self.qrCodeFrameView?.isHidden = false
            self.captureSession?.startRunning()
        })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //алерт с информацией о том, что такой чек уже существует
    func showDuplicateAlert (qrString: String) {
        let alert = UIAlertController(title: "Ошибка", message: "Чек уже отсканирован", preferredStyle: .alert)
        
        let actionCancel = UIAlertAction(title: "Oтмена", style: .cancel, handler: {(action: UIAlertAction) in
            self.videoPreviewLayer?.isHidden = false
            self.qrCodeFrameView?.isHidden = false
            self.captureSession?.startRunning()
        })
        //если выбираем "Перейти к чеку", то пытаемся загрузить данные
        let actionOk = UIAlertAction(title: "Перейти к чеку", style: .default, handler: {(action: UIAlertAction) in
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            self.getStringInfo(qrStringInfo: qrString)
        })
        
        alert.addAction(actionOk)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
    
    func getStringInfo(qrStringInfo: String) {
        var realmQrString = QrStringInfoObject()
        
        do {
                let realm = try Realm()
            realmQrString = realm.object(ofType: QrStringInfoObject.self, forPrimaryKey: qrStringInfo)!
            } catch {
                print (error)
            }
        
        if (realmQrString.jsonString != nil && realmQrString.jsonString != "null") {
            self.addedString = realmQrString
            performSegue(withIdentifier: "qrResult", sender: nil)
        }
        else {
            RequestService.loadData(receivedString: qrStringInfo)
            self.getStringFromRealm()
            print("got string from realm")
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "qrResult" {
            print("performing segue qrResult")
            let controller = segue.destination as! CheckInfoViewController
            controller.parentString = addedString
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print ("scanView disappears")
        token = nil
    }
    deinit {
        token?.invalidate()
    }
}

