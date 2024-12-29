//
//  WaterFlowLayout.swift
//  CodingTest
//
//  Created by Ye Keyon on 2024/12/29.
//

import UIKit

class WaterFlowLayout: UICollectionViewFlowLayout {
    
    public var numberOfColumns: Int = 1 {
        didSet {
            invalidateLayout()
        }
    }
    
    public var delegate: UICollectionViewDelegateFlowLayout? {
        get {
            return collectionView?.delegate as? UICollectionViewDelegateFlowLayout
        }
    }
    
    private var columnHeights: [[CGFloat]] = []
    
    private var attributesForSectionItems: [[UICollectionViewLayoutAttributes]] = []
    
    private var attributesForAllElements: [UICollectionViewLayoutAttributes] = []
    
    private var attributesForHeaders: [Int: UICollectionViewLayoutAttributes] = [:]
    private var attributesForFooters: [Int: UICollectionViewLayoutAttributes] = [:]
    
    private var unionRects: [CGRect] = []
    private let unionSize = 20
    
    public override func prepare() {
        super.prepare()
        
        let numberOfSections = collectionView?.numberOfSections ?? 0
        guard numberOfSections > 0 else {
            return
        }
        
        attributesForHeaders = [:]
        attributesForFooters = [:]
        unionRects = []
        attributesForAllElements = []
        attributesForSectionItems = .init(repeating: [], count: numberOfSections)
        columnHeights = .init(repeating: [], count: numberOfSections)
        
        var top: CGFloat = 0
        var attributes = UICollectionViewLayoutAttributes()
        
        for section in 0..<numberOfSections {
            
            let sectionInset = inset(forSection: section)
            let columnSpacing = lineSpacing(forSection: section)
            let interitemSpacing = interitemSpacing(forSection: section)
            let effectiveItemWidth = effectiveItemWidth(inSection: section)
            
            let headerSize = headerReferenceSize(inSection: section)
            if headerSize.height > 0 {
                attributes = UICollectionViewLayoutAttributes(
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    with: IndexPath(row: 0, section: section)
                )
                attributes.frame = CGRect(x: 0, y: top,
                                          width: headerSize.width,
                                          height: headerSize.height)
                
                attributesForHeaders[section] = attributes
                attributesForAllElements.append(attributes)
                
                top = attributes.frame.maxY
            }
            
            top += sectionInset.top
            columnHeights[section] = [CGFloat](repeating: top, count: numberOfColumns)
            
            let numberOfItems = collectionView!.numberOfItems(inSection: section)
            
            for item in 0..<numberOfItems {
                let indexPath = IndexPath(item: item, section: section)
                let currentColumnIndex = columnIndex(forItemAt: indexPath)
                
                let xOffset = sectionInset.left + (effectiveItemWidth + columnSpacing) * CGFloat(currentColumnIndex)
                let yOffset = columnHeights[section][currentColumnIndex]
                
                let referenceItemSize = itemSize(at: indexPath)
                
                attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: yOffset,
                                          width: effectiveItemWidth, height: referenceItemSize.height)
                
                attributesForSectionItems[section].append(attributes)
                attributesForAllElements.append(attributes)
                columnHeights[section][currentColumnIndex] = attributes.frame.maxY + interitemSpacing
            }
            
            let longestLineIndex  = longestColumnIndex(inSection: section)
            top = columnHeights[section][longestLineIndex] - interitemSpacing + sectionInset.bottom
            let footerSize = footerReferenceSize(inSection: section)
            
            if footerSize.height > 0 {
                attributes = UICollectionViewLayoutAttributes(
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                    with: IndexPath(item: 0, section: section)
                )
                attributes.frame = CGRect(x: 0, y: top,
                                          width: footerSize.width,
                                          height: footerSize.height)
                
                attributesForFooters[section] = attributes
                attributesForAllElements.append(attributes)
                
                top = attributes.frame.maxY
            }
            
            columnHeights[section] = [CGFloat](repeating: top, count: numberOfColumns)
        }
        
