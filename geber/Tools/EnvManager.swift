//
//  EnvManager.swift
//  geber
//
//  Created by mac.bernanda on 03/04/24.
//

import Foundation

class EnvManager {
    static let shared = EnvManager()
    @Published var REDIS_HOST : String
    @Published var REDIS_USER : String
    @Published var REDIS_PASS : String
    @Published var RECEIVER_FCM : String
    @Published var SERVER_KEY : String
    @Published var BEACON_UUID : String
    
    private init() {
        let envDict = Bundle.main.infoDictionary?["LSEnvironment"] as! Dictionary<String, String>
        REDIS_HOST = envDict["REDIS_HOST"]!
        REDIS_USER = envDict["REDIS_USER"]!
        REDIS_PASS = envDict["REDIS_PASS"]!
        RECEIVER_FCM = envDict["RECEIVER_FCM"]!
        SERVER_KEY = envDict["SERVER_KEY"]!
        BEACON_UUID = envDict["BEACON_UUID"]!
    }
}
