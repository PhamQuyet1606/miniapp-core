//
//  EventProtocol.swift
//  miniapp-core
//
//  Created by Stany Bluebik on 24/07/2024.
//

import Foundation

public protocol EventProtocol: AnyObject {
    func emit(event: EventType)
}
