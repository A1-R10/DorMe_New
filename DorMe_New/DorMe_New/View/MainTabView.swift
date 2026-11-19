//
//  MainTabView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/7/2026.
//

import SwiftUI
import SwiftData

struct MainTabView: View {

    var landlord: Landlord
    @Binding var currentLandlord: Landlord?

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView(landlord: landlord, selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Dashboard", systemImage: "square.grid.2x2.fill")
            }
            .tag(0)

            NavigationStack {
                TenantsListView()
            }
            .tabItem {
                Label("Tenants", systemImage: "person.2.fill")
            }
            .tag(1)

            NavigationStack {
                RoomsListView()
            }
            .tabItem {
                Label("Rooms", systemImage: "house.fill")
            }
            .tag(2)

            NavigationStack {
                PaymentsListView()
            }
            .tabItem {
                Label("Payments", systemImage: "tray.fill")
            }
            .tag(3)

            NavigationStack {
                ProfileView(landlord: landlord, currentLandlord: $currentLandlord)
            }
            .tabItem {
                Label("Profile", systemImage: "gearshape.fill")
            }
            .tag(4)
        }
        .tint(Color.dormeMustard)
    }
}

#Preview {
    MainTabView(landlord: Landlord(fullName: "Roberto Reyes"), currentLandlord: .constant(nil))
        .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
