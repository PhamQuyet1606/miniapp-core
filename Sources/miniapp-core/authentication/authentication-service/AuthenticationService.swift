//
//  AuthenticationService.swift
//  miniapp-core
//
//  Created by Stany Bluebik on 23/07/2024.
//

import Foundation

final class AuthenticationService {
    
    static let shared = AuthenticationService()
    
    private var authConfig: AuthConfig?
    
    private init() {
        
    }
    
    //MARK: - Authentication
    
    private func authenticate(authService: AuthenticationServiceProtocol ,username: String, password: String) async throws {
        return try await authService.authenticate(username: username, password: password)
    }
    
    //MARK: - Deauthentication
    
    private func deauthenticate(authService: AuthenticationServiceProtocol) async throws {
        return try await authService.deauthenticate()
    }
    
    //MARK: - Refresh Token
    
    private func refreshToken(authService: AuthenticationServiceProtocol) async throws {
        return try await authService.refreshToken()
    }
    
}


extension AuthenticationService: AuthenticationProtocol {
    
    func config(authConfig: AuthConfig) {
        self.authConfig = authConfig
    }
    
    func login(username: String, password: String) async throws {
        guard let baseURL = authConfig?.baseURL else { throw AuthenticationError.invalidAuthURL }
        switch authConfig?.authType {
            
        case .keycloak(let clientID, let clientSecret, let realm):
            let keycloak = KeycloakService(baseURL: baseURL, realm: realm, clientID: clientID, clientSecret: clientSecret)
            return try await authenticate(authService: keycloak, username: username, password: password)
            
        default:
            break
        }
    }
    
    func logout() async throws {
        guard let baseURL = authConfig?.baseURL else { throw AuthenticationError.invalidAuthURL }
        switch authConfig?.authType {
            
        case .keycloak(let clientID, let clientSecret, let realm):
            let keycloak = KeycloakService(baseURL: baseURL, realm: realm, clientID: clientID, clientSecret: clientSecret)
            return try await deauthenticate(authService: keycloak)
            
        default:
            break
        }
    }
    
    func refreshToken() async throws {
        guard let baseURL = authConfig?.baseURL else { throw AuthenticationError.invalidAuthURL }
        switch authConfig?.authType {
            
        case .keycloak(let clientID, let clientSecret, let realm):
            let keycloak = KeycloakService(baseURL: baseURL, realm: realm, clientID: clientID, clientSecret: clientSecret)
            return try await refreshToken(authService: keycloak)
            
        default:
            break
        }
    }
    
    
}
