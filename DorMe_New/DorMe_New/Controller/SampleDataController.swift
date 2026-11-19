//
//  SampleDataController.swift
//  DorMe_New
//
//  Created by Mac-LAB on 10/20/2026.
//

import Foundation
import SwiftData

struct SampleDataController {

    func addSampleData(modelContext: ModelContext) {
        let dateController = DateController()

        let room201 = Room(number: "Room 201", wing: "2nd Floor, East Wing", monthlyRent: 5000)
        let room202 = Room(number: "Room 202", wing: "2nd Floor, East Wing", monthlyRent: 5000)
        let room203 = Room(number: "Room 203", wing: "2nd Floor, East Wing", monthlyRent: 5000)
        let room204 = Room(number: "Room 204", wing: "2nd Floor, West Wing", monthlyRent: 5000)
        let room205 = Room(number: "Room 205", wing: "2nd Floor, West Wing", monthlyRent: 5000)

        for room in [room201, room202, room203, room204, room205] {
            modelContext.insert(room)
            SyncController.shared.save(room: room)
        }

        let juan = Tenant(name: "Juan Dela Cruz", contact: "+63 917 123 4567", email: "juan@email.com", roomID: room201.id, monthlyRent: 5000, nextDueDate: dateController.daysFromNow(20), accessCode: "482915")
        let maria = Tenant(name: "Maria Santos", contact: "+63 917 234 5678", email: "maria@email.com", roomID: room202.id, monthlyRent: 5000, nextDueDate: dateController.daysFromNow(3), accessCode: "730264")
        let pedro = Tenant(name: "Pedro Cruz", contact: "+63 917 345 6789", email: "pedro@email.com", roomID: room204.id, monthlyRent: 5000, nextDueDate: dateController.daysFromNow(-5), accessCode: "159378")

        for tenant in [juan, maria, pedro] {
            modelContext.insert(tenant)
            SyncController.shared.save(tenant: tenant)
        }

        let payments = [
            Payment(tenantID: juan.id, amount: 5000, date: dateController.daysFromNow(-10), method: "GCash"),
            Payment(tenantID: juan.id, amount: 5000, date: dateController.daysFromNow(-40), method: "Cash"),
            Payment(tenantID: juan.id, amount: 5000, date: dateController.daysFromNow(-70), method: "GCash"),
            Payment(tenantID: maria.id, amount: 5000, date: dateController.daysFromNow(-27), method: "GCash"),
            Payment(tenantID: pedro.id, amount: 5000, date: dateController.daysFromNow(-35), method: "Cash")
        ]

        for payment in payments {
            modelContext.insert(payment)
            SyncController.shared.save(payment: payment)
        }

        let activities = [
            ActivityLog(message: "Juan Dela Cruz paid ₱5,000", date: Date(timeIntervalSinceNow: -7200), kind: "payment"),
            ActivityLog(message: "Maria Santos was added", date: Date(timeIntervalSinceNow: -86400), kind: "tenant"),
            ActivityLog(message: "Room 203 became available", date: Date(timeIntervalSinceNow: -172800), kind: "room")
        ]

        for activity in activities {
            modelContext.insert(activity)
            SyncController.shared.save(activity: activity)
        }

        PortalController.shared.publishAll(modelContext: modelContext)
    }
}
