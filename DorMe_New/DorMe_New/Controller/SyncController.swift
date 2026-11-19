//
//  SyncController.swift
//  DorMe_New
//
//  Created by Mac-LAB on 10/16/2026.
//

import Foundation
import SwiftData
import FirebaseAuth
import FirebaseFirestore


final class SyncController {

    static let shared = SyncController()

    private var listeners: [ListenerRegistration] = []

    private var loadedCollections: Set<String> = []

    private var db: Firestore {
        return Firestore.firestore()
    }

    private var ownerID: String {
        return Auth.auth().currentUser?.uid ?? ""
    }

    func start(modelContext: ModelContext) {
        stop()

        let uid = ownerID
        if uid == "" {
            return
        }

        if UserDefaults.standard.string(forKey: "syncOwnerID") != uid {
            wipeLocalData(modelContext: modelContext)
            UserDefaults.standard.set(uid, forKey: "syncOwnerID")
        }

        listen(collection: "rooms", uid: uid, modelContext: modelContext) { change in
            self.applyRoom(change: change, modelContext: modelContext)
        }

        listen(collection: "tenants", uid: uid, modelContext: modelContext) { change in
            self.applyTenant(change: change, modelContext: modelContext)
        }

        listen(collection: "payments", uid: uid, modelContext: modelContext) { change in
            self.applyPayment(change: change, modelContext: modelContext)
        }

        listen(collection: "activity", uid: uid, modelContext: modelContext) { change in
            self.applyActivity(change: change, modelContext: modelContext)
        }
    }

    private func markLoaded(collection: String, modelContext: ModelContext) {
        if loadedCollections.contains(collection) {
            return
        }

        loadedCollections.insert(collection)

        if loadedCollections.isSuperset(of: ["rooms", "tenants", "payments"]) {
            PortalController.shared.publishAll(modelContext: modelContext)
        }
    }

    func stop() {
        for listener in listeners {
            listener.remove()
        }
        listeners = []
        loadedCollections = []
    }

    private func listen(collection: String, uid: String, modelContext: ModelContext, onChange: @escaping (DocumentChange) -> Void) {
        let registration = db.collection(collection).whereField("ownerID", isEqualTo: uid).addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
            if let error = error {
                print("Sync error (\(collection)): \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot else {
                return
            }

            Task { @MainActor in
                for change in snapshot.documentChanges {
                    onChange(change)
                }

                if !snapshot.metadata.isFromCache {
                    self.markLoaded(collection: collection, modelContext: modelContext)
                }
            }
        }

        listeners.append(registration)
    }

    private func applyRoom(change: DocumentChange, modelContext: ModelContext) {
        guard let id = UUID(uuidString: change.document.documentID) else { return }

        let allRooms = (try? modelContext.fetch(FetchDescriptor<Room>())) ?? []
        let existing = allRooms.first(where: { $0.id == id })

        if change.type == .removed {
            if let existing = existing {
                modelContext.delete(existing)
            }
            return
        }

        let data = change.document.data()
        let number = data["number"] as? String ?? ""
        let wing = data["wing"] as? String ?? ""
        let monthlyRent = data["monthlyRent"] as? Int ?? 0

        if let existing = existing {
            existing.number = number
            existing.wing = wing
            existing.monthlyRent = monthlyRent
        } else {
            modelContext.insert(Room(id: id, number: number, wing: wing, monthlyRent: monthlyRent))
        }
    }

