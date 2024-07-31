//
//  Event.swift
//  miniapp-core
//
//  Created by Stany Bluebik on 24/07/2024.
//

import Foundation

final class EventBusService: EventProtocol {
    
    static let shared = EventBusService()
    
    private init() {}
    
    func emit(event: EventType) {
        switch event {
        case .navigate(event: let event, params: let params):
            NavigationService.shared.navigate(forEvent: event, params: params)
        case .apiCall(endpoint: let endpoint, method: let method, params: let params, completion: let completion):
            APIService.shared.makeAPICall(endpoint: endpoint, method: method, params: params, completion: completion)
        }
    }
    
    
}