        let count = attributesForAllElements.count
        var i = 0
        while i < count {
            let rect1 = attributesForAllElements[i].frame
            i = min(i + unionSize, count) - 1
            let rect2 = attributesForAllElements[i].frame
            unionRects.append(rect1.union(rect2))
            i += 1
        }
    }
    
    public override var collectionViewContentSize: CGSize {
        guard collectionView!.numberOfSections > 0,
              let collectionViewContentHeight = columnHeights.last?.first else {
            return .zero
        }
        return .init(width: collectionViewEffectiveContentSize.width, height: collectionViewContentHeight)
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section >= attributesForSectionItems.count {
            return nil
        }
        let list = attributesForSectionItems[indexPath.section]
        if indexPath.item >= list.count {
            return nil
        }
        return list[indexPath.item]
    }
    
    public override func layoutAttributesForSupplementaryView(
        ofKind elementKind: String,
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes {
        var attribute: UICollectionViewLayoutAttributes?
        if elementKind == UICollectionView.elementKindSectionHeader {
            attribute = attributesForHeaders[indexPath.section]
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            attribute = attributesForFooters[indexPath.section]
        }
        return attribute ?? UICollectionViewLayoutAttributes()
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var begin = 0, end = unionRects.count
        
        if let i = unionRects.firstIndex(where: { rect.intersects($0) }) {
            begin = i * unionSize
        }
        if let i = unionRects.lastIndex(where: { rect.intersects($0) }) {
            end = min((i + 1) * unionSize, attributesForAllElements.count)
        }
        return attributesForAllElements[begin..<end]
            .filter { rect.intersects($0.frame) }
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.width != collectionView!.bounds.width
    }
    
    private func columnIndex(forItemAt indexPath: IndexPath) -> Int {
        return shortestColumnIndex(inSection: indexPath.section)
    }
    
    private func shortestColumnIndex(inSection section: Int) -> Int {
        return columnHeights[section].enumerated()
            .min(by: { $0.element < $1.element })?
            .offset ?? 0
    }
    
    private func longestColumnIndex(inSection section: Int) -> Int {
        return columnHeights[section].enumerated()
            .max(by: { $0.element < $1.element })?
            .offset ?? 0
    }
}

extension WaterFlowLayout {
    private var collectionViewEffectiveContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        return collectionView.bounds.size.applyingInset(collectionView.contentInset)
    }
    
    private func effectiveContentWidth(forSection section: Int) -> CGFloat {
        let sectionInset = inset(forSection: section)
        return collectionViewEffectiveContentSize.width - sectionInset.left - sectionInset.right
    }
    
    private func effectiveItemWidth(inSection section: Int) -> CGFloat {
        let columnSpacing = lineSpacing(forSection: section)
        let sectionContentWidth = effectiveContentWidth(forSection: section)
        let width = (sectionContentWidth - (columnSpacing * CGFloat(numberOfColumns - 1))) / CGFloat(numberOfColumns)
        assert(width >= 0, "width必须大于0")
        return width
    }
    
    private func itemSize(at indexPath: IndexPath) -> CGSize {
        let referenceItemSize = delegate?.collectionView?(collectionView!, layout: self, sizeForItemAt: indexPath) ?? itemSize
        return referenceItemSize
    }
    
    private func inset(forSection section: Int) -> UIEdgeInsets {
        return delegate?.collectionView?(collectionView!, layout: self, insetForSectionAt: section) ?? sectionInset
    }
    
    private func lineSpacing(forSection section: Int) -> CGFloat {
        return delegate?.collectionView?(collectionView!, layout: self, minimumLineSpacingForSectionAt: section) ?? minimumLineSpacing
    }
    
    private func interitemSpacing(forSection section: Int) -> CGFloat {
        return delegate?.collectionView?(collectionView!, layout: self, minimumInteritemSpacingForSectionAt: section) ?? minimumInteritemSpacing
    }
    
    private func headerReferenceSize(inSection section: Int) -> CGSize {
        return delegate?.collectionView?(collectionView!, layout: self, referenceSizeForHeaderInSection: section) ?? headerReferenceSize
    }
    
    private func footerReferenceSize(inSection section: Int) -> CGSize {
        return delegate?.collectionView?(collectionView!, layout: self, referenceSizeForFooterInSection: section) ?? footerReferenceSize
    }
}

extension CGSize {
    static func -(lhs: Self, rhs: Self) -> Self {
        return .init(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    
    func applyingInset(_ inset: UIEdgeInsets) -> CGSize {
        return self - CGSize(width: inset.left + inset.right,
                             height: inset.top + inset.bottom)
    }
}
