//
//  MiniAppCore.swift
//  miniapp-core
//
//  Created by Stany Bluebik on 16/07/2024.
//

import Foundation
import UIKit
import SwiftUI
import Alamofire

public struct MiniAppCore {
    
    public static let Auth: AuthenticationProtocol = AuthenticationService.shared
    public static let API: APIProtocol = APIService.shared
    public static let Navigation: NavigationProtocol = NavigationService.shared
    public static let EventBus: EventProtocol = EventBusService.shared
    
    private init() {}
    
}
