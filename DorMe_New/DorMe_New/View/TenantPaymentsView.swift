//
//  TenantPaymentsView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/9/2026.
//

import SwiftUI
import SwiftData

struct TenantPaymentsView: View {
    @Query(sort: \Payment.date, order: .reverse) private var payments: [Payment]

    var tenant: Tenant

    private let paymentController = PaymentController()
    private let dateController = DateController()
    private let formatController = FormatController()

    private var tenantPayments: [Payment] {
        return paymentController.payments(for: tenant, payments: payments)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Payments")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .padding(.top, 8)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Next Due")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(Color.dormeGray)

                        Text(dateController.formattedDate(tenant.nextDueDate))
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(Color.black)

                        Text(dateController.dueText(for: tenant))
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(Color.dormeGray)
                    }

                    Spacer()

                    StatusBadge(status: dateController.status(for: tenant))
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))

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
                    VStack(spacing: 12) {
                        ForEach(tenantPayments) { payment in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(formatController.peso(payment.amount))
                                        .font(.system(.headline, design: .rounded))
                                        .foregroundStyle(Color.black)

                                    Text("\(dateController.formattedDate(payment.date)) • \(payment.method)")
                                        .font(.system(.footnote, design: .rounded))
                                        .foregroundStyle(Color.dormeGray)
                                }

                                Spacer()

                                StatusBadge(status: .paid)
                            }
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
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
        TenantPaymentsView(tenant: Tenant(name: "Juan Dela Cruz", monthlyRent: 5000))
    }
    .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
