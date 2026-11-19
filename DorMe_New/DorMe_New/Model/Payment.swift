//
//  Payment.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/10/2026.
//

import Foundation
import SwiftData

@Model
final class Payment: Identifiable {
    var id: UUID
    var tenantID: UUID
    var amount: Int
    var date: Date
    var method: String
    var notes: String

    init(id: UUID = UUID(), tenantID: UUID = UUID(), amount: Int = 0, date: Date = Date(), method: String = "", notes: String = "") {
        self.id = id
        self.tenantID = tenantID
        self.amount = amount
        self.date = date
        self.method = method
        self.notes = notes
    }
}
