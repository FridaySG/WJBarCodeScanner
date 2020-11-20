//
//  WJScanViewController.swift
//  BarcodeScanDemo
//
//  Created by wj on 15/12/4.
//  Copyright © 2015年 wj. All rights reserved.
//
import UIKit
import AVFoundation

@IBDesignable
class WJScanViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate{
    
    let session = AVCaptureSession()
    let output = AVCaptureMetadataOutput()
    var input:AVCaptureDeviceInput?

    fileprivate var scanView :WJScanView?
    
    var metadataObjectTypes = [ AVMetadataObject.ObjectType.upce,
                                AVMetadataObject.ObjectType.code39,
                                AVMetadataObject.ObjectType.code39Mod43 ,
                                AVMetadataObject.ObjectType.ean13 ,
                                AVMetadataObject.ObjectType.ean8 ,
                                AVMetadataObject.ObjectType.code93 ,
                                AVMetadataObject.ObjectType.code128 ,
                                AVMetadataObject.ObjectType.pdf417 ,
                                AVMetadataObject.ObjectType.qr ,
                                AVMetadataObject.ObjectType.aztec ,
                                AVMetadataObject.ObjectType.interleaved2of5 ,
                                AVMetadataObject.ObjectType.itf14 ,
                                AVMetadataObject.ObjectType.dataMatrix        ]
        {
        didSet{
            if input != nil{
                output.metadataObjectTypes = metadataObjectTypes
            }
        }
    }
    
    @IBInspectable
    var scanColor:UIColor = UIColor.green{ didSet{  scanView?.scanColor = scanColor } }
    
    var transparentArea = CGRect.zero{
        didSet{
            print("disSet transparentArea to \(transparentArea)")
            scanView?.transparentArea = transparentArea
            output.rectOfInterest = CGRect(x: transparentArea.origin.y/view.frame.height,
                                               y: transparentArea.origin.x/view.frame.width,
                                               width: transparentArea.height/view.frame.height,
                                               height: transparentArea.width/view.frame.width)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        
        guard let device = AVCaptureDevice.default(for: .video) else{
            return
        }
        
        do  {
            input = try AVCaptureDeviceInput(device: device)
        }catch let error as NSError{
            print("WJScanViewController : \n \(error.localizedDescription)")
            return
        }
        
        guard let input = try? AVCaptureDeviceInput(device: device) else{
            return
        }
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        session.sessionPreset = AVCaptureSession.Preset.high
        session.addInput(input)
        session.addOutput(output)
        output.metadataObjectTypes = metadataObjectTypes

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = AVLayerVideoGravity.resize
        preview.frame = view.bounds
        view.layer.insertSublayer(preview, at: 0)
        session.startRunning()
        
        scanView = WJScanView(frame: view.bounds)
        scanView!.scanColor = scanColor
        view.insertSubview(scanView!, at: 1)
        
        //congifure transparentArea
        if transparentArea == CGRect.zero{
            transparentArea = CGRect(x: view.center.x-100, y: view.center.y-100, width: 200, height: 200)
        }else{
            let rect = transparentArea
            transparentArea = rect
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if input == nil{
            handleCameraWithoutAuth()
        }
    }
    
    //override in your subclass
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        print("11")
        if  let metadataObject = metadataObjects.first {
            if let stringValue = (metadataObject as! AVMetadataMachineReadableCodeObject).stringValue{
                print(stringValue)
            }
        }
    }
    
    //Lock Orientations to Portrait
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    //access to camera denied
    func handleCameraWithoutAuth(){
        print("handleCameraWithoutAuth")
    }
    
    
}