    private func applyTenant(change: DocumentChange, modelContext: ModelContext) {
        guard let id = UUID(uuidString: change.document.documentID) else { return }

        let allTenants = (try? modelContext.fetch(FetchDescriptor<Tenant>())) ?? []
        let existing = allTenants.first(where: { $0.id == id })

        if change.type == .removed {
            if let existing = existing {
                modelContext.delete(existing)
            }
            return
        }

        let data = change.document.data()
        let name = data["name"] as? String ?? ""
        let contact = data["contact"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let roomID = UUID(uuidString: data["roomID"] as? String ?? "") ?? UUID()
        let monthlyRent = data["monthlyRent"] as? Int ?? 0
        let nextDueDate = (data["nextDueDate"] as? Timestamp)?.dateValue() ?? Date()
        let accessCode = data["accessCode"] as? String ?? ""
        let notes = data["notes"] as? String ?? ""

        if let existing = existing {
            existing.name = name
            existing.contact = contact
            existing.email = email
            existing.roomID = roomID
            existing.monthlyRent = monthlyRent
            existing.nextDueDate = nextDueDate
            existing.accessCode = accessCode
            existing.notes = notes
        } else {
            modelContext.insert(Tenant(id: id, name: name, contact: contact, email: email, roomID: roomID, monthlyRent: monthlyRent, nextDueDate: nextDueDate, accessCode: accessCode, notes: notes))
        }
    }

    private func applyPayment(change: DocumentChange, modelContext: ModelContext) {
        guard let id = UUID(uuidString: change.document.documentID) else { return }

        let allPayments = (try? modelContext.fetch(FetchDescriptor<Payment>())) ?? []
        let existing = allPayments.first(where: { $0.id == id })

        if change.type == .removed {
            if let existing = existing {
                modelContext.delete(existing)
            }
            return
        }

        let data = change.document.data()
        let tenantID = UUID(uuidString: data["tenantID"] as? String ?? "") ?? UUID()
        let amount = data["amount"] as? Int ?? 0
        let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
        let method = data["method"] as? String ?? ""
        let notes = data["notes"] as? String ?? ""

        if let existing = existing {
            existing.tenantID = tenantID
            existing.amount = amount
            existing.date = date
            existing.method = method
            existing.notes = notes
        } else {
            modelContext.insert(Payment(id: id, tenantID: tenantID, amount: amount, date: date, method: method, notes: notes))
        }
    }

    private func applyActivity(change: DocumentChange, modelContext: ModelContext) {
        guard let id = UUID(uuidString: change.document.documentID) else { return }

        let allActivities = (try? modelContext.fetch(FetchDescriptor<ActivityLog>())) ?? []
        let existing = allActivities.first(where: { $0.id == id })

        if change.type == .removed {
            if let existing = existing {
                modelContext.delete(existing)
            }
            return
        }

        let data = change.document.data()
        let message = data["message"] as? String ?? ""
        let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
        let kind = data["kind"] as? String ?? ""

        if let existing = existing {
            existing.message = message
            existing.date = date
            existing.kind = kind
        } else {
            modelContext.insert(ActivityLog(id: id, message: message, date: date, kind: kind))
        }
    }

    private func wipeLocalData(modelContext: ModelContext) {
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
    }

    func save(room: Room) {
        write(collection: "rooms", id: room.id, data: [
            "number": room.number,
            "wing": room.wing,
            "monthlyRent": room.monthlyRent
        ])
    }

    func save(tenant: Tenant) {
        write(collection: "tenants", id: tenant.id, data: [
            "name": tenant.name,
            "contact": tenant.contact,
            "email": tenant.email,
            "roomID": tenant.roomID.uuidString,
            "monthlyRent": tenant.monthlyRent,
            "nextDueDate": Timestamp(date: tenant.nextDueDate),
            "accessCode": tenant.accessCode,
            "notes": tenant.notes
        ])
    }

    func save(payment: Payment) {
        write(collection: "payments", id: payment.id, data: [
            "tenantID": payment.tenantID.uuidString,
            "amount": payment.amount,
            "date": Timestamp(date: payment.date),
            "method": payment.method,
            "notes": payment.notes
        ])
    }

    func save(activity: ActivityLog) {
        write(collection: "activity", id: activity.id, data: [
            "message": activity.message,
            "date": Timestamp(date: activity.date),
            "kind": activity.kind
        ])
    }

    func delete(room: Room) {
        remove(collection: "rooms", id: room.id)
    }

    func delete(tenant: Tenant) {
        remove(collection: "tenants", id: tenant.id)
    }

    func delete(payment: Payment) {
        remove(collection: "payments", id: payment.id)
    }

    private func write(collection: String, id: UUID, data: [String: Any]) {
        let uid = ownerID
        if uid == "" {
            return
        }

        var fullData = data
        fullData["ownerID"] = uid

        db.collection(collection).document(id.uuidString).setData(fullData) { error in
            if let error = error {
                print("Sync error saving to \(collection): \(error.localizedDescription)")
            }
        }
    }

    private func remove(collection: String, id: UUID) {
        if ownerID == "" {
            return
        }

        db.collection(collection).document(id.uuidString).delete { error in
            if let error = error {
                print("Sync error deleting from \(collection): \(error.localizedDescription)")
            }
        }
    }
}
