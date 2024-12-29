//
//  IndicatorView.swift
//  CodingTest
//
//  Created by Ye Keyon on 2024/12/29.
//

import UIKit

enum RefreshStyle {
    case header, footer
}

class IndicatorView: UIView {
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = false
        return view
    }()
    
    let style: RefreshStyle
    let height: CGFloat
    open var action: () -> Void
    
    init(style: RefreshStyle, height: CGFloat, action: @escaping () -> Void) {
        self.style = style
        self.height = height
        self.action = action
        super.init(frame: .zero)
        configSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isRefreshing = false {
        didSet { didUpdateState(isRefreshing) }
    }
    
    private var progress: CGFloat = 0 {
        didSet { didUpdateProgress(progress) }
    }
    
    open func didUpdateState(_ isRefreshing: Bool) {
        isRefreshing ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
    }
    
    open func didUpdateProgress(_ progress: CGFloat) {
        
    }
    
    private var scrollView: UIScrollView? {
        return superview as? UIScrollView
    }
    
    private var offsetToken: NSKeyValueObservation?
    private var stateToken: NSKeyValueObservation?
    private var sizeToken: NSKeyValueObservation?
    
    private func configSubView() {
        [loadingIndicator].forEach { addSubview($0) }
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    override open func didMoveToSuperview() {
        guard let scrollView = scrollView else { return }
        
        offsetToken = scrollView.observe(\.contentOffset) { _, _ in
            self.scrollViewDidScroll(scrollView)
        }
        stateToken = scrollView.panGestureRecognizer.observe(\.state) { pan, _ in
            guard pan.state == .ended else { return }
            self.scrollViewDidEndDragging(scrollView)
        }
        
        if style == .header {
            frame = CGRect(x: 0, y: -height, width: UIScreen.main.bounds.width, height: height)
        } else {
            sizeToken = scrollView.observe(\.contentSize) { _, _ in
                self.frame = CGRect(x: 0, y: scrollView.contentSize.height, width: UIScreen.main.bounds.width, height: self.height)
                self.isHidden = scrollView.contentSize.height <= scrollView.bounds.height
            }
        }
    }
    
    private func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isRefreshing { return }
        
        switch style {
        case .header:
            progress = min(1, max(0, -(scrollView.contentOffset.y + scrollView.contentInset.top) / height))
        case .footer:
            if scrollView.contentSize.height <= scrollView.bounds.height { break }
            progress = min(1, max(0, (scrollView.contentOffset.y + scrollView.bounds.height - scrollView.contentSize.height - scrollView.contentInset.bottom) / height))
        }
    }
    
    private func scrollViewDidEndDragging(_ scrollView: UIScrollView) {
        if isRefreshing || progress < 1 { return }
        beginRefreshing()
    }
    
    func beginRefreshing() {
        guard let scrollView = scrollView, !isRefreshing else { return }
        
        progress = 1
        isRefreshing = true
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                switch self.style {
                case .header:
                    scrollView.contentOffset.y = -self.height - scrollView.contentInset.top
                    scrollView.contentInset.top += self.height
                case .footer:
                    scrollView.contentInset.bottom += self.height
                }
            }, completion: { _ in
                self.action()
            })
        }
    }
    
    func endRefreshing(completion: (() -> Void)? = nil) {
        guard let scrollView = scrollView else { return }
        guard isRefreshing else { completion?(); return }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                switch self.style {
                case .header:
                    scrollView.contentInset.top -= self.height
                case .footer:
                    scrollView.contentInset.bottom -= self.height
                }
            }, completion: { _ in
                self.isRefreshing = false
                self.progress = 0
                completion?()
            })
        }
    }
}
