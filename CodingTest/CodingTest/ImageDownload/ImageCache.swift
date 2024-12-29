//
//  ImageCache.swift
//  CodingTest
//
//  Created by Ye Keyon on 2024/12/29.
//

import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    private var memoryCache = NSCache<NSString, UIImage>()
    private var diskCacheURL: URL?
    
    init() {
        // 设置磁盘缓存目录
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        diskCacheURL = cacheDirectory?.appendingPathComponent("ImageCache")
        
        if let diskCacheURL = diskCacheURL, !FileManager.default.fileExists(atPath: diskCacheURL.path) {
            try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func getImage(forKey key: String) -> UIImage? {
        if let image = memoryCache.object(forKey: key as NSString) {
            return image
        }
        if let fileURL = diskCacheURL?.appendingPathComponent(key),
           let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            return image
        }
        return nil
    }
    
    func saveCache(image: UIImage, forKey key: String) {
        memoryCache.setObject(image, forKey: key as NSString)
        if let fileURL = diskCacheURL?.appendingPathComponent(key),
           let data = image.pngData() {
            try? data.write(to: fileURL)
        }
    }
}
