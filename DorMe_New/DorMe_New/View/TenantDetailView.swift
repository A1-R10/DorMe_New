//
//  TenantDetailView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/8/2026.
//

import SwiftUI
import SwiftData

struct TenantDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var tenants: [Tenant]
    @Query private var rooms: [Room]
    @Query(sort: \Payment.date, order: .reverse) private var payments: [Payment]

    var tenantID: UUID

    @State private var showDeleteTenantAlert = false
    @State private var showDeletePaymentAlert = false
    @State private var paymentToDelete: Payment?
    @State private var showResetCodeAlert = false
    @State private var showShareSheet = false
    @State private var shareText = ""

    private let tenantController = TenantController()
    private let roomController = RoomController()
    private let paymentController = PaymentController()
    private let dateController = DateController()
    private let formatController = FormatController()

    private var tenant: Tenant? {
        return tenants.first(where: { $0.id == tenantID })
    }

    var body: some View {
        ScrollView {
            if let tenant = tenant {
                detailContent(for: tenant)
            }
        }
        .background(Color.dormeBackground)
        .navigationTitle(tenant?.name ?? "")
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
        .alert("Delete Tenant?", isPresented: $showDeleteTenantAlert) {
            Button("Delete", role: .destructive) {
                if let tenant = tenant {
                    tenantController.deleteTenant(tenant: tenant, payments: payments, modelContext: modelContext)
                }
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This removes the tenant and their payment history, and frees up their room.")
        }
        .alert("Reset Login Code?", isPresented: $showResetCodeAlert) {
            Button("Reset", role: .destructive) {
                if let tenant = tenant {
                    tenantController.resetAccessCode(tenant: tenant, tenants: tenants)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("The old code will stop working. Share the new code with the tenant.")
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(text: shareText)
                .presentationDetents([.medium, .large])
        }
    }

    private func detailContent(for tenant: Tenant) -> some View {
        let tenantPayments = paymentController.payments(for: tenant, payments: payments)

        return VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {
                ProfileAvatar(name: tenant.name, size: 64)

                VStack(alignment: .leading, spacing: 4) {
                    Text(tenant.name)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)

                    Text(roomController.roomNumber(for: tenant.roomID, rooms: rooms))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Color.dormeGray)
                }

                Spacer()
            }
            .padding(.top, 8)

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

                HStack {
                    Text("Contact")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Color.dormeGray)

                    Spacer()

                    Text(tenant.contact.isEmpty ? "Not set" : tenant.contact)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.dormeMustard)
                }
                .padding(.vertical, 10)

                Divider()
                DetailRow(label: "Email", value: tenant.email.isEmpty ? "Not set" : tenant.email)
                Divider()

                HStack {
                    Text("Login Code")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Color.dormeGray)

                    Spacer()

                    Text(tenant.accessCode)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.black)

                    Button(action: {
                        shareText = tenantController.shareMessage(for: tenant)
                        showShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.subheadline)
                            .foregroundStyle(Color.dormeMustard)
                            .padding(.leading, 8)
                    }

                    Button(action: {
                        showResetCodeAlert = true
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.subheadline)
                            .foregroundStyle(Color.dormeMustard)
                            .padding(.leading, 6)
                    }
                }
                .padding(.vertical, 10)

                if !tenant.notes.isEmpty {
                    Divider()
                    DetailRow(label: "Notes", value: tenant.notes)
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 12) {
                Text("Payment History")
                    .font(.system(.headline, design: .rounded))

                if tenantPayments.isEmpty {
                    Text("No payments recorded yet.")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Color.dormeGray)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    VStack(spacing: 0) {
                        ForEach(tenantPayments) { payment in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(formatController.peso(payment.amount))
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(.semibold)

                                    Text("\(dateController.formattedDate(payment.date)) • \(payment.method)")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundStyle(Color.dormeGray)
                                }

                                Spacer()

                                StatusBadge(status: .paid)

                                Button(action: {
                                    paymentToDelete = payment
                                    showDeletePaymentAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .font(.footnote)
                                        .foregroundStyle(Color.dormeGray)
                                        .padding(.leading, 8)
                                }
                            }
                            .padding(.vertical, 10)

                            if payment.id != tenantPayments.last?.id {
                                Divider()
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.dormeMustard, lineWidth: 1)
                    )
                    .alert("Delete Payment?", isPresented: $showDeletePaymentAlert) {
                        Button("Delete", role: .destructive) {
                            if let payment = paymentToDelete {
                                paymentController.deletePayment(payment: payment, tenants: tenants, modelContext: modelContext)
                                paymentToDelete = nil
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("The tenant's next due date will move back one month.")
                    }
                }
            }

            VStack(spacing: 12) {
                NavigationLink(destination: RecordPaymentView(preselectedTenant: tenant)) {
                    Text("Record Payment")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.dormeMaroon)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                NavigationLink(destination: EditTenantView(tenant: tenant)) {
                    Text("Edit Tenant Details")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Color.dormeMustard)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.dormeMustard, lineWidth: 1.5)
                        )
                }

                Button(action: {
                    showDeleteTenantAlert = true
                }) {
                    Text("Delete Tenant")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Color.dormeRed)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.dormeRed, lineWidth: 1.5)
                        )
                }
            }
            .padding(.top, 10)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

struct DetailRow: View {

    var label: String
    var value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Color.dormeGray)

            Spacer()

            Text(value)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(Color.black)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    NavigationStack {
        TenantDetailView(tenantID: UUID())
    }
    .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
