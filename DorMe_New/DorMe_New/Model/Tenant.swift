//
//  Tenant.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/8/2026.
//

import Foundation
import SwiftData

enum PaymentStatus: String {
    case paid = "PAID"
    case dueSoon = "DUE SOON"
    case overdue = "OVERDUE"
}

@Model
final class Tenant: Identifiable {
    var id: UUID
    var name: String
    var contact: String
    var email: String
    var roomID: UUID
    var monthlyRent: Int
    var nextDueDate: Date
    var accessCode: String
    var notes: String

    init(id: UUID = UUID(), name: String = "", contact: String = "", email: String = "", roomID: UUID = UUID(), monthlyRent: Int = 0, nextDueDate: Date = Date(), accessCode: String = "", notes: String = "") {
        self.id = id
        self.name = name
        self.contact = contact
        self.email = email
        self.roomID = roomID
        self.monthlyRent = monthlyRent
        self.nextDueDate = nextDueDate
        self.accessCode = accessCode
        self.notes = notes
    }
}
