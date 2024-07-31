//
//  APIServiceProtocol.swift
//  miniapp-core
//
//  Created by Stany Bluebik on 18/07/2024.
//

import Foundation
import Alamofire

public protocol APIProtocol: AnyObject {
    func config(apiConfig: APIConfig, token: AuthToken?)
    func updateAuthToken(token: AuthToken?)
    func makeAPICall<Params: Encodable, Response: Decodable>(endpoint: String, method: HTTPMethod, params: Params?) async -> Result<Response, Error>
    func cancelAllRequests()
}
