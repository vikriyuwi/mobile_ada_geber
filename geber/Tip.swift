//
//  Tip.swift
//  geber
//
//  Created by win win on 02/04/24.
//

import Foundation
import SwiftData

@Model
final class Tip {
    var text: String
    
    init(text: String) {
        self.text = text
    }
}
