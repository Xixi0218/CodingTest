//
//  Client.swift
//  CodingTest
//
//  Created by Ye Keyon on 2024/12/29.
//

import Foundation

class Client: NSObject {
    let session: URLSession = .shared
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    let baseURL: URL?
    
    init(baseURL: URL?) {
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
        self.baseURL = baseURL
        super.init()
    }
    
    func send<T: Codable>(request: Request) async throws ->  T {
        let (data, response) = try await session.data(for: makeURLRequest(for: request))
        return try decoder.decode(T.self, from: data)
    }
    
    private func makeURLRequest(
        for request: Request
    ) async throws -> URLRequest {
        let url = try makeURL(url: request.url, query: request.query)
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = request.headers
        urlRequest.httpMethod = request.method.string
        if let body = request.body {
            urlRequest.httpBody = try encoder.encode(body)
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil &&
                session.configuration.httpAdditionalHeaders?["Content-Type"] == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        if urlRequest.value(forHTTPHeaderField: "Accept") == nil &&
            session.configuration.httpAdditionalHeaders?["Accept"] == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        return urlRequest
    }
    
    private func makeURL(url: String, query: [String: String]?) throws -> URL {
        func makeURL(path: String) -> URL? {
            guard !path.isEmpty else {
                return baseURL?.appendingPathComponent("/")
            }
            guard let url = URL(string: path) else {
                return nil
            }
            return url.scheme == nil ? baseURL?.appendingPathComponent(path) : url
        }
        guard let url = makeURL(path: url), var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }
        if let query = query, !query.isEmpty {
            components.queryItems = query.map(URLQueryItem.init)
        }
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        return url
    }
}
