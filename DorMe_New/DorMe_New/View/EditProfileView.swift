//
//  EditProfileView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 10/2/2026.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss

    var landlord: Landlord

    @State private var fullName = ""
    @State private var contactNumber = ""
    @State private var dormitoryName = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    private let authController = AuthController()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    ProfileAvatar(name: fullName, size: 72)
                    Spacer()
                }
                .padding(.top, 10)

                LabeledField(label: "Full Name", placeholder: "Juan Dela Cruz", text: $fullName)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Email Address")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)

                    Text(landlord.email)
                        .foregroundStyle(Color.dormeGray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text("Your email is your login ID, so it can't be changed here.")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Color.dormeGray)
                }

                LabeledField(label: "Contact Number", placeholder: "+63 9123456789", text: $contactNumber, keyboard: .phonePad)
                LabeledField(label: "Dormitory Name", placeholder: "Reyes Dormitory", text: $dormitoryName)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Color.dormeRed)
                }

                Button(action: {
                    saveChanges()
                }) {
                    Text(isLoading ? "Saving..." : "Save Changes")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.dormeMaroon)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(isLoading)
                .padding(.top, 10)
            }
            .padding(.horizontal, 24)
        }
        .background(Color.dormeBackground)
        .navigationTitle("Edit Profile")
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
            fullName = landlord.fullName
            contactNumber = landlord.contact
            dormitoryName = landlord.dormitoryName
        }
    }

    private func saveChanges() {
        if fullName.trimmingCharacters(in: .whitespaces) == "" {
            errorMessage = "Please enter your full name."
            return
        }

        isLoading = true
        errorMessage = ""

        Task {
            do {
                try await authController.updateProfile(landlord: landlord, fullName: fullName, contact: contactNumber, dormitoryName: dormitoryName)
                dismiss()
            } catch {
                errorMessage = authController.message(for: error)
            }
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileView(landlord: Landlord(fullName: "Roberto Reyes", email: "roberto@email.com"))
    }
}
