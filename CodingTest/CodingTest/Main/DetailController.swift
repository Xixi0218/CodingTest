//
//  DetailController.swift
//  CodingTest
//
//  Created by Ye Keyon on 2024/12/29.
//

import UIKit
import WebKit

class DetailController: UIViewController {
    
    let model: ListModel
    private var progressOberver: NSKeyValueObservation?
    
    init(model: ListModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configSubView()
        configData()
    }
    
    private func configData() {
        if let webURL = model.getDetailURL() {
            let request = URLRequest(url: webURL)
            webView.load(request)
        }
        
        
    }
    
    private func configSubView() {
        [webView, progressView].forEach { view.addSubview($0) }
        webView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
        }
        
        progressOberver = webView.observe(\.estimatedProgress, options: [.initial, .new]) { [weak self] webView, _ in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.progressView.progress = Float(webView.estimatedProgress)
            }, completion: { _ in
                self.progressView.isHidden = webView.estimatedProgress == 1
            })
        }
    }
    
    private var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsLinkPreview = false
        return webView
    }()
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.isHidden = true
        view.progressTintColor = .blue
        view.trackTintColor = .gray
        return view
    }()
}
