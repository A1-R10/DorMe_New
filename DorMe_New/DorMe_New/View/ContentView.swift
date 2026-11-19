//
//  ContentView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/14/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var landlords: [Landlord]

    @State private var currentLandlord: Landlord?
    @State private var currentTenant: Tenant?
    @State private var isCheckingSession = true

    private let authController = AuthController()

    var body: some View {
        Group {
            if isCheckingSession {
                ProgressView()
            } else if let landlord = currentLandlord {
                MainTabView(landlord: landlord, currentLandlord: $currentLandlord)
            } else if let tenant = currentTenant {
                TenantTabView(tenant: tenant, currentTenant: $currentTenant)
            } else {
                WelcomeView(currentLandlord: $currentLandlord, currentTenant: $currentTenant)
            }
        }
        .task {
            await restoreSession()
        }
    }

    private func restoreSession() async {
        currentLandlord = await authController.restoreSession(landlords: landlords, modelContext: modelContext)

        // No landlord? Check if a tenant was logged in on this phone last time.
        if currentLandlord == nil {
            currentTenant = authController.restoreTenantSession(modelContext: modelContext, onRemoved: {
                currentTenant = nil
            })
        }

        isCheckingSession = false
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
