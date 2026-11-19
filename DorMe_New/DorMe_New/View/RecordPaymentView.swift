//
//  RecordPaymentView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/11/2026.
//

import SwiftUI
import SwiftData

struct RecordPaymentView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tenant.name) private var tenants: [Tenant]
    @Query private var rooms: [Room]

    var preselectedTenant: Tenant?

    @State private var selectedTenantID = UUID()
    @State private var amountPaid = ""
    @State private var paymentDate = Date()
    @State private var paymentMethod = "GCash"
    @State private var optionalNotes = ""
    @State private var errorMessage = ""

    let paymentMethods = ["GCash", "Cash", "Bank Transfer"]

    private let paymentController = PaymentController()
    private let roomController = RoomController()

    private var selectedTenant: Tenant? {
        return tenants.first(where: { $0.id == selectedTenantID })
    }

    private var assignedRoomText: String {
        if let tenant = selectedTenant {
            return roomController.roomNumber(for: tenant.roomID, rooms: rooms)
        }
        return "No room"
    }

    var body: some View {
        ScrollView {
            if tenants.isEmpty {
                Text("Add a tenant first before recording a payment.")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Color.dormeGray)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Select Tenant")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.semibold)

                        Picker("Select Tenant", selection: $selectedTenantID) {
                            ForEach(tenants) { tenant in
                                Text(tenant.name).tag(tenant.id)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Assigned Room")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.semibold)

                        Text(assignedRoomText)
                            .foregroundStyle(Color.black)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }

                    LabeledField(label: "Amount Paid (₱)", placeholder: "5,000", text: $amountPaid, keyboard: .numberPad)
                    LabeledDateField(label: "Payment Date", date: $paymentDate)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Payment Method")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.semibold)

                        Picker("Payment Method", selection: $paymentMethod) {
                            ForEach(paymentMethods, id: \.self) { method in
                                Text(method)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }

                    LabeledField(label: "Optional Notes", placeholder: "Advance payment for utilities", text: $optionalNotes)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(Color.dormeRed)
                    }

                    Button(action: {
                        savePayment()
                    }) {
                        Text("Save Payment")
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.dormeMaroon)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
            }
        }
        .background(Color.dormeBackground)
        .navigationTitle("Record Payment")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundStyle(Color.dormeMustard)
                }
            }
        }
        .onAppear {
            if let preselectedTenant {
                selectedTenantID = preselectedTenant.id
                amountPaid = "\(preselectedTenant.monthlyRent)"
            } else if let firstTenant = tenants.first {
                selectedTenantID = firstTenant.id
                amountPaid = "\(firstTenant.monthlyRent)"
            }
        }
        .onChange(of: selectedTenantID) {
            if let tenant = selectedTenant {
                amountPaid = "\(tenant.monthlyRent)"
            }
        }
    }

    private func savePayment() {
        guard let tenant = selectedTenant else {
            errorMessage = "Please select a tenant."
            return
        }

        guard let amount = Int(amountPaid.replacingOccurrences(of: ",", with: "")), amount > 0 else {
            errorMessage = "Please enter a valid amount."
            return
        }

        paymentController.recordPayment(tenant: tenant, amount: amount, date: paymentDate, method: paymentMethod, notes: optionalNotes, modelContext: modelContext)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        RecordPaymentView()
    }
    .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
