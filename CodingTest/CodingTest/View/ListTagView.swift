//
//  ListTagView.swift
//  CodingTest
//
//  Created by Ye Keyon on 2024/12/29.
//

import UIKit

class ListTagView: UIView, TagListViewReusable {
    
    private var contentRect: CGRect = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configSubView() {
        [bgView].forEach { addSubview($0) }
        [titleLabel].forEach { bgView.addSubview($0) }
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func readData(title: String) {
        titleLabel.text = title
        contentRect = title.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 20), options: [.usesLineFragmentOrigin], attributes: [.font: UIFont.systemFont(ofSize: 12)], context: nil)
        titleLabel.frame = contentRect
    }
    
    func calculateWidth() -> CGFloat {
        return contentRect.width + 12
    }
    
    func calculateHeight() -> CGFloat {
        return 20
    }
    
    static var reuseIdentifier: String = "ListTagView"
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gray.cgColor
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
}
