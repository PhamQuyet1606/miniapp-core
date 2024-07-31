//
//  EventType.swift
//  miniapp-core
//
//  Created by Stany Bluebik on 16/07/2024.
//

import Foundation
import Alamofire

public enum EventType {
    case navigate(event: String, params: Any?)
    case apiCall(endpoint: String, method: HTTPMethod, params: Parameters?, completion: (Result<Data, Error>) -> Void)
}

