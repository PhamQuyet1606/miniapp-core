//
//  NavigationProtocol.swift
//  miniapp-core
//
//  Created by Stany Bluebik on 24/07/2024.
//

import Foundation
import UIKit

public protocol NavigationProtocol {
    var currentMiniApp: String { get }
    func config(navigate: @escaping (_ miniApp: String, _ params: Any?) -> Void)
    func configRouters(routers: [[String:Any]], currentMiniApp: String)
    func setCurrentMiniApp(miniApp: String)
}
