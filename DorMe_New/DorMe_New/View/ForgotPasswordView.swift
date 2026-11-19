//
//  ForgotPasswordView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/7/2026.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss

    @State private var email = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showSuccessAlert = false

    private let authController = AuthController()

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("Enter the email you signed up with and we will send you a link to reset your password.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Color.dormeGray)

            LabeledField(label: "Email", placeholder: "name@email.com", text: $email, keyboard: .emailAddress)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(Color.dormeRed)
            }

            Spacer()

            Button(action: {
                sendResetLink()
            }) {
                Text(isLoading ? "Sending..." : "Send Reset Link")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.dormeMaroon)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(isLoading)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .background(Color.white)
        .navigationTitle("Forgot Password")
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
        .alert("Check Your Email", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("If an account exists for \(email), a password reset link has been sent. Check your spam folder too.")
        }
    }

    private func sendResetLink() {
        if email.trimmingCharacters(in: .whitespaces) == "" || !email.contains("@") {
            errorMessage = "Please enter a valid email address."
            return
        }

        isLoading = true
        errorMessage = ""

        Task {
            do {
                try await authController.sendPasswordReset(email: email)
                showSuccessAlert = true
            } catch {
                errorMessage = authController.message(for: error)
            }
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView()
    }
}
