//
//  PaymentsListView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/9/2026.
//

import SwiftUI
import SwiftData

enum PaymentFilter: String, CaseIterable {
    case all = "All"
    case paid = "Paid"
    case due = "Due"
    case overdue = "Overdue"
}

struct PaymentsListView: View {
    @Query(sort: \Tenant.name) private var tenants: [Tenant]
    @Query private var rooms: [Room]
    @Query(sort: \Payment.date, order: .reverse) private var payments: [Payment]

    @State private var selectedFilter: PaymentFilter = .all

    private let roomController = RoomController()
    private let paymentController = PaymentController()
    private let dateController = DateController()
    private let formatController = FormatController()

    private var filteredTenants: [Tenant] {
        switch selectedFilter {
        case .all:
            return tenants
        case .paid:
            return tenants.filter { dateController.status(for: $0) == .paid }
        case .due:
            return tenants.filter { dateController.status(for: $0) == .dueSoon }
        case .overdue:
            return tenants.filter { dateController.status(for: $0) == .overdue }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Payments")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            HStack(spacing: 0) {
                ForEach(PaymentFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedFilter == filter ? Color.white : Color.clear)
                        .foregroundStyle(selectedFilter == filter ? Color.black : Color.dormeGray)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedFilter == filter ? Color.dormeMustard : Color.clear, lineWidth: 1.5)
                        )
                        .onTapGesture {
                            selectedFilter = filter
                        }
                }
            }
            .padding(4)
            .background(Color.dormeMustard.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            if filteredTenants.isEmpty {
                Spacer()
                Text(tenants.isEmpty ? "No tenants yet." : "No payments in this category.")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Color.dormeGray)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                List {
                    ForEach(filteredTenants) { tenant in
                        ZStack(alignment: .leading) {
                            NavigationLink(destination: TenantDetailView(tenantID: tenant.id)) {
                                EmptyView()
                            }
                            .opacity(0)

                            PaymentRow(tenant: tenant, roomNumber: roomController.roomNumber(for: tenant.roomID, rooms: rooms), subtitle: subtitle(for: tenant), status: dateController.status(for: tenant), amount: formatController.peso(tenant.monthlyRent))
                        }
                    }
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

    private func subtitle(for tenant: Tenant) -> String {
        if dateController.status(for: tenant) == .paid, let lastDate = paymentController.lastPaymentDate(for: tenant, payments: payments) {
            return "Paid \(dateController.formattedDate(lastDate))"
        }
        return dateController.dueText(for: tenant)
    }
}

struct PaymentRow: View {

    var tenant: Tenant
    var roomNumber: String
    var subtitle: String
    var status: PaymentStatus
    var amount: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(tenant.name)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.black)

                Text("\(roomNumber) • \(subtitle)")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(Color.dormeGray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(amount)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.black)

                StatusBadge(status: status)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        PaymentsListView()
    }
    .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
