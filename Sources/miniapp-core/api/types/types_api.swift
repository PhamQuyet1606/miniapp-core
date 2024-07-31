//
//  types.swift
//  miniapp-core
//
//  Created by Stany Bluebik on 22/07/2024.
//

import Foundation

public struct AuthToken {
    let accessToken: String
    let refreshToken: String
    
    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

public struct APIConfig {
    let baseURL: String
    let timeout: TimeInterval
    let headers: [String: String]?
    let isCancelWhenRouterChange: Bool
    
    public init(baseURL: String, timeout: TimeInterval, headers: [String : String]?, isCancelWhenRouterChange: Bool) {
        self.baseURL = baseURL
        self.timeout = timeout
        self.headers = headers
        self.isCancelWhenRouterChange = isCancelWhenRouterChange
    }
}




