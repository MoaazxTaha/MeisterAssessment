//
//  APIEndpoint.swift
//  MeisterTaskAssessment
//
//  Created by Moaaz Ahmed Fawzy Taha on 01/02/2022.
//

import Foundation

enum HTTPHeaders: String {
    case Auth
    case ContentType
    
    var key: String {
        switch self {
        case .Auth:
            return "Authorization"
        case .ContentType:
            return "Accept"
        }
    }
    
    var value: String {
        switch self {
        case .Auth:
            return "Bearer 2N6edq_uS3ACq89RhzN2yQtdT5aEhbKgaE5-P9BD3hc"
        case .ContentType:
            return "application/json"
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol Endpoint {
    var base: String { get }
    var path: String { get }
    var prefix: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
}


extension Endpoint {
    var urlComponents: URLComponents {
        var components = URLComponents(string: base)
        components?.path = self.prefix + path
        components?.queryItems = queryItems
        return components!
    }
    
    var request: URLRequest {
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = method.rawValue
        
        //Common Headers for all Requests
        request.addValue(HTTPHeaders.ContentType.value, forHTTPHeaderField: HTTPHeaders.ContentType.key)
        request.addValue(HTTPHeaders.Auth.value, forHTTPHeaderField: HTTPHeaders.Auth.key)
        return request
    }
}
