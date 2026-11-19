//
//  PaymentController.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/29/2026.
//

import Foundation
import SwiftData

struct PaymentController {

    func payments(for tenant: Tenant, payments: [Payment]) -> [Payment] {
        return payments.filter { $0.tenantID == tenant.id }
    }

    func lastPaymentDate(for tenant: Tenant, payments: [Payment]) -> Date? {
        let tenantPayments = self.payments(for: tenant, payments: payments)
        return tenantPayments.first?.date
    }

    func recordPayment(tenant: Tenant, amount: Int, date: Date, method: String, notes: String, modelContext: ModelContext) {
        let payment = Payment(tenantID: tenant.id, amount: amount, date: date, method: method, notes: notes.trimmingCharacters(in: .whitespaces))
        modelContext.insert(payment)
        SyncController.shared.save(payment: payment)

        tenant.nextDueDate = DateController().addOneMonth(to: tenant.nextDueDate)
        SyncController.shared.save(tenant: tenant)

        ActivityController().addActivity(message: "\(tenant.name) paid \(FormatController().peso(amount))", kind: "payment", modelContext: modelContext)
        PortalController.shared.publish(tenant: tenant, modelContext: modelContext)
    }

    func deletePayment(payment: Payment, tenants: [Tenant], modelContext: ModelContext) {
        let tenant = tenants.first(where: { $0.id == payment.tenantID })

        if let tenant = tenant {
            tenant.nextDueDate = DateController().subtractOneMonth(from: tenant.nextDueDate)
            SyncController.shared.save(tenant: tenant)
        }

        SyncController.shared.delete(payment: payment)
        modelContext.delete(payment)

        if let tenant = tenant {
            PortalController.shared.publish(tenant: tenant, modelContext: modelContext)
        }
    }
}
