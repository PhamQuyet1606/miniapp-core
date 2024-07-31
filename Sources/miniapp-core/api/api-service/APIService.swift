//
//  APIService.swift
//  miniapp-core
//
//  Created by Stany Bluebik on 18/07/2024.
//

import Foundation
import Alamofire

final class APIService {
    
    static let shared = APIService()
    
    private(set) var token: AuthToken?
    private(set) var apiConfig: APIConfig?
    
    // Session is roughly equivalent in responsibility to the URLSession instance for calling API request.
    private let session: Session
    
    // APIRequestInterceptor is used to intercept the ongoing request
    private let interceptor = APIRequestInterceptor()
    
    private init() {
        session = Session(interceptor: interceptor)
    }
    
    private func getURL(endpoint: String) -> String {
        guard let baseURL = apiConfig?.baseURL, !baseURL.isEmpty else { return "" }
        return baseURL + endpoint
    }
    
    private func makeRequest<Params: Encodable, Response: Decodable>(
        convertible: URLConvertible,
        method: HTTPMethod,
        params: Params?
    ) async -> Result<Response, Error> {
        await withCheckedContinuation { continuation in
            session.request(convertible, method: method, parameters: params)
                .customValidate()
                .responseDecodable(of: Response.self){ response in
                    let result: Result<Response, Error>
                    switch response.result{
                    case .success(let data):
                        result = .success(data)
                    case .failure(let error):
                        result = .failure(error)
                    }
                    continuation.resume(returning: result)
                }
        }
    }
    
    private func makeRequest(
        convertible: URLConvertible,
        method: HTTPMethod,
        params: Parameters?,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        session.request(convertible, method: method, parameters: params)
            .customValidate()
            .response { response in
                let result: Result<Data, Error>
                switch response.result{
                case .success(let data):
                    if let data {
                        result = .success(data)
                    }
                    else {
                        result = .failure(AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength))
                    }
                    
                case .failure(let error):
                    result = .failure(error)
                }
                completion(result)
            }
    }
    
}

extension APIService: APIProtocol {
    
    func updateAuthToken(token: AuthToken?) {
        self.token = token
    }
    
    func config(apiConfig: APIConfig, token: AuthToken?) {
        self.apiConfig = apiConfig
        if let token {
            self.token = token
        }
        session.sessionConfiguration.timeoutIntervalForRequest = apiConfig.timeout
        session.sessionConfiguration.timeoutIntervalForResource = apiConfig.timeout
    }
    
    func makeAPICall<Params: Encodable, Response: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        params: Params?
    ) async -> Result<Response, Error> {
        let url = getURL(endpoint: endpoint)
        return await makeRequest(convertible: url, method: method, params: params)
    }
    
    func makeAPICall(endpoint: String, method: HTTPMethod, params: Parameters?, completion: @escaping (Result<Data, Error>) -> Void) {
        let url = getURL(endpoint: endpoint)
        makeRequest(convertible: url, method: method, params: params, completion: completion)
    }
    
    func cancelAllRequests(){
        if apiConfig?.isCancelWhenRouterChange == true {
            session.cancelAllRequests()
        }
    }
    
}

extension DataRequest {
    func customValidate() -> Self {
        return self.validate { request, response, data -> Request.ValidationResult in
            let statusCode = response.statusCode
            var errorCode = statusCode
            
            let invalidTokenCodes = ["4011", "4012", "4013"]
            
            if let data, statusCode != 401 {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] ?? [:]
                    let code = json["code"] as? String ?? ""
                    if invalidTokenCodes.contains(code) {
                        errorCode = Int(code)!
                    }
                    else {
                        return .success(())
                    }
                }
                catch {}
            }
            
            return .failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: errorCode)))
        }
    }
}
