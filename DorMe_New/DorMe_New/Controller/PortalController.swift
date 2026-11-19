//
//  PortalController.swift
//  DorMe_New
//
//  Created by Mac-LAB on 10/21/2026.
//

import Foundation
import SwiftData
import CryptoKit
import FirebaseAuth
import FirebaseFirestore

final class PortalController {

    static let shared = PortalController()

    private var listener: ListenerRegistration?
    private let sessionKey = "tenantPortalKey"
    private let formatController = FormatController()

    private var db: Firestore {
        return Firestore.firestore()
    }

    func portalKey(email: String, code: String) -> String {
        let text = "dorme|" + formatController.cleanEmail(email) + "|" + code.trimmingCharacters(in: .whitespaces)
        let hash = SHA256.hash(data: Data(text.utf8))
        return hash.map { String(format: "%02x", $0) }.joined()
    }


    func currentLandlord(modelContext: ModelContext) -> Landlord? {
        let email = formatController.cleanEmail(Auth.auth().currentUser?.email ?? "")
        let allLandlords = (try? modelContext.fetch(FetchDescriptor<Landlord>())) ?? []
        return allLandlords.first(where: { $0.email == email })
    }

    func publish(tenant: Tenant, modelContext: ModelContext) {
        guard let user = Auth.auth().currentUser else {
            return
        }

        try? modelContext.save()

        let allRooms = (try? modelContext.fetch(FetchDescriptor<Room>())) ?? []
        let allPayments = (try? modelContext.fetch(FetchDescriptor<Payment>())) ?? []

        let room = allRooms.first(where: { $0.id == tenant.roomID })
        let landlord = currentLandlord(modelContext: modelContext)

        let tenantPayments = allPayments
            .filter { $0.tenantID == tenant.id }
            .sorted { $0.date > $1.date }

        var paymentList: [[String: Any]] = []
        for payment in tenantPayments {
            paymentList.append([
                "id": payment.id.uuidString,
                "amount": payment.amount,
                "date": Timestamp(date: payment.date),
                "method": payment.method
            ])
        }

        let data: [String: Any] = [
            "ownerID": user.uid,
            "tenantID": tenant.id.uuidString,
            "name": tenant.name,
            "contact": tenant.contact,
            "email": tenant.email,
            "roomID": tenant.roomID.uuidString,
            "roomNumber": room?.number ?? "",
            "roomWing": room?.wing ?? "",
            "monthlyRent": tenant.monthlyRent,
            "nextDueDate": Timestamp(date: tenant.nextDueDate),
            "landlordName": landlord?.fullName ?? "",
            "landlordEmail": landlord?.email ?? "",
            "landlordContact": landlord?.contact ?? "",
            "dormitoryName": landlord?.dormitoryName ?? "",
            "payments": paymentList,
            "updatedAt": Timestamp(date: Date())
        ]

        let key = portalKey(email: tenant.email, code: tenant.accessCode)
        db.collection("portals").document(key).setData(data) { error in
            if let error = error {
                print("Portal error saving: \(error.localizedDescription)")
            }
        }
    }

    func removePortal(email: String, code: String) {
        if Auth.auth().currentUser == nil {
            return
        }

        let key = portalKey(email: email, code: code)
        db.collection("portals").document(key).delete { error in
            if let error = error {
                print("Portal error deleting: \(error.localizedDescription)")
            }
        }
    }

    func publishAll(modelContext: ModelContext) {
        let allTenants = (try? modelContext.fetch(FetchDescriptor<Tenant>())) ?? []
        for tenant in allTenants {
            publish(tenant: tenant, modelContext: modelContext)
        }
    }

    func publishTenants(inRoom roomID: UUID, modelContext: ModelContext) {
        let allTenants = (try? modelContext.fetch(FetchDescriptor<Tenant>())) ?? []
        for tenant in allTenants where tenant.roomID == roomID {
            publish(tenant: tenant, modelContext: modelContext)
        }
    }

    @MainActor
    func tenantLogIn(email: String, code: String, modelContext: ModelContext, onRemoved: @escaping () -> Void) async throws -> Tenant {
        let key = portalKey(email: email, code: code)
        let snapshot = try await db.collection("portals").document(key).getDocument()

        guard let data = snapshot.data() else {
            throw AppError(message: "That email and access code do not match.")
        }

        wipeLocalData(modelContext: modelContext)
        UserDefaults.standard.removeObject(forKey: "syncOwnerID")
        UserDefaults.standard.set(key, forKey: sessionKey)

        let tenant = applyPortal(data: data, modelContext: modelContext)
        startListening(key: key, modelContext: modelContext, onRemoved: onRemoved)
        return tenant
    }

