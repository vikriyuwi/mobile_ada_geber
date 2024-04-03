//
//  PushNotificationActor.swift
//  geber
//
//  Created by mac.bernanda on 03/04/24.
//

import Foundation

class PushNotificationActor {
    static func pushNotification(loc: String) {
        let receiverFCM = EnvManager.shared.RECEIVER_FCM
        let serverKey = EnvManager.shared.SERVER_KEY
        
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "to": receiverFCM,
            "notification": [
                "title": "Someone Need Help!",
                "body": "Location \(loc)",
                "sound": "defaulr"
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) {
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
//                For debugging
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                if let data = data {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response: \(responseString)")
                    }
                }
            }.resume()
        }
    }
}
