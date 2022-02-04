//
//  Rechability.swift
//  MeisterTaskAssessment
//
//  Created by Moaaz Ahmed Fawzy Taha on 02/02/2022.
//

import Foundation
import Reachability

protocol ReachabilityInterface {
    var isConnected:Bool { get }
}

class NetworkConnection:ReachabilityInterface {
    static let shared = NetworkConnection()
    
    let reachability = try! Reachability()
    
    private init() {
        do{
          try reachability.startNotifier()
        } catch let error {
          print("could not start reachability notifier with error:\(error)")
        }
    }
}

extension NetworkConnection {
var isConnected: Bool {
    return reachability.connection != .unavailable
}
}
