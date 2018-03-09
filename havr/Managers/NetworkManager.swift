//
//  NetworkManager.swift
//  havr
//
//  Created by Personal on 7/8/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import ReachabilitySwift

class NetworkManager: NSObject {
    
    static var reachability = Reachability()!
    
    /// call when app goes in foreground
    static func start() {
        reachability.whenReachable = { instance in
            print("Reachable")
        }
        
        reachability.whenUnreachable = { instance in
            print("Unreachable")
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    /// call when app goes in background
    static func stop() {
        reachability.stopNotifier()
    }
    
    static var isConnected : Bool {
        return reachability.isReachable
    }
}
