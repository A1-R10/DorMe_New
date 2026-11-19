//
//  DorMeApp.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/2/2026.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct DorMeApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self])
    }
}
