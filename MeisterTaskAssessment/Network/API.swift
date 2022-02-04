//
//  API.swift
//  MeisterTaskAssessment
//
//  Created by Moaaz Ahmed Fawzy Taha on 01/02/2022.
//
import Foundation

typealias SearchQuery = (FilterationParameter,String)

enum API {
    case searchTask(SearchQuery)
}

extension API: Endpoint{
    
    var base: String {
        return Bundle.main.baseURL
    }
    
    var prefix: String {
        switch self {
        case .searchTask:
            return "/search"
        }
        
    }
    
    var path: String {
        switch self {
        case .searchTask:
            return ""
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .searchTask:
            return .post
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case let .searchTask(query):
            return [URLQueryItem(name: "filter", value: "{\"status\":\(String(describing:query.0.value)),\"text\":\"\(query.1)\"}"),
                    URLQueryItem(name: "response_format", value: "object")]
        }
    }
}
