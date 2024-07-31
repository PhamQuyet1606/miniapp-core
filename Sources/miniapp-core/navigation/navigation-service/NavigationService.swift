//
//  Navigation.swift
//  miniapp-core
//
//  Created by Stany Bluebik on 24/07/2024.
//

import Foundation
import UIKit

final class NavigationService  {
    
    static let shared = NavigationService()
    
    private var routers: [[String : Any]] = []
    private var navigate: ((String, Any?) -> Void)?
    
    var currentMiniApp: String {
        UserDefaults.standard.string(forKey: UserDefaultsKeys.currentMiniApp) ?? ""
    }
    
    private init() {
        
    }
    
    func navigate(forEvent event: String, params: Any?) {
        guard let currentFlow = routers.first(where: { $0["key"] as? String == currentMiniApp } ) else { return }
        guard let events = currentFlow["events"] as? [String: Any] else { return }
        guard let nextMiniApp = events[event] as? String else { return }
        navigate?(nextMiniApp, params)
    }
    
}

extension NavigationService: NavigationProtocol {
    
    func config(navigate: @escaping (String, Any?) -> Void) {
        self.navigate = navigate
    }
    
    func configRouters(routers: [[String : Any]], currentMiniApp: String) {
        self.routers = routers
        navigate?(currentMiniApp, nil)
    }
    
    //MARK: - Set Current MiniApp
    
    func setCurrentMiniApp(miniApp: String) {
        UserDefaults.standard.setValue(miniApp, forKey: UserDefaultsKeys.currentMiniApp)
        UserDefaults.standard.synchronize()
    }
}

