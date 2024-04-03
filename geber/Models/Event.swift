//
//  Event.swift
//  geber
//
//  Created by mac.bernanda on 03/04/24.
//

import Foundation

struct Event : Codable {
    let location: SectionLocation
    let timestamp: Date
}

enum SectionLocation : Codable {
    case s1, s2, s3
}
