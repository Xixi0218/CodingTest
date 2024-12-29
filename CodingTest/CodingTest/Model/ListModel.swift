//
//  ListModel.swift
//  CodingTest
//
//  Created by Ye Keyon on 2024/12/29.
//

import UIKit

class BaseResponse<T: Codable>: Codable {
    var data: T
}

class ListModel: Codable {
    var latestCommenters: [String]
    var id: String
    var title: String
    var labels: [String]
    var lastCommentedAt: String?
    var publishTime: String
    var createdAt: String
    var updatedAt: String
    var cover: String
    var locale: String
    var slug: String
    
    var height: CGFloat = 0
    
    enum CodingKeys: CodingKey {
        case latestCommenters
        case id
        case title
        case labels
        case lastCommentedAt
        case publishTime
        case createdAt
        case updatedAt
        case cover
        case locale
        case slug
    }
    
    func getDetailURL() -> URL? {
        return URL(string: "https://www.arcblock.io/blog/\(locale)/\(slug)")
    }
    
    func getHeight() -> CGFloat {
        if height == 0 {
            let contentWidth = (UIScreen.main.bounds.width - 16 - 8) / 2 - 16
            let titleHeight = min(title.boundingRect(with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], attributes: [.font: UIFont.systemFont(ofSize: 16)], context: nil).height, 39)
            
            var tagX: CGFloat = 0
            var tagY: CGFloat = 0
            var tagW: CGFloat = 0
            var tagH: CGFloat = 0
            var lastViewFrame: CGRect?
            
            
            for label in labels.filter({ !$0.contains(":")}) {
                
                tagW = label.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 20), options: [.usesLineFragmentOrigin], attributes: [.font: UIFont.systemFont(ofSize: 12)], context: nil).width + 12
                tagH = 20
                
                if let lastViewFrame = lastViewFrame {
                    if lastViewFrame.maxX + 0 + 6 + tagW > contentWidth {
                        tagX = 0
                        tagY = lastViewFrame.maxY + 6
                    }else {
                        tagX = lastViewFrame.maxX + 6
                    }
                }
                
                lastViewFrame = CGRect(x: tagX, y: tagY, width: tagW, height: tagH)
            }
            height += (80 + 8 + titleHeight + 8)
            height += (lastViewFrame?.maxY ?? 0) + 8 + 14 + 8
            return height
        }
        return height
    }
}
