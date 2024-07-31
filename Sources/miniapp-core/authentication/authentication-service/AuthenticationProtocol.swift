//
//  AutheticationServiceProtocol.swift
//  miniapp-core
//
//  Created by Stany Bluebik on 23/07/2024.
//

import Foundation

protocol AuthenticationServiceProtocol {
    func authenticate(username: String, password: String) async throws
    func deauthenticate() async throws
    func refreshToken() async throws
}

public protocol AuthenticationProtocol: AnyObject {
    func config(authConfig: AuthConfig)
    func login(username: String, password: String) async throws
    func logout() async throws
}
