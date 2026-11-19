//
//  SettingsView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 10/8/2026.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var rooms: [Room]
    @Query private var tenants: [Tenant]

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showPasswordAlert = false
    @State private var showSampleAlert = false
    @State private var sampleMessage = ""

    private let authController = AuthController()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Change Password")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .padding(.top, 10)

                LabeledSecureField(label: "Current Password", placeholder: "Enter current password", text: $currentPassword)
                LabeledSecureField(label: "New Password", placeholder: "At least 6 characters", text: $newPassword)
                LabeledSecureField(label: "Confirm New Password", placeholder: "Re-enter new password", text: $confirmPassword)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Color.dormeRed)
                }

                Button(action: {
                    updatePassword()
                }) {
                    Text(isLoading ? "Updating..." : "Update Password")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.dormeMaroon)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(isLoading)
                .padding(.top, 10)
                .alert("Password Updated", isPresented: $showPasswordAlert) {
                    Button("OK") {
                        dismiss()
                    }
                } message: {
                    Text("Your password has been changed.")
                }

                Divider()
                    .padding(.vertical, 10)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Demo Data")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)

                    Text("Adds sample rooms, tenants, and payments so you can try every screen. Only works when you have no rooms or tenants yet.")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Color.dormeGray)

                    Button(action: {
                        loadSampleData()
                    }) {
                        Text("Load Sample Data")
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
                }
                .padding(.bottom, 20)
                .alert("Sample Data", isPresented: $showSampleAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(sampleMessage)
                }
            }
            .padding(.horizontal, 24)
        }
        .background(Color.dormeBackground)
        .navigationTitle("Settings")
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
    }

    private func updatePassword() {
        if currentPassword == "" {
            errorMessage = "Please enter your current password."
            return
        }

        if newPassword.count < 6 {
            errorMessage = "New password must be at least 6 characters."
            return
        }

        if newPassword != confirmPassword {
            errorMessage = "New passwords do not match."
            return
        }

        isLoading = true
        errorMessage = ""

        Task {
            do {
                try await authController.changePassword(currentPassword: currentPassword, newPassword: newPassword)
                showPasswordAlert = true
            } catch {
                errorMessage = authController.message(for: error)
            }
            isLoading = false
        }
    }

    private func loadSampleData() {
        if !rooms.isEmpty || !tenants.isEmpty {
            sampleMessage = "You already have rooms or tenants, so sample data was not added."
        } else {
            SampleDataController().addSampleData(modelContext: modelContext)
            sampleMessage = "Sample rooms, tenants, and payments were added."
        }
        showSampleAlert = true
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
