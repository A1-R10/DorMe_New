//
//  SignUpView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/4/2026.
//

import SwiftUI
import SwiftData

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var landlords: [Landlord]

    @Binding var currentLandlord: Landlord?
    @Binding var currentTenant: Tenant?

    @State private var fullName = ""
    @State private var email = ""
    @State private var contactNumber = ""
    @State private var dormitoryName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    private let authController = AuthController()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Create Landlord Account")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .padding(.top, 10)

                LabeledField(label: "Full Name", placeholder: "Juan Dela Cruz", text: $fullName)
                LabeledField(label: "Email Address", placeholder: "name@gmail.com", text: $email, keyboard: .emailAddress)
                LabeledField(label: "Contact Number", placeholder: "+63 9123456789", text: $contactNumber, keyboard: .phonePad)
                LabeledField(label: "Dormitory Name", placeholder: "Reyes Dormitory", text: $dormitoryName)
                LabeledSecureField(label: "Password", placeholder: "*********", text: $password)
                LabeledSecureField(label: "Confirm Password", placeholder: "*********", text: $confirmPassword)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Color.dormeRed)
                }

                Button(action: {
                    createAccount()
                }) {
                    Text(isLoading ? "Creating account..." : "Create Account")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.dormeMaroon)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(isLoading)
                .padding(.top, 10)

                HStack {
                    Spacer()
                    Text("Already have an account?")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Color.dormeGray)
                    NavigationLink(destination: LoginView(currentLandlord: $currentLandlord, currentTenant: $currentTenant)) {
                        Text("Log In")
                            .font(.system(.footnote, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 24)
        }
        .background(Color.white)
        .navigationTitle("Sign Up")
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

    private func createAccount() {
        if fullName.trimmingCharacters(in: .whitespaces) == "" || email.trimmingCharacters(in: .whitespaces) == "" || contactNumber.trimmingCharacters(in: .whitespaces) == "" || dormitoryName.trimmingCharacters(in: .whitespaces) == "" || password == "" {
            errorMessage = "Please fill in all fields."
            return
        }

        if !email.contains("@") {
            errorMessage = "Please enter a valid email address."
            return
        }

        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        if password != confirmPassword {
            errorMessage = "Passwords do not match."
            return
        }

        isLoading = true
        errorMessage = ""

        Task {
            do {
                currentLandlord = try await authController.signUp(fullName: fullName, email: email, contact: contactNumber, dormitoryName: dormitoryName, password: password, landlords: landlords, modelContext: modelContext)
            } catch {
                errorMessage = authController.message(for: error)
            }
            isLoading = false
        }
    }
}

struct LabeledField: View {

    var label: String
    var placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    private var capitalization: TextInputAutocapitalization {
        if keyboard == .emailAddress {
            return .never
        }
        return .words
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)

            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(capitalization)
                .autocorrectionDisabled()
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
}

struct LabeledSecureField: View {

    var label: String
    var placeholder: String
    @Binding var text: String
    @State private var showText = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)

            HStack {
                if showText {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }

                Button(action: {
                    showText.toggle()
                }) {
                    Image(systemName: showText ? "eye.slash" : "eye")
                        .foregroundStyle(Color.dormeGray)
                }
            }
            .textContentType(.oneTimeCode)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView(currentLandlord: .constant(nil), currentTenant: .constant(nil))
    }
    .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
