//
//  Image+Extension.swift
//  RF_localRepo
//
//  Created by zrf on 2021/6/8.
//

import UIKit


public extension UIImage {
    /// SwifterSwift: UIImage with .alwaysOriginal rendering mode.
    //颜色渲染
    var original: UIImage {
        return withRenderingMode(.alwaysOriginal)
    }
    
    /// SwifterSwift: Size in bytes of UIImage.
    var bytesSize: Int {
        return jpegData(compressionQuality: 1)?.count ?? 0
    }
    var kb: Int {return (jpegData(compressionQuality: 1)?.count ?? 0) / 1024}
    #if canImport(CoreImage)
    /// SwifterSwift: Average color for this image.
    func averageColor() -> UIColor? {
        // https://stackoverflow.com/questions/26330924
        guard let ciImage = ciImage ?? CIImage(image: self) else { return nil }

        // CIAreaAverage returns a single-pixel image that contains the average color for a given region of an image.
        let parameters = [kCIInputImageKey: ciImage, kCIInputExtentKey: CIVector(cgRect: ciImage.extent)]
        guard let outputImage = CIFilter(name: "CIAreaAverage", parameters: parameters)?.outputImage else {
            return nil
        }

        // After getting the single-pixel image from the filter extract pixel's RGBA8 data
        var bitmap = [UInt8](repeating: 0, count: 4)
        let workingColorSpace: Any = cgImage?.colorSpace ?? NSNull()
        let context = CIContext(options: [.workingColorSpace: workingColorSpace])
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)

