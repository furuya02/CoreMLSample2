//
//  ViewController.swift
//  CoreMLSample2
//
//  Created by . SIN on 2017/08/09.
//  Copyright © 2017年 SAPPOROWORKS. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var index = 0
    let max = 7

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapChangeButton(_ sender: Any) {
        
        let imageName = String(format: "%03d", index + 1)
        if let image = UIImage(named: imageName) {
            
//            let imageSize:CGSize = CGSize(width: 224, height: 224)
//            imageView.image = image.resize(to: imageSize)
            
            imageView.image = image
            coreMLRequest(image: image)
        }
        index += 1
        if (max <= index) {
            index = 0
        }
    }
    
    func coreMLRequest(image:UIImage) {
        let t = Double(time(nil))
        
        let model = VGG16()
        let imageSize:CGSize = CGSize(width: 224, height: 224)
        let pixelBuffer = image.resize(to: imageSize).pixelBuffer()
        
        guard let pb = pixelBuffer, let output = try? model.prediction(image: pb) else {
            fatalError("error")
        }
        let elapsed = Double(time(nil)) - t
        print("\(output.classLabel)|\(output.classLabelProbs[output.classLabel]!)|\(elapsed)")

//        print("label = \(output.classLabel)")
//        print("probabilityr = \(output.classLabelProbs[output.classLabel]!)")
//        print("elapsed = \(elapsed)")
    }

//    func coreMLRequest(image:UIImage) {
//        let t = Double(time(nil))
//
//        let model = SqueezeNet()
//        let imageSize:CGSize = CGSize(width: 227, height: 227)
//        let pixelBuffer = image.resize(to: imageSize).pixelBuffer()
//
//        guard let pb = pixelBuffer, let output = try? model.prediction(image: pb) else {
//            fatalError("error")
//        }
//        let elapsed = Double(time(nil)) - t
//
//        print("label = \(output.classLabel)")
//        print("probabilityr = \(output.classLabelProbs[output.classLabel]!)")
//        print("elapsed = \(elapsed)")
//    }

//    func coreMLRequest(image:UIImage) {
//        let t = Double(time(nil))
//
//        let model = Resnet50()
//        let imageSize:CGSize = CGSize(width: 224, height: 224)
//        let pixelBuffer = image.resize(to: imageSize).pixelBuffer()
//
//        guard let pb = pixelBuffer, let output = try? model.prediction(image: pb) else {
//            fatalError("error")
//        }
//        let elapsed = Double(time(nil)) - t
//
//        print("label = \(output.classLabel)")
//        print("probabilityr = \(output.classLabelProbs[output.classLabel]!)")
//        print("elapsed = \(elapsed)")
//    }

//    func coreMLRequest(image:UIImage) {
//        let t = Double(time(nil))
//        
//        let model = GoogLeNetPlaces()
//        let imageSize:CGSize = CGSize(width: 224, height: 224)
//        let pixelBuffer = image.resize(to: imageSize).pixelBuffer()
//        
//        guard let pb = pixelBuffer, let output = try? model.prediction(sceneImage: pb) else {
//            fatalError("error")
//        }
//        let elapsed = Double(time(nil)) - t
//        
//        print("label = \(output.sceneLabel)")
//        print("probabilityr = \(output.sceneLabelProbs[output.sceneLabel]!)")
//        print("elapsed = \(elapsed)")
//    }

    
//    func coreMLRequest(image:UIImage) {
//        let t = Double(time(nil))
//
//        let model = Inceptionv3() //GoogLeNetPlaces()
//        let imageSize:CGSize = CGSize(width: 299, height: 299)
//        let pixelBuffer = image.resize(to: imageSize).pixelBuffer()
//
//        guard let pb = pixelBuffer, let output = try? model.prediction(image: pb) else {
//            fatalError("error")
//        }
//        let elapsed = Double(time(nil)) - t
//
//        print("identifier = \(output.classLabel)")
//        print("confidence = \(output.classLabelProbs[output.classLabel]!)")
//        print("elapsed = \(elapsed)")
//    }

}


extension UIImage {
    func resize(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize.width, height: newSize.height), true, 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }

    func pixelBuffer() -> CVPixelBuffer? {
        let width = self.size.width
        let height = self.size.height
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        
        guard let resultPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(resultPixelBuffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(resultPixelBuffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
                                        return nil
        }
        
        context.translateBy(x: 0, y: height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return resultPixelBuffer
    }
}


