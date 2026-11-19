//
//  AuthController.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/14/2026.
//

import Foundation
import SwiftData
import FirebaseAuth
import FirebaseFirestore

struct AppError: Error {
    var message: String
}

struct AuthController {

    private let formatController = FormatController()

    private var db: Firestore {
        return Firestore.firestore()
    }

    @MainActor
    func signUp(fullName: String, email: String, contact: String, dormitoryName: String, password: String, landlords: [Landlord], modelContext: ModelContext) async throws -> Landlord {
        let cleanEmail = formatController.cleanEmail(email)

        let result = try await Auth.auth().createUser(withEmail: cleanEmail, password: password)

        let profile: [String: Any] = [
            "fullName": fullName.trimmingCharacters(in: .whitespaces),
            "email": cleanEmail,
            "contact": contact.trimmingCharacters(in: .whitespaces),
            "dormitoryName": dormitoryName.trimmingCharacters(in: .whitespaces)
        ]
        try await db.collection("landlords").document(result.user.uid).setData(profile)

        let landlord = saveLocalCopy(profile: profile, email: cleanEmail, landlords: landlords, modelContext: modelContext)
        SyncController.shared.start(modelContext: modelContext)
        return landlord
    }

    @MainActor
    func logIn(email: String, password: String, landlords: [Landlord], modelContext: ModelContext) async throws -> Landlord {
        let cleanEmail = formatController.cleanEmail(email)

        let result = try await Auth.auth().signIn(withEmail: cleanEmail, password: password)
        let profile = try await loadProfile(uid: result.user.uid, email: cleanEmail)

        let landlord = saveLocalCopy(profile: profile, email: cleanEmail, landlords: landlords, modelContext: modelContext)
        SyncController.shared.start(modelContext: modelContext)
        return landlord
    }

    @MainActor
    func restoreSession(landlords: [Landlord], modelContext: ModelContext) async -> Landlord? {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            return nil
        }

        let cleanEmail = formatController.cleanEmail(email)

        SyncController.shared.start(modelContext: modelContext)

        if let profile = try? await loadProfile(uid: user.uid, email: cleanEmail) {
            return saveLocalCopy(profile: profile, email: cleanEmail, landlords: landlords, modelContext: modelContext)
        }

        return landlords.first(where: { $0.email == cleanEmail })
    }

    func logOut() {
        SyncController.shared.stop()
        try? Auth.auth().signOut()
    }

    @MainActor
    func updateProfile(landlord: Landlord, fullName: String, contact: String, dormitoryName: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AppError(message: "You are not logged in.")
        }

        let changes: [String: Any] = [
            "fullName": fullName.trimmingCharacters(in: .whitespaces),
            "contact": contact.trimmingCharacters(in: .whitespaces),
            "dormitoryName": dormitoryName.trimmingCharacters(in: .whitespaces)
        ]

        try await db.collection("landlords").document(user.uid).setData(changes, merge: true)

        landlord.fullName = fullName.trimmingCharacters(in: .whitespaces)
        landlord.contact = contact.trimmingCharacters(in: .whitespaces)
        landlord.dormitoryName = dormitoryName.trimmingCharacters(in: .whitespaces)

        // Tenants see the landlord's name, contact, and dormitory name in their portal.
        if let modelContext = landlord.modelContext {
            PortalController.shared.publishAll(modelContext: modelContext)
        }
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw AppError(message: "You are not logged in.")
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        _ = try await user.reauthenticate(with: credential)
        try await user.updatePassword(to: newPassword)
    }

    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: formatController.cleanEmail(email))
    }


    @MainActor
    func tenantLogIn(email: String, code: String, modelContext: ModelContext, onRemoved: @escaping () -> Void) async throws -> Tenant {
        if email.trimmingCharacters(in: .whitespaces) == "" || code.trimmingCharacters(in: .whitespaces).count != 6 {
            throw AppError(message: "Please enter your email and 6-digit access code.")
        }

        return try await PortalController.shared.tenantLogIn(email: email, code: code, modelContext: modelContext, onRemoved: onRemoved)
    }

    @MainActor
    func restoreTenantSession(modelContext: ModelContext, onRemoved: @escaping () -> Void) -> Tenant? {
        return PortalController.shared.restoreTenant(modelContext: modelContext, onRemoved: onRemoved)
    }

    @MainActor
    func tenantLogOut(modelContext: ModelContext) {
        PortalController.shared.tenantLogOut(modelContext: modelContext)
    }


    // Firebase errors have a number (code). We turn the common ones into plain sentences.
    func message(for error: Error) -> String {
        if let appError = error as? AppError {
            return appError.message
        }

        let nsError = error as NSError

        if nsError.domain == "FIRAuthErrorDomain" {
            switch nsError.code {
            case 17007: return "That email is already registered."
            case 17008: return "Please enter a valid email address."
            case 17026: return "Password must be at least 6 characters."
            case 17004, 17009, 17011: return "Incorrect email or password."
            case 17010: return "Too many attempts. Please wait a moment and try again."
            case 17020: return "No internet connection. Please try again."
            default: return nsError.localizedDescription
            }
        }

        if nsError.domain == "FIRFirestoreErrorDomain" {
            if nsError.code == 7 {
                return "The database refused the request. Check your Firestore rules."
            }
            if nsError.code == 14 {
                return "No internet connection. Please try again."
            }
        }

        return nsError.localizedDescription
    }

    // Reads the landlord's profile document. If it does not exist yet, it makes one.
    private func loadProfile(uid: String, email: String) async throws -> [String: Any] {
        let reference = db.collection("landlords").document(uid)
        let snapshot = try await reference.getDocument()

        if let data = snapshot.data() {
            return data
        }

        let newProfile: [String: Any] = [
            "fullName": "Landlord",
            "email": email,
            "contact": "",
            "dormitoryName": ""
        ]
        try? await reference.setData(newProfile)
        return newProfile
    }

    @MainActor
    private func saveLocalCopy(profile: [String: Any], email: String, landlords: [Landlord], modelContext: ModelContext) -> Landlord {
        let fullName = profile["fullName"] as? String ?? ""
        let contact = profile["contact"] as? String ?? ""
        let dormitoryName = profile["dormitoryName"] as? String ?? ""

        if let existing = landlords.first(where: { $0.email == email }) {
            existing.fullName = fullName
            existing.contact = contact
            existing.dormitoryName = dormitoryName
            return existing
        }

        let landlord = Landlord(fullName: fullName, email: email, contact: contact, dormitoryName: dormitoryName)
        modelContext.insert(landlord)
        return landlord
    }
}