        // Convert pixel data to UIColor
        return UIColor(red: CGFloat(bitmap[0]) / 255.0,
                       green: CGFloat(bitmap[1]) / 255.0,
                       blue: CGFloat(bitmap[2]) / 255.0,
                       alpha: CGFloat(bitmap[3]) / 255.0)
    }
    #endif
    /// SwifterSwift: Compressed UIImage data from original UIImage.
    ///
    /// - Parameter quality: The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality), (default is 0.5).
    /// - Returns: optional Data (if applicable).
    func compressedData(quality: CGFloat = 0.5) -> Data? {
        return jpegData(compressionQuality: quality)
    }
    /// SwifterSwift: Compressed UIImage from original UIImage.
    ///
    /// - Parameter quality: The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality), (default is 0.5).
    /// - Returns: optional UIImage (if applicable).
    func compressed(quality: CGFloat = 0.5) -> UIImage? {
        guard let data = compressedData(quality: quality) else { return nil }
        return UIImage(data: data)
    }
    //压缩图片
    //toByte: 目标大小
    //isResize: 是否自动更新图片大小。默认为true 当为true时，图片长宽比大于6或小于1.0/6时自动将图片一边处理为屏幕大小*0.8
    func compress(toByte : Int = 600 * 1024, isResize: Bool = true) -> Data? {
        autoreleasepool {
            let newImage = self
//            if isResize {
//                if newImage.size.width / newImage.size.height > 6 {  //大宽图
//                    if newImage.size.height > UIScreen.main.bounds.size.height*0.8 {
//                        let ratio = newImage.size.height / (UIScreen.main.bounds.size.height*0.8)
//                        newImage = resizeImage(newSize: CGSize(width: self.size.width*ratio, height: self.size.height*ratio))
//                    }
//                }else if newImage.size.width / newImage.size.height < 1.0/6.0 {
//                    if newImage.size.width > UIScreen.main.bounds.size.width*0.8 {
//                        let ratio = newImage.size.width / (UIScreen.main.bounds.size.width*0.8)
//                        newImage = resizeImage(newSize: CGSize(width: self.size.width*ratio, height: self.size.height*ratio))
//                    }
//                }
//            }
            var compressByte = toByte
            
            // ⚠️ 转长图特殊处理
            if toByte == 30 * 1024 { compressByte = 30 * 1024 * 1024 }
            
            let byte = compressByte
            var compression: CGFloat = 1
            guard var data = newImage.jpegData(compressionQuality: compression) else { return nil}
            
            // 若原图小于限制大小,则直接返回,不做压缩处理;
            if data.count <= toByte { return data }
            
            print("压缩前", data.count, "byte")
            var max: CGFloat = 1
            var min: CGFloat = 0
            
            // 旋转 循环压缩  会糊
            if Float(data.count) / Float(byte) < 1.2 {
                return data
            }
            // 减少 压缩比例
            if Float(data.count) / Float(byte) < 1.5 {
                min = 0.8
            } else {
                for _ in 0..<6 {
                    compression = (max + min) / 2
                    data = newImage.jpegData(compressionQuality: compression)!
                    if CGFloat(data.count) < CGFloat(byte) * 0.9 {
                        min = compression
                    }else if data.count > byte {
                        max = compression
                    }else {
                        break
                    }
                }
            }
            
            if data.count < byte {
                print("压缩后", data.count, "byte")
                return data
            }
     
            var resultImage: UIImage = UIImage(data: data)!
            var lastDataLength: Int = 0
            while data.count > byte, data.count != lastDataLength {
                lastDataLength = data.count
                let ratio: CGFloat = CGFloat(byte) / CGFloat(data.count)
                let size: CGSize = CGSize(width: Int(resultImage.size.width * sqrt(ratio)),
                                        height: Int(resultImage.size.height * sqrt(ratio)))
                UIGraphicsBeginImageContext(size)
                resultImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                resultImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                data = resultImage.jpegData(compressionQuality: 1)!
            }
            
            print("resize压缩后", data.count, "byte")
            return data
        }
    }
    // 获取一张新的尺寸的图片. 内部自动等比例对齐
    func resizeImage(newSize: CGSize) -> UIImage {
        autoreleasepool {
            var newSize = newSize
            if self.size.width > self.size.height {
                newSize.height = newSize.width * self.size.height / self.size.width
            } else {
                newSize.width = newSize.height * self.size.width / self.size.height
            }
            
            UIGraphicsBeginImageContext(newSize)
            self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage ?? UIImage()
        }
    }
    func rotated(on degrees: CGFloat) -> UIImage {
        
        let degrees = round(degrees / 90) * 90
        let sameOrientationType = Int(degrees) % 180 == 0
        let radians = .pi * degrees / CGFloat(180)
        let newSize = sameOrientationType ? size : CGSize(width: size.height, height: size.width)

        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        defer {
          UIGraphicsEndImageContext()
        }
        guard let ctx = UIGraphicsGetCurrentContext(), let cgImage = cgImage else {
          return self
        }

        ctx.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        ctx.rotate(by: radians)
        ctx.scaleBy(x: 1, y: -1)
        let origin = CGPoint(x: -(size.width / 2), y: -(size.height / 2))
        let rect = CGRect(origin: origin, size: size)
        ctx.draw(cgImage, in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image ?? self
    }
    /// SwifterSwift: UIImage Cropped to CGRect.
    ///
    /// - Parameter rect: CGRect to crop UIImage to.
    /// - Returns: cropped UIImage
    func cropped(to rect: CGRect) -> UIImage {
        guard rect.size.width <= size.width, rect.size.height <= size.height else { return self }
        let scaledRect = rect.applying(CGAffineTransform(scaleX: scale, y: scale))
        guard let image = cgImage?.cropping(to: scaledRect) else { return self }
        return UIImage(cgImage: image, scale: scale, orientation: imageOrientation)
    }
    //修复图片方向
    func fixImageOrientation() -> UIImage {
       guard let cgImage = self.cgImage else {
           return self
       }
       if self.imageOrientation == .up {
           return self
       }
       let width  = self.size.width
       let height = self.size.height

       var transform = CGAffineTransform.identity

       switch self.imageOrientation {
       case .down, .downMirrored:
           transform = transform.translatedBy(x: width, y: height)
           transform = transform.rotated(by: CGFloat.pi)

       case .left, .leftMirrored:
           transform = transform.translatedBy(x: width, y: 0)
           transform = transform.rotated(by: 0.5*CGFloat.pi)

       case .right, .rightMirrored:
           transform = transform.translatedBy(x: 0, y: height)
           transform = transform.rotated(by: -0.5*CGFloat.pi)

       case .up, .upMirrored:
           break
       @unknown default:
            return self
       }

       switch self.imageOrientation {
       case .upMirrored, .downMirrored:
           transform = transform.translatedBy(x: width, y: 0)
           transform = transform.scaledBy(x: -1, y: 1)

       case .leftMirrored, .rightMirrored:
           transform = transform.translatedBy(x: height, y: 0)
           transform = transform.scaledBy(x: -1, y: 1)

       default:
           break;
       }
       guard let colorSpace = cgImage.colorSpace else {
           return self
       }
       guard let context = CGContext(
           data: nil,
           width: Int(width),
           height: Int(height),
           bitsPerComponent: cgImage.bitsPerComponent,
           bytesPerRow: 0,
           space: colorSpace,
           bitmapInfo: UInt32(cgImage.bitmapInfo.rawValue)
           ) else {
               return self
       }

       context.concatenate(transform);
       switch self.imageOrientation {
       case .left, .leftMirrored, .right, .rightMirrored:
           context.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
       default:
           context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
       }

       guard let newCGImg = context.makeImage() else {
           return self
       }

       let img = UIImage(cgImage: newCGImg)
       return img;
    }
    /// SwifterSwift: UIImage with rounded corners.
    ///
    /// - Parameters:
    ///   - radius: corner radius (optional), resulting image will be round if unspecified.
    /// - Returns: UIImage with all corners rounded.
    //圆角处理
    func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        if let radius = radius, radius > 0, radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        draw(in: rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    /// SwifterSwift: Base 64 encoded PNG data of the image.
    ///
    /// - Returns: Base 64 encoded PNG data of the image as a String.
    func pngBase64String() -> String? {
        return pngData()?.base64EncodedString()
    }

    /// SwifterSwift: Base 64 encoded JPEG data of the image.
    ///
    /// - Parameter: compressionQuality: The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality).
    /// - Returns: Base 64 encoded JPEG data of the image as a String.
    func jpegBase64String(compressionQuality: CGFloat) -> String? {
        return jpegData(compressionQuality: compressionQuality)?.base64EncodedString()
    }
}

// MARK: - Initializers

public extension UIImage {
    /// SwifterSwift: Create UIImage from color and size.
    ///
    /// - Parameters:
    ///   - color: image fill color.
    ///   - size: image size.
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)

        defer {
            UIGraphicsEndImageContext()
        }

        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))

        guard let aCgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }

        self.init(cgImage: aCgImage)
    }

    /// SwifterSwift: Create a new image from a base 64 string.
    ///
    /// - Parameters:
    ///   - base64String: a base-64 `String`, representing the image
    ///   - scale: The scale factor to assume when interpreting the image data created from the base-64 string. Applying a scale factor of 1.0 results in an image whose size matches the pixel-based dimensions of the image. Applying a different scale factor changes the size of the image as reported by the `size` property.
    convenience init?(base64String: String, scale: CGFloat = 1.0) {
        guard let data = Data(base64Encoded: base64String) else { return nil }
        self.init(data: data, scale: scale)
    }

    /// SwifterSwift: Create a new image from a URL
    ///
    /// - Important:
    ///   Use this method to convert data:// URLs to UIImage objects.
    ///   Don't use this synchronous initializer to request network-based URLs. For network-based URLs, this method can block the current thread for tens of seconds on a slow network, resulting in a poor user experience, and in iOS, may cause your app to be terminated.
    ///   Instead, for non-file URLs, consider using this in an asynchronous way, using `dataTask(with:completionHandler:)` method of the URLSession class or a library such as `AlamofireImage`, `Kingfisher`, `SDWebImage`, or others to perform asynchronous network image loading.
    /// - Parameters:
    ///   - url: a `URL`, representing the image location
    ///   - scale: The scale factor to assume when interpreting the image data created from the URL. Applying a scale factor of 1.0 results in an image whose size matches the pixel-based dimensions of the image. Applying a different scale factor changes the size of the image as reported by the `size` property.
    convenience init?(url: URL, scale: CGFloat = 1.0) throws {
        let data = try Data(contentsOf: url)
        self.init(data: data, scale: scale)
    }
}
