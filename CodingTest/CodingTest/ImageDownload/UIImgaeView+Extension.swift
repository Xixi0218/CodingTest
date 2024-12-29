//
//  UIImgaeView+Extension.swift
//  CodingTest
//
//  Created by Ye Keyon on 2024/12/29.
//

import UIKit

private var taskIdentifierKey: Void?

func getAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer) -> T? {
    if #available(iOS 14, macOS 11, watchOS 7, tvOS 14, *) {
        return objc_getAssociatedObject(object, key) as? T
    } else {
        return objc_getAssociatedObject(object, key) as AnyObject as? T
    }
}

func setRetainedAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer, _ value: T) {
    objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

extension UIImageView {
    var taskIdentifier: URLSessionDataTask? {
        get {
            return getAssociatedObject(self, &taskIdentifierKey)
        }
        set {
            taskIdentifier?.cancel()
            setRetainedAssociatedObject(self, &taskIdentifierKey, newValue)
        }
    }
    
    func setImage(with url: URL?, placeholder: UIImage?, cropSize: CGSize?) {
        if let url = url {
            image = placeholder
            taskIdentifier = ImageDownloader.shared.downloadImage(from: url, cropSize: cropSize) { [weak self] result in
                self?.image = result ?? placeholder
                self?.taskIdentifier = nil
            }
        } else {
            image = placeholder
        }
    }
}
