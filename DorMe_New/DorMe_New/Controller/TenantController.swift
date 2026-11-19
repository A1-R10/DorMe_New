//
//  TenantController.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/24/2026.
//

import Foundation
import SwiftData

struct TenantController {

    func generateAccessCode(tenants: [Tenant]) -> String {
        var code = String(Int.random(in: 100000...999999))

        while tenants.contains(where: { $0.accessCode == code }) {
            code = String(Int.random(in: 100000...999999))
        }

        return code
    }

    func addTenant(name: String, contact: String, email: String, roomID: UUID, monthlyRent: Int, firstDueDate: Date, notes: String, tenants: [Tenant], modelContext: ModelContext) -> Tenant {
        let tenant = Tenant(name: name.trimmingCharacters(in: .whitespaces), contact: contact.trimmingCharacters(in: .whitespaces), email: FormatController().cleanEmail(email), roomID: roomID, monthlyRent: monthlyRent, nextDueDate: firstDueDate, accessCode: generateAccessCode(tenants: tenants), notes: notes.trimmingCharacters(in: .whitespaces))

        modelContext.insert(tenant)
        SyncController.shared.save(tenant: tenant)
        ActivityController().addActivity(message: "\(tenant.name) was added", kind: "tenant", modelContext: modelContext)
        PortalController.shared.publish(tenant: tenant, modelContext: modelContext)

        return tenant
    }

    func updateTenant(tenant: Tenant, name: String, contact: String, email: String, roomID: UUID, monthlyRent: Int, notes: String) {

        let oldEmail = tenant.email

        tenant.name = name.trimmingCharacters(in: .whitespaces)
        tenant.contact = contact.trimmingCharacters(in: .whitespaces)
        tenant.email = FormatController().cleanEmail(email)
        tenant.roomID = roomID
        tenant.monthlyRent = monthlyRent
        tenant.notes = notes.trimmingCharacters(in: .whitespaces)

        SyncController.shared.save(tenant: tenant)

        if oldEmail != tenant.email {
            PortalController.shared.removePortal(email: oldEmail, code: tenant.accessCode)
        }

        if let modelContext = tenant.modelContext {
            PortalController.shared.publish(tenant: tenant, modelContext: modelContext)
        }
    }

    func resetAccessCode(tenant: Tenant, tenants: [Tenant]) {
        let oldCode = tenant.accessCode
        tenant.accessCode = generateAccessCode(tenants: tenants)

        SyncController.shared.save(tenant: tenant)
        PortalController.shared.removePortal(email: tenant.email, code: oldCode)

        if let modelContext = tenant.modelContext {
            PortalController.shared.publish(tenant: tenant, modelContext: modelContext)
        }
    }

    func shareMessage(for tenant: Tenant) -> String {
        var dormitoryName = ""
        if let modelContext = tenant.modelContext, let landlord = PortalController.shared.currentLandlord(modelContext: modelContext) {
            dormitoryName = landlord.dormitoryName
        }

        let place = dormitoryName.isEmpty ? "your dormitory" : dormitoryName

        return """
        Hi \(FormatController().firstName(from: tenant.name))! You can now check your rent details for \(place) in the DorMe app.

        1. Open DorMe and tap Log In
        2. Choose "Tenant"
        3. Email: \(tenant.email)
        4. Access Code: \(tenant.accessCode)

        Please keep this code private.
        """
    }

    func deleteTenant(tenant: Tenant, payments: [Payment], modelContext: ModelContext) {
        for payment in payments {
            if payment.tenantID == tenant.id {
                SyncController.shared.delete(payment: payment)
                modelContext.delete(payment)
            }
        }

        ActivityController().addActivity(message: "\(tenant.name) was removed", kind: "tenant", modelContext: modelContext)
        PortalController.shared.removePortal(email: tenant.email, code: tenant.accessCode)
        SyncController.shared.delete(tenant: tenant)
        modelContext.delete(tenant)
    }

    func tenantName(for tenantID: UUID, tenants: [Tenant]) -> String {
        let tenant = tenants.first(where: { $0.id == tenantID })
        return tenant?.name ?? "Unknown Tenant"
    }
}
