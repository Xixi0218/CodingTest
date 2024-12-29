//
//  Request.swift
//  CodingTest
//
//  Created by Ye Keyon on 2024/12/29.
//

import Foundation

 enum HTTPMethod {
    case get
    case post

    var string: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        }
    }
}

class Request {
    public var method: HTTPMethod
    public let url: String
    public var query: [String: String]?
    public let body: Encodable?
    public var headers: [String: String]?
    
    public init(
        method: HTTPMethod = .get,
        url: String,
        query: [String: String]? = nil,
        body: Encodable? = nil,
        headers: [String: String]? = nil
    ) {
        self.method = method
        self.url = url
        self.query = query
        self.headers = headers
        self.body = body
    }
}
