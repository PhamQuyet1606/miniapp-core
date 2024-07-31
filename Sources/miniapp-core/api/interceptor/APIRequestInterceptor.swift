import Alamofire

enum RetryStatusCode: Int {
    case unauthorized = 401
    case forbidden = 403
    case badToken = 4011
    case badGeneratedToken = 4012
    case tokenNotSet = 4013
}

final class APIRequestInterceptor: RequestInterceptor {
    private let retryLimit = 1
    private var isRetrying = false
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        if let token = APIService.shared.token?.accessToken {
            urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        }
        urlRequest.setValue(UUID().uuidString, forHTTPHeaderField: "X-API-KEY")
        let language = APIService.shared.apiConfig?.headers?["Accept-Language"]
        urlRequest.setValue(language, forHTTPHeaderField: "Accept-Language")
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        let response = request.task?.response as? HTTPURLResponse
        
        // If first retry then move forward else do not retry
        guard request.retryCount < self.retryLimit else {
            isRetrying = false
            completion(.doNotRetry)
            return
        }
        
        // if status is 401 & retry is first time then move forward else do not retry
        guard !isRetrying else {
            isRetrying = false
            completion(.doNotRetryWithError(error))
            return
        }
        
        determineError(session: session, error: error, completion: completion)
    }
    
    private func determineError(session: Session, error: Error, completion: @escaping (RetryResult) -> Void) {
        if let afError = error as? AFError {
            switch afError {
            case .responseValidationFailed(let reason):
                self.determineResponseValidationFailed(session: session, reason: reason, completion: completion)
            default:
                completion(.doNotRetryWithError(error))
            }
        }
    }
    
    private func determineResponseValidationFailed(session: Session, reason: AFError.ResponseValidationFailureReason, completion: @escaping (RetryResult) -> Void) {
        switch reason {
        case .unacceptableStatusCode(let code):
            switch code {
            case RetryStatusCode.unauthorized.rawValue,
                RetryStatusCode.forbidden.rawValue,
                RetryStatusCode.badToken.rawValue,
                RetryStatusCode.badGeneratedToken.rawValue,
                RetryStatusCode.tokenNotSet.rawValue:
                Task { // Refreshing token
                    do {
                        try await AuthenticationService.shared.refreshToken()
                        isRetrying = true
                        completion(.retry)
                    }
                    catch {
                        completion(.doNotRetryWithError(error))
                    }
                }
                
            default:
                completion(.doNotRetry)
            }
        default:
            completion(.doNotRetry)
        }
    }
}