    @MainActor
    func restoreTenant(modelContext: ModelContext, onRemoved: @escaping () -> Void) -> Tenant? {
        guard let key = UserDefaults.standard.string(forKey: sessionKey) else {
            return nil
        }

        let allTenants = (try? modelContext.fetch(FetchDescriptor<Tenant>())) ?? []
        guard let tenant = allTenants.first else {
            UserDefaults.standard.removeObject(forKey: sessionKey)
            return nil
        }

        startListening(key: key, modelContext: modelContext, onRemoved: onRemoved)
        return tenant
    }

    @MainActor
    func tenantLogOut(modelContext: ModelContext) {
        stopListening()
        UserDefaults.standard.removeObject(forKey: sessionKey)
    }

    private func startListening(key: String, modelContext: ModelContext, onRemoved: @escaping () -> Void) {
        stopListening()

        listener = db.collection("portals").document(key).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Portal listener error: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot else {
                return
            }

            Task { @MainActor in
                if let data = snapshot.data() {
                    _ = self.applyPortal(data: data, modelContext: modelContext)
                } else if !snapshot.metadata.isFromCache {
                    self.tenantLogOut(modelContext: modelContext)
                    onRemoved()
                }
            }
        }
    }

    private func stopListening() {
        listener?.remove()
        listener = nil
    }

    @MainActor
    private func applyPortal(data: [String: Any], modelContext: ModelContext) -> Tenant {
        let tenantID = UUID(uuidString: data["tenantID"] as? String ?? "") ?? UUID()
        let roomID = UUID(uuidString: data["roomID"] as? String ?? "") ?? UUID()

        // Landlord
        let landlords = (try? modelContext.fetch(FetchDescriptor<Landlord>())) ?? []
        let landlord = landlords.first ?? Landlord()
        landlord.fullName = data["landlordName"] as? String ?? ""
        landlord.email = data["landlordEmail"] as? String ?? ""
        landlord.contact = data["landlordContact"] as? String ?? ""
        landlord.dormitoryName = data["dormitoryName"] as? String ?? ""
        if landlords.isEmpty {
            modelContext.insert(landlord)
        }

        // Room
        let rooms = (try? modelContext.fetch(FetchDescriptor<Room>())) ?? []
        let room = rooms.first(where: { $0.id == roomID }) ?? Room(id: roomID)
        room.number = data["roomNumber"] as? String ?? ""
        room.wing = data["roomWing"] as? String ?? ""
        room.monthlyRent = data["monthlyRent"] as? Int ?? 0
        if !rooms.contains(where: { $0.id == roomID }) {
            modelContext.insert(room)
        }
        for oldRoom in rooms where oldRoom.id != roomID {
            modelContext.delete(oldRoom)
        }

        // Tenant
        let tenants = (try? modelContext.fetch(FetchDescriptor<Tenant>())) ?? []
        let tenant = tenants.first(where: { $0.id == tenantID }) ?? Tenant(id: tenantID)
        tenant.name = data["name"] as? String ?? ""
        tenant.contact = data["contact"] as? String ?? ""
        tenant.email = data["email"] as? String ?? ""
        tenant.roomID = roomID
        tenant.monthlyRent = data["monthlyRent"] as? Int ?? 0
        tenant.nextDueDate = (data["nextDueDate"] as? Timestamp)?.dateValue() ?? Date()
        if !tenants.contains(where: { $0.id == tenantID }) {
            modelContext.insert(tenant)
        }
        for oldTenant in tenants where oldTenant.id != tenantID {
            modelContext.delete(oldTenant)
        }

        let oldPayments = (try? modelContext.fetch(FetchDescriptor<Payment>())) ?? []
        for payment in oldPayments {
            modelContext.delete(payment)
        }

        let paymentList = data["payments"] as? [[String: Any]] ?? []
        for item in paymentList {
            let payment = Payment(
                id: UUID(uuidString: item["id"] as? String ?? "") ?? UUID(),
                tenantID: tenantID,
                amount: item["amount"] as? Int ?? 0,
                date: (item["date"] as? Timestamp)?.dateValue() ?? Date(),
                method: item["method"] as? String ?? ""
            )
            modelContext.insert(payment)
        }

        try? modelContext.save()
        return tenant
    }

    @MainActor
    private func wipeLocalData(modelContext: ModelContext) {
        for landlord in (try? modelContext.fetch(FetchDescriptor<Landlord>())) ?? [] {
            modelContext.delete(landlord)
        }
        for room in (try? modelContext.fetch(FetchDescriptor<Room>())) ?? [] {
            modelContext.delete(room)
        }
        for tenant in (try? modelContext.fetch(FetchDescriptor<Tenant>())) ?? [] {
            modelContext.delete(tenant)
        }
        for payment in (try? modelContext.fetch(FetchDescriptor<Payment>())) ?? [] {
            modelContext.delete(payment)
        }
        for activity in (try? modelContext.fetch(FetchDescriptor<ActivityLog>())) ?? [] {
            modelContext.delete(activity)
        }
        try? modelContext.save()
    }
}
