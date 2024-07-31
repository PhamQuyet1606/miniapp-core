//
//  KeycloakService.swift
//  miniapp-core
//
//  Created by Stany Bluebik on 24/07/2024.
//

import Foundation
import Alamofire

struct KeycloakService {
    private let mainURL: String
    private let clientID: String
    private let clientSecret: String
    
    init(baseURL: String, realm: String, clientID: String, clientSecret: String) {
        self.mainURL = baseURL + realm
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
    
    private func generateToken(parameters: [String: String]) async throws {
        let url = mainURL + "/protocol/openid-connect/token"
        return try await withCheckedThrowingContinuation{ continuation in
            AF.request(
                url,
                method: .post,
                parameters: parameters,
                encoder: URLEncodedFormParameterEncoder(destination: .httpBody)
            )
            .responseDecodable(of: KeycloakResponse.self){ response in
                switch response.result {
                case .success(let data):
                    guard let access_token = data.access_token,
                            let refresh_token = data.refresh_token else {
                        continuation.resume(throwing: AuthenticationError.noTokenGenerated)
                        return
                    }
                    print(access_token)
                    APIService.shared.updateAuthToken(token: AuthToken(accessToken: access_token, refreshToken: refresh_token))
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
     
}

extension KeycloakService: AuthenticationServiceProtocol {
    
    func authenticate(username: String, password: String) async throws {
        
        let parameters: [String: String] = [
            "grant_type": "password",
            "username": username,
            "password": password,
            "client_id": clientID,
            "client_secret": clientSecret
        ]
        
        return try await generateToken(parameters: parameters)
    }
    
    func deauthenticate() async throws {
        let url = mainURL + "/protocol/openid-connect/logout"
        let parameters: [String: String] = [
            "refresh_token": APIService.shared.token?.refreshToken ?? "",
            "client_id": clientID,
            "client_secret": clientSecret
        ]
        return try await withCheckedThrowingContinuation{ continuation in
            AF.request(
                url,
                method: .post,
                parameters: parameters,
                encoder: URLEncodedFormParameterEncoder(destination: .httpBody)
            )
            .response { response in
                switch response.result {
                case .success(_):
                    APIService.shared.updateAuthToken(token: nil)
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func refreshToken() async throws {
        let parameters: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": APIService.shared.token?.refreshToken ?? "",
            "client_id": clientID,
            "client_secret": clientSecret
        ]
        
        return try await generateToken(parameters: parameters)
    }
}
