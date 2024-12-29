//
//  ImageDownloader.swift
//  CodingTest
//
//  Created by Ye Keyon on 2024/12/29.
//

import UIKit
import CommonCrypto

class ImageDownloader {
    
    static let shared = ImageDownloader()
    
    let session = URLSession.shared
    
    @discardableResult
    func downloadImage(from url: URL, cropSize: CGSize?, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
        let key: String
        if let size = cropSize {
            key = (url.absoluteString + "-\(size.width)x\(size.height)").md5()
        } else {
            key = url.absoluteString.md5()
        }
        
        if let image = ImageCache.shared.getImage(forKey: key) {
            performMainThread {
                completion(image)
            }
            return nil
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data, let image = UIImage(data: data) else {
                self?.performMainThread {
                    completion(nil)
                }
                return
            }
            
            if let size = cropSize, let image = self.crop(image: image, to: size) {
                ImageCache.shared.saveCache(image: image, forKey: key)
                self.performMainThread {
                    completion(image)
                }
            } else {
                ImageCache.shared.saveCache(image: image, forKey: key)
                self.performMainThread {
                    completion(image)
                }
            }
            
        }
        
        task.resume()
        return task
    }
    
    private func performMainThread(action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async {
                action()
            }
        }
    }
    
    private func crop(image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }
}

extension String {
    func md5() -> String {
        // 将字符串转换为 Data 类型
        let data = Data(self.utf8)
        
        // 创建一个长度为 16 字节的数组用于存储 MD5 哈希值
        var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        
        // 使用 CommonCrypto 库计算 MD5 哈希
        data.withUnsafeBytes {
            _ = CC_MD5($0.baseAddress, CC_LONG(data.count), &hash)
        }
        
        // 将哈希值转换为十六进制字符串
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
