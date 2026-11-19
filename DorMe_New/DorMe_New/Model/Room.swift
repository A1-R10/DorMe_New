//
//  Room.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/8/2026.
//

import Foundation
import SwiftData

enum RoomStatus: String {
    case occupied = "Occupied"
    case available = "Available"
}

@Model
final class Room: Identifiable {
    var id: UUID
    var number: String
    var wing: String
    var monthlyRent: Int

    init(id: UUID = UUID(), number: String = "", wing: String = "", monthlyRent: Int = 0) {
        self.id = id
        self.number = number
        self.wing = wing
        self.monthlyRent = monthlyRent
    }
}
