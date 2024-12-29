//
//  UIScrollView+Extension.swift
//  CodingTest
//
//  Created by Ye Keyon on 2024/12/29.
//

import UIKit

private var headerKey: Void?
private var footerKey: Void?

extension UIScrollView {
    
    private var header: IndicatorView? {
        get {
            return getAssociatedObject(self, &headerKey)
        }
        set {
            header?.removeFromSuperview()
            setRetainedAssociatedObject(self, &headerKey, newValue)
            newValue.map { insertSubview($0, at: 0) }
        }
    }
    
    private var footer: IndicatorView? {
        get {
            return getAssociatedObject(self, &footerKey)
        }
        set {
            footer?.removeFromSuperview()
            setRetainedAssociatedObject(self, &footerKey, newValue)
            newValue.map { insertSubview($0, at: 0) }
        }
    }
    
    func setHeader(height: CGFloat = 60, action: @escaping () -> Void) {
        header = IndicatorView(style: .header, height: height, action: action)
    }
    
    func setFooter(height: CGFloat = 60, action: @escaping () -> Void) {
        footer = IndicatorView(style: .footer, height: height, action: action)
    }
    
    func endRefreshing() {
        header?.endRefreshing()
        footer?.endRefreshing()
    }
}
