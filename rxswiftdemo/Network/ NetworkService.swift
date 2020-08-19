//
//   NetworkService.swift
//  rxswiftdemo
//
//  Created by Hoang Lu on 8/19/20.
//  Copyright © 2020 Hoang Lu. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    static let sharedManager = NetworkManager()
    let alamofireSession: Session

    init() {
        let alamofireConfig = URLSessionConfiguration.default
        alamofireConfig.httpShouldSetCookies = true
        alamofireConfig.httpCookieAcceptPolicy = .always
        alamofireConfig.requestCachePolicy = .useProtocolCachePolicy
        alamofireConfig.timeoutIntervalForRequest = 10
        alamofireSession = Session(configuration: alamofireConfig)
    }
}

class NetworkService {
    let alamofireSession: Session = NetworkManager.sharedManager.alamofireSession

}
