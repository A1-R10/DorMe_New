//
//  Landlord.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/8/2026.
//

import Foundation
import SwiftData

@Model
final class Landlord: Identifiable {
    var id: UUID
    var fullName: String
    var email: String
    var password: String
    var contact: String
    var dormitoryName: String

    init(id: UUID = UUID(), fullName: String = "", email: String = "", password: String = "", contact: String = "", dormitoryName: String = "") {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.password = password
        self.contact = contact
        self.dormitoryName = dormitoryName
    }
}
