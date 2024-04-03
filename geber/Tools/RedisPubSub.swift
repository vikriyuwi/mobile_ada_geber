//
//  HomePageViewModel.swift
//  geber
//
//  Created by mac.bernanda on 03/04/24.
//

import Foundation
import SwiftyRedis
import SwiftRedis
import Network

final class RedisPubSub: ObservableObject {
    @Published var current_key_event: String = ""
    
    private let currentKeyEventKey = "currentKeyEvent"
    private let redis = Redis()
    
    init() {
        
        if let storedKey = UserDefaults.standard.string(forKey: currentKeyEventKey) {
            current_key_event = storedKey
        }
        
        redis.connect(host: EnvManager.shared.REDIS_HOST, port: 6379) { (redisError: NSError?) in
            if let error = redisError {
                print(error)
            }
            else {
                print("Connected to Redis")
                redis.auth(EnvManager.shared.REDIS_PASS) { (err : NSError?) in
                    if let error = redisError {
                        print(error)
                    }
                }
                
            }
        }
    }
    
    private func saveCurrentKeyEvent() {
        UserDefaults.standard.set(current_key_event, forKey: currentKeyEventKey)
    }
    
    func setVal(input: String) {
        redis.set("Redis", value: input) { (result: Bool, redisError: NSError?) in
            if let error = redisError {
                print(error)
            }
            
            else {
                print("Success set data")
            }
        }
    }
    

    func expireHelp(key: String) {
        redis.expire(key, inTime: 0) { (success: Bool, err: NSError?) in
            if let error = err {
                print(error)
            } else {
                if (success) {
                    current_key_event = ""
                    saveCurrentKeyEvent()
                }
            }
        }
    }
    
    func getHelp(minor: Int) {
        do {
            var loc: SectionLocation
            
            if minor == 0 {
                loc = SectionLocation.s1
            } else if minor == 1 {
                loc = SectionLocation.s2
            } else if minor == 2 {
                loc = SectionLocation.s3
            } else {
                return
            }
            
            
            let event = Event(location: loc, timestamp: Date())
            let timeInterval = Int(event.timestamp.timeIntervalSince1970)
            let key = "\(event.location)_event_\(timeInterval)"
            
            let jsonData = try JSONEncoder().encode(event)
            let jsonString = String(data: jsonData, encoding: .utf8)
            
            redis.hset(key, field: "event_data", value: jsonString!){ (result: Bool, redisError: NSError?) in
                if let error = redisError {
                    print(error)
                }
                
                else {
                    current_key_event = key
                    saveCurrentKeyEvent()
                    PushNotificationActor.pushNotification(loc: "\(event.location)")
                }
            }
            
        } catch {
            
        }
        
    }
}
