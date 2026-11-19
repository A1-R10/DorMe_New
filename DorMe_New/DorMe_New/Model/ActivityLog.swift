//
//  ActivityLog.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/29/2026.
//

import Foundation
import SwiftData

@Model
final class ActivityLog: Identifiable {
    var id: UUID
    var message: String
    var date: Date
    var kind: String

    init(id: UUID = UUID(), message: String = "", date: Date = Date(), kind: String = "") {
        self.id = id
        self.message = message
        self.date = date
        self.kind = kind
    }
}
