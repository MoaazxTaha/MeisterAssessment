//
//  Rechability.swift
//  MeisterTaskAssessment
//
//  Created by Moaaz Ahmed Fawzy Taha on 02/02/2022.
//

import Foundation
import Reachability

class NetworkConnection {
    static let shared = NetworkConnection()
    
    let reachability = try! Reachability()
    var isConnected: Bool {
        return reachability.connection != .unavailable
    }
    
    private init() {
        do{
          try reachability.startNotifier()
        } catch let error {
          print("could not start reachability notifier with error:\(error)")
        }
    }
}
