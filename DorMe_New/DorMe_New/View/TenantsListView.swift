//
//  TenantsListView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/10/2026.
//

import SwiftUI
import SwiftData

struct TenantsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tenant.name) private var tenants: [Tenant]
    @Query private var rooms: [Room]
    @Query private var payments: [Payment]

    @State private var searchText = ""

    private let tenantController = TenantController()
    private let roomController = RoomController()
    private let dateController = DateController()
    private let formatController = FormatController()

    private var filteredTenants: [Tenant] {
        guard !searchText.isEmpty else { return tenants }

        return tenants.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Tenants")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)

                Spacer()

                NavigationLink(destination: AddTenantView()) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.dormeMustard)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.dormeGray)

                TextField("Search tenants...", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding()
            .background(Color.dormeMustard.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            .padding(.top, 12)

            if filteredTenants.isEmpty {
                Spacer()
                Text(tenants.isEmpty ? "No tenants yet. Tap + to add one." : "No tenants found.")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Color.dormeGray)
                Spacer()
            } else {
                List {
                    ForEach(filteredTenants) { tenant in
                        ZStack(alignment: .leading) {
                            NavigationLink(destination: TenantDetailView(tenantID: tenant.id)) {
                                EmptyView()
                            }
                            .opacity(0)

                            TenantRow(tenant: tenant, roomNumber: roomController.roomNumber(for: tenant.roomID, rooms: rooms), status: dateController.status(for: tenant), rent: formatController.peso(tenant.monthlyRent))
                        }
                    }
                    .onDelete(perform: deleteTenant)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.dormeBackground)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color.dormeBackground)
        .navigationBarHidden(true)
    }

    private func deleteTenant(indexSet: IndexSet) {
        for index in indexSet {
            tenantController.deleteTenant(tenant: filteredTenants[index], payments: payments, modelContext: modelContext)
        }
    }
}

struct TenantRow: View {

    var tenant: Tenant
    var roomNumber: String
    var status: PaymentStatus
    var rent: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(tenant.name)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.black)

                Text("\(roomNumber) • \(rent)/month")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(Color.dormeGray)
            }

            Spacer()

            StatusBadge(status: status)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        TenantsListView()
    }
    .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
