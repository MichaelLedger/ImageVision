//
//  ImageTool.swift
//  ImageTest
//
//  Created by Gavin Xiang on 2024/4/25.
//

import Foundation
import Vision
import CoreImage.CIFilterBuiltins

@objcMembers public class ForegroundObjectFilter: NSObject {
    
    @available(iOS 17.0, *) public static func applyVisualEffectCroppedImageDataFromUrl(to imageUrlString: String,croppedToInstancesExtent: Bool = false, result: ((Data?) -> Void)? = nil) {
        ImageProcessQueue.visualEffectToObject.queue.async {
            if let imageUrl = URL(string: imageUrlString) {
                let request = URLRequest(url: imageUrl)
                URLSession.shared.dataTask(with: request) { imageData, resp, error in
                    if error == nil {
                        guard let imageData,
                              let downloadedImage = CIImage(data: imageData, options: [.applyOrientationProperty:true]),
                                let maskCIImage = generateMask(from: downloadedImage, cropped: croppedToInstancesExtent)else {
                            result?(nil)
                            return
                        }
                        DispatchQueue.main.async {
                            result?(UIImage(ciImage: maskCIImage).pngData())
                        }
                    } else {
                        result?(nil)
                    }
                }.resume()
            }
        }
    }
    
    @available(iOS 17.0, *) public static func applyVisualEffectCroppedImageData(to imageData: Data,croppedToInstancesExtent: Bool = false, result: ((Data?) -> Void)? = nil) {
        if let inputImage = CIImage(data: imageData,options: [.applyOrientationProperty:true]) {
            ImageProcessQueue.visualEffectToObject.queue.async {
                guard let maskCIImage = generateMask(from: inputImage, cropped: croppedToInstancesExtent) else {
                    result?(nil)
                    return
                }
                DispatchQueue.main.async {
                    result?(UIImage(ciImage: maskCIImage).pngData())
                }
            }
        } else {
            result?(nil)
        }
    }
    
    @available(iOS 17.0, *) public static func applyVisualEffectCroppedImage(to image: UIImage, result: ((UIImage?) -> Void)? = nil) {
        if let inputImage = CIImage(image: image, options: [.applyOrientationProperty:true]) {
            ImageProcessQueue.visualEffectToObject.queue.async {
                guard let maskCIImage = generateMask(from: inputImage, cropped: true) else {
                    result?(nil)
                    return
                }
                DispatchQueue.main.async {
                    result?(UIImage(ciImage: maskCIImage))
                }
            }
        } else {
            result?(nil)
        }
    }
    
    @available(iOS 17.0, *) public static func applyVisualEffect(to image: UIImage, background: CIColor = .clear, result: ((UIImage?) -> Void)? = nil) {
        if let inputImage = CIImage(image: image, options: [.applyOrientationProperty:true]) {
            ImageProcessQueue.visualEffectToObject.queue.async {
                guard let maskCIImage = generateMask(from: inputImage) else {
                    result?(nil)
                    return
                }
                let backgroundCIImage = CIImage(color: background).cropped(to: maskCIImage.extent)
                if let outputCIImage = compose(inputImage: inputImage, maskImage: maskCIImage, backgroundImage: backgroundCIImage) {
                    DispatchQueue.main.async {
                        result?(UIImage(ciImage: outputCIImage))
                    }
                } else {
                    result?(nil)
                }
            }
        } else {
            result?(nil)
        }
    }
    
    @available(iOS 17.0, *) public static func generateMask(from image: CIImage, cropped: Bool = false) -> CIImage? {
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handle = VNImageRequestHandler(ciImage: image)
        do {
            try handle.perform([request])
        } catch {
            print("get image foreground obejct error:\(error.localizedDescription)")
            return nil
        }
        
        guard let processImageResult = request.results?.first else {
            return nil
        }
        let foregroundObjects = processImageResult.allInstances
        
        do {
            let mask = try processImageResult.generateMaskedImage(ofInstances: foregroundObjects, from: handle, croppedToInstancesExtent: cropped);
            let maskCIImage = CIImage(cvPixelBuffer: mask)
            return maskCIImage
        } catch {
            print("generate foreground objects image failed:\(error.localizedDescription)")
            return nil
        }
    }
    
    public static func compose(inputImage: CIImage, maskImage: CIImage, backgroundImage: CIImage) -> CIImage? {
        let filter = CIFilter.blendWithMask()
        filter.backgroundImage = backgroundImage
        filter.inputImage = inputImage
        filter.maskImage = maskImage
        return filter.outputImage
    }
}

extension ForegroundObjectFilter {
    enum ImageProcessQueue: String {
        case foregroundObject
        case visualEffectToObject
        var queue: DispatchQueue {
            return DispatchQueue(label: queueName)
        }
        
        var queueName: String {
            return rawValue
        }
    }
}

