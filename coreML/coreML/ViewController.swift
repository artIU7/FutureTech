//
//  ViewController.swift
//  coreML
//
//  Created by  brazilec22 on 26.07.2020.
//  Copyright © 2020  brazilec22. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import coreML
class ViewController: UIViewController {
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var resultView: UIView!
    private var maskLayer = [CAShapeLayer]()

    let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    let captureQueue = DispatchQueue(label: "captureQueue")
    var visionRequests = [VNRequest]()
    private var detectionOverlay: CALayer! = nil
    var rootLayer: CALayer! = nil
    var bufferSize: CGSize = .zero
    var posX = CGFloat()
    var posY = CGFloat()

    override func viewDidLoad() {
        super.viewDidLoad()
        posX = view.frame.maxX
        posY = view.frame.maxY
        guard let camera = AVCaptureDevice.default(for: .video) else {
            return
        }
        do {
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            resultView.layer.addSublayer(previewLayer)
            rootLayer = resultView.layer
            previewLayer.frame = rootLayer.bounds
            rootLayer.addSublayer(previewLayer)
            
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: captureQueue)
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

            session.sessionPreset = .high
            session.addInput(cameraInput)
            session.addOutput(videoOutput)

            let connection = videoOutput.connection(with: .video)
            connection?.videoOrientation = .portrait
            session.startRunning()
            guard let visionModel = try? VNCoreMLModel(for: Inceptionv3().model)
                else {
                fatalError("Could not load model")
            }

            let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleClassifications)
            classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop//VNImageCropAndScaleOptionCenterCrop
            visionRequests = [classificationRequest]
            } catch {
            let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        let layer = CAShapeLayer()
        let rect =  CGRect(x: 250 - 50, y: 100, width: 100, height: 100)//CGRect(x: posX/2 - 50, y: posY/2, width: 100, height: 100)
        layer.path = UIBezierPath(roundedRect: rect, cornerRadius: 0).cgPath
        layer.fillColor = UIColor.red.cgColor
        layer.opacity = 0.5
        
        resultView.layer.addSublayer(layer)
        
        //let shapeLayer = self.createRoundedRectLayerWithBounds(rect)
        
//        resultView.layer.addSublayer(shapeLayer)

        

        
       // self.setupLayers()
       // self.updateLayerGeometry()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.frame
    }

    private func handleClassifications(request: VNRequest, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let results = request.results as? [VNClassificationObservation] else {
            print("No results")
            return
        }
        //print("Classification results: \(results)")
        var resultString = "-"
        //self.drawVisionRequestResults(results)
        results[0...3].forEach {
            let identifer = $0.identifier.lowercased()
            let confidence = $0.confidence
            if identifer == "paper towel" {
                //let bounds = CGRect(x: view.frame.maxX/2 - 50, y: view.frame.maxY/2, width: 150, height: 150)
                self.updateMainLayer(/*layer: layer*/)
                resultString = "\(identifer) : \(confidence)"
            }
           // if identifer.range(of: "cat") != nil || identifer.range(of: "cat") != nil || //identifer == "cat" {
    //out            print("id results: \(identifer) - \(confidence)")
           // }
        }
        DispatchQueue.main.async {
            self.resultLabel.text = resultString
        }
    }
    func updateMainLayer(/*layer : CALayer*/) {
        let layer = CAShapeLayer()
        let rect = CGRect(x: 250 - 50, y: 100, width: 100, height: 100)
        print(rect)
        layer.path = UIBezierPath(roundedRect: rect, cornerRadius: 0).cgPath
        layer.fillColor = UIColor.blue.cgColor
        layer.opacity = 0.5
        self.resultView.layer.addSublayer(layer)
    }
    func drawVisionRequestResults(_ results: [Any]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
      //  print("out for :: \(results)")
        
     //    print("type : \(type(of: results))")
        guard let observations = results as? [VNClassificationObservation] else { print("is VNCoreMLFeatureValueObservation")
            return
        }
     //   print("type array : \(type(of: observations))")
            for observation in observations /* where observation is VNRecognizedObjectObservation */{
                guard let objectObservation = observation as? VNClassificationObservation else {
       //         print("is Observation None")
                continue }
            // Select only the label with the highest confidence.
                       let topLabelObservation = objectObservation//objectObservation.labels[0]
                       let objectBounds = VNImageRectForNormalizedRect(CGRect(x: 0.0,
                                                                                         y: 0.0,
                                  width: bufferSize.width + 1.0,
                                  height: bufferSize.height + 1.0), Int(bufferSize.width), Int(bufferSize.height))
                       
                       let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
                       
                       let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                                       identifier: topLabelObservation.identifier,
                                                                       confidence: topLabelObservation.confidence)
                       shapeLayer.addSublayer(textLayer)
                       detectionOverlay.addSublayer(shapeLayer)
        }
         
       /*
        for observation in results where observation is VNRecognizedObjectObservation {
     //       print("in for :: \(observation)")
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(CGRect(x: 0.0,
                                                                              y: 0.0,
                       width: bufferSize.width + 1.0,
                       height: bufferSize.height + 1.0), Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
            
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)
            shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
        } */
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
           let shapeLayer = CALayer()
           shapeLayer.bounds = bounds
           shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
           shapeLayer.name = "Found Object"
           shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
           shapeLayer.cornerRadius = 7
           return shapeLayer
       }
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
           let textLayer = CATextLayer()
           textLayer.name = "Object Label"
           let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
           let largeFont = UIFont(name: "Helvetica", size: 24.0)!
           formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
           textLayer.string = formattedString
           textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
           textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
           textLayer.shadowOpacity = 0.7
           textLayer.shadowOffset = CGSize(width: 2, height: 2)
           textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
           textLayer.contentsScale = 2.0 // retina rendering
           // rotate the layer into screen orientation and scale and mirror
           textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
           return textLayer
       }
    func updateLayerGeometry() {
           let bounds = rootLayer.bounds
           var scale: CGFloat
           
           let xScale: CGFloat = bounds.size.width / bufferSize.height
           let yScale: CGFloat = bounds.size.height / bufferSize.width
           
           scale = fmax(xScale, yScale)
           if scale.isInfinite {
               scale = 1.0
           }
           CATransaction.begin()
           CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
           
           // rotate the layer into screen orientation and scale and mirror
           detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
           // center the layer
           detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
           
           CATransaction.commit()
       }
    func setupLayers() {
        detectionOverlay = CALayer() // container layer that has all the renderings of the observations
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width + 2,
                                         height: bufferSize.height + 2)
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionOverlay)
    }
    
    /// MARK
    private func createLayer(in rect: CGRect) -> CAShapeLayer{
          
          let mask = CAShapeLayer()
          mask.frame = rect
          mask.cornerRadius = 10
          mask.opacity = 0.75
          mask.borderColor = UIColor.yellow.cgColor
          mask.borderWidth = 2.0
          maskLayer.append(mask)
          return mask
      }
      
      func drawFaceboundingBox(face : VNClassificationObservation) {
          
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.view.frame.height)
          
          let translate = CGAffineTransform.identity.scaledBy(x: self.view.frame.width, y: self.view.frame.height)
          
          // The coordinates are normalized to the dimensions of the processed image, with the origin at the image's lower-left corner.
          let facebounds = CGRect(x: 0, y: 0, width: 2, height: 2)
          
          _ = createLayer(in: facebounds)
          
      }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        var requestOptions: [VNImageOption: Any] = [:]
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics: cameraIntrinsicData]
        }

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 1)!, options: requestOptions)
        do {
            try imageRequestHandler.perform(visionRequests)
        } catch {
            print(error)
        }
    }
}

