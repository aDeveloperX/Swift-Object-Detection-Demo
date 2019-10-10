//
//  ViewController.swift
//  Object Detection
//
//  Created by Yichuan Wang on 10/10/19.
//  Copyright © 2019 Wang Yichuan. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var lblIdentifier: UILabel!
    @IBOutlet weak var lblConfidence: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else{
            return
        }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
         guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
               
               guard let model = try? VNCoreMLModel(for: Resnet50Int8LUT().model) else {return}
               let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
                   
                   
                   guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
                   
                   guard let firstObservation = results.first else {return}
                
                DispatchQueue.main.async(execute: {
                   print(firstObservation.identifier, firstObservation.confidence)
                   self.lblIdentifier.text = firstObservation.identifier
                   self.lblConfidence.text = String(firstObservation.confidence*100) + "%"
                })
               }
               
               try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }


}

