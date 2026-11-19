//
//  TenantHomeView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/9/2026.
//

import SwiftUI
import SwiftData

struct TenantHomeView: View {
    @Query private var rooms: [Room]
    @Query private var landlords: [Landlord]
    @Query(sort: \Payment.date, order: .reverse) private var payments: [Payment]

    var tenant: Tenant

    private let paymentController = PaymentController()
    private let dateController = DateController()
    private let formatController = FormatController()

    private var room: Room? {
        return rooms.first(where: { $0.id == tenant.roomID })
    }

    private var lastPaymentText: String {
        if let lastDate = paymentController.lastPaymentDate(for: tenant, payments: payments) {
            return dateController.formattedDate(lastDate)
        }
        return "No payments yet"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("\(dateController.greeting()), \(formatController.firstName(from: tenant.name))!")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .padding(.top, 8)

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.dormeMustard)

                    VStack(spacing: 8) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.white)

                        Text(room?.number ?? "No room")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        Text(room?.wing ?? "")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                .frame(height: 150)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Rent Details")
                        .font(.system(.headline, design: .rounded))

                    VStack(spacing: 0) {
                        HStack {
                            Text("Status")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(Color.dormeGray)

                            Spacer()

                            StatusBadge(status: dateController.status(for: tenant))
                        }
                        .padding(.vertical, 10)

                        Divider()
                        DetailRow(label: "Monthly Rent", value: formatController.peso(tenant.monthlyRent))
                        Divider()
                        DetailRow(label: "Next Due Date", value: dateController.formattedDate(tenant.nextDueDate))
                        Divider()
                        DetailRow(label: "Payment Reminder", value: dateController.dueText(for: tenant))
                        Divider()
                        DetailRow(label: "Last Payment", value: lastPaymentText)
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                if let landlord = landlords.first {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Landlord")
                            .font(.system(.headline, design: .rounded))

                        VStack(spacing: 0) {
                            DetailRow(label: "Name", value: landlord.fullName)
                            Divider()
                            DetailRow(label: "Dormitory", value: landlord.dormitoryName.isEmpty ? "Not set" : landlord.dormitoryName)
                            Divider()
                            DetailRow(label: "Contact", value: landlord.contact.isEmpty ? "Not set" : landlord.contact)
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.dormeBackground)
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        TenantHomeView(tenant: Tenant(name: "Juan Dela Cruz", monthlyRent: 5000))
    }
    .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
