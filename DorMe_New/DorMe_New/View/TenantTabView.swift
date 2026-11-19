//
//  TenantTabView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/17/2026.
//

import SwiftUI
import SwiftData

struct TenantTabView: View {

    var tenant: Tenant
    @Binding var currentTenant: Tenant?

    var body: some View {
        TabView {
            NavigationStack {
                TenantHomeView(tenant: tenant)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                TenantPaymentsView(tenant: tenant)
            }
            .tabItem {
                Label("Payments", systemImage: "tray.fill")
            }

            NavigationStack {
                TenantProfileView(tenant: tenant, currentTenant: $currentTenant)
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
        .tint(Color.dormeMustard)
    }
}

#Preview {
    TenantTabView(tenant: Tenant(name: "Juan Dela Cruz", monthlyRent: 5000), currentTenant: .constant(nil))
        .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
