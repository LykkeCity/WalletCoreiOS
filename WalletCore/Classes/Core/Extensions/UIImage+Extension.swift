//
//  UIImage+Extension.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/3/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
    
    /// Generate qr code UIImage with transperant background
    ///
    /// - Parameters:
    ///   - string: String that will turned into a QR Code
    ///   - color: Front Color of the QR Code
    /// - Returns: QR Code image
    public static func generateQRCode(fromString string: String, withSize size: CGSize, color: UIColor) -> UIImage? {
        guard let data = string.data(using: String.Encoding.ascii) else { return nil }
        
        //QR Filter
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setDefaults()
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        
        // Color code and background
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        colorFilter.setDefaults()
        colorFilter.setValue(qrFilter.outputImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(color: color), forKey: "inputColor0")
        colorFilter.setValue(CIColor(color: UIColor.clear), forKey: "inputColor1")
        
        //Transperant filter
        guard let transparentFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        transparentFilter.setDefaults()
        transparentFilter.setValue(colorFilter.outputImage, forKey: "inputImage")
        
        return transparentFilter.outputImage?.nonInterpolatedImage(withSize: size)
    }
}

fileprivate extension CIImage {
    
    /// Creates an `UIImage` with interpolation disabled and scaled given a scale property
    ///
    /// - parameter withScale:  a given scale using to resize the result image
    ///
    /// - returns: an non-interpolated UIImage
    fileprivate func nonInterpolatedImage(withSize size: CGSize) -> UIImage? {
        // Render the image into a CoreGraphics image
        guard let cgImage: CGImage = CIContext(options: nil).createCGImage(self, from: self.extent) else { return nil }
        //Scale the image usign CoreGraphics
        UIGraphicsBeginImageContext(CGSize(width: size.width, height: size.height))
        guard let context: CGContext = UIGraphicsGetCurrentContext() else { return nil }
        context.interpolationQuality = .none
        
        context.draw(cgImage, in: context.boundingBoxOfClipPath)
        guard let preImage = UIGraphicsGetImageFromCurrentImageContext() else {return nil}
        //Cleaning up .
        UIGraphicsEndImageContext()
        
        guard let preCIImage = preImage.cgImage else { return nil }
        
        return UIImage(cgImage: preCIImage, scale: preImage.scale, orientation: .right)
    }
}

