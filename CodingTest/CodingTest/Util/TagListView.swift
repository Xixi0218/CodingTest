//
//  TagListView.swift
//  CodingTest
//
//  Created by Ye Keyon on 2024/12/29.
//

import UIKit

protocol TagListViewReusable: UIView {
    func calculateWidth() -> CGFloat
    func calculateHeight() -> CGFloat
    static var reuseIdentifier: String { get }
}

protocol TagListViewDataSource: AnyObject {
    func tagListView(_ tagListView: TagListView, forItemAt index: Int) -> TagListViewReusable
    func numberOfItems(in tagListView: TagListView) -> Int
}

class TagListView: UIView {
    
    
    
    var minimumLineSpacing: CGFloat = 10.0
    
    var minimumInteritemSpacing: CGFloat = 10.0
    
    var contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    var tagsViewWidth = UIScreen.main.bounds.width
    
    weak var dataSource: TagListViewDataSource?
    
    private var displayViews = [TagListViewReusable]()
    
    private var reuseViews = [TagListViewReusable]()
    
    private var identifiers = [String: AnyClass]()
    
    private var contentSize = CGSize.zero
    
    
    func reloadData() -> Void {
        
        var tagX: CGFloat = contentInset.left
        var tagY: CGFloat = contentInset.top
        var tagW: CGFloat = 0.0
        var tagH: CGFloat = 0.0
        
        var lastView: TagListViewReusable?
        
        prepareForReuse()
        
        for subView in displayViews {
            
            tagW = subView.calculateWidth()
            tagH = subView.calculateHeight()
            
            if let lastView = lastView {
                if lastView.frame.maxX + contentInset.right + minimumInteritemSpacing + tagW > tagsViewWidth {
                    tagX = contentInset.left
                    tagY = lastView.frame.maxY + minimumLineSpacing
                }else {
                    tagX = lastView.frame.maxX + minimumInteritemSpacing
                }
            }
            
            subView.frame = CGRect(x: tagX, y: tagY, width: tagW, height: tagH)
            lastView = subView
        }
        
        let sumHeight: CGFloat = lastView?.frame.maxY ?? 0
        let viewContentSize = CGSize(width: tagsViewWidth, height: sumHeight)
        
        frame.size.height = sumHeight
        
        if (!contentSize.equalTo(viewContentSize)) {
            contentSize = viewContentSize;
            invalidateIntrinsicContentSize()
        }
        
    }
    
    func prepareForReuse() {
        guard let dataSource = dataSource else { return }
        let labelsCount = dataSource.numberOfItems(in: self)
        let displayCount = displayViews.count
        
        if labelsCount < displayCount {
            let diff = displayCount - labelsCount
            var rangeViews = displayViews[0..<diff]
            for _ in 0..<diff {
                let view = rangeViews.removeLast()
                appendReuseView(view)
            }
        }
        
        for index in 0..<labelsCount {
            let label = dataSource.tagListView(self, forItemAt: index)
            addView(label)
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return contentSize
    }
}

extension TagListView {
    func registerLabelClass<T>(ofType type: T.Type) where T: TagListViewReusable {
        self.identifiers[T.reuseIdentifier] = type.self
    }
}

extension TagListView {
    
    func dequeueReusableLabel<T>(ofType type: T.Type, index: Int) -> T where T: TagListViewReusable {
        return dequeueReusableLabel(withIdentifier: T.reuseIdentifier, index: index) as! T
    }
    
    private func dequeueReusableLabel(withIdentifier identifier: String, index: Int) -> TagListViewReusable {
        if index < displayViews.count {
            let label = displayViews[index]
            return label
        }
        
        if reuseViews.count > 0 {
            let view = reuseViews.removeLast()
            return view
        }
        guard let clas = self.identifiers[identifier] else {
            fatalError("identifier is not register")
        }
        guard let viewClass = clas as? TagListViewReusable.Type else {
            fatalError("class do not comply TagListViewReusable")
        }
        return viewClass.init()
    }
    
    private func addView(_ view: TagListViewReusable) {
        addSubview(view)
        let index = displayViews.lastIndex { tagView in
            return tagView == view
        }
        if index == nil {
            displayViews.append(view)
        }
    }
    
    private func appendReuseView(_ view: TagListViewReusable) {
        view.removeFromSuperview()
        let index = displayViews.lastIndex { tagView in
            return tagView == view
        }
        if let index = index {
            displayViews.remove(at: index)
        }
        reuseViews.append(view)
    }
}

