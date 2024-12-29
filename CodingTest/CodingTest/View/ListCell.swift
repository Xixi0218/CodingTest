//
//  ListCell.swift
//  CodingTest
//
//  Created by Ye Keyon on 2024/12/29.
//

import UIKit

class ListCell: UICollectionViewCell {
    
    private var labels: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(model: ListModel) {
        self.labels = model.labels.filter { !$0.contains(":") }
        self.titleLabel.text = model.title
        if let date = dateFormatter.date(from: model.createdAt) {
            self.timeLabel.text = resultDateFormatter.string(from: date)
        } else {
            self.timeLabel.text = model.createdAt
        }
        self.tagView.reloadData()
        self.coverImageView.setImage(with: URL(string: "https://www.arcblock.io/blog/uploads\(model.cover)"), placeholder: nil, cropSize: CGSize(width: (UIScreen.main.bounds.width - 16 - 8) / 2 * UIScreen.main.scale, height: 80 * UIScreen.main.scale))
    }
    
    private func configSubView() {
        [shadowView, bgView].forEach { contentView.addSubview($0) }
        [coverImageView, titleLabel, tagView, timeLabel].forEach { bgView.addSubview($0) }
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        shadowView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        coverImageView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom).offset(8)
            make.left.equalTo(8)
            make.right.equalTo(-8)
        }
        
        tagView.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.top.equalTo(tagView.snp.bottom).offset(8)
        }
    }
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.4
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.textColor = .black
        return label
    }()
    
    private lazy var tagView: TagListView = {
        let view = TagListView()
        view.minimumLineSpacing = 6
        view.minimumInteritemSpacing = 6
        view.tagsViewWidth = (UIScreen.main.bounds.width - 16 - 8) / 2 - 16
        view.dataSource = self
        view.registerLabelClass(ofType: ListTagView.self)
        return view
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }()
    
    private lazy var resultDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd号"
        return dateFormatter
    }()
}

extension ListCell: TagListViewDataSource {
    func tagListView(_ tagListView: TagListView, forItemAt index: Int) -> TagListViewReusable {
        let view = tagListView.dequeueReusableLabel(ofType: ListTagView.self, index: index)
        view.readData(title: labels[index])
        return view
    }
    
    func numberOfItems(in tagListView: TagListView) -> Int {
        return labels.count
    }
}
