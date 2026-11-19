//
//  LoginView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/7/2026.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var landlords: [Landlord]

    @Binding var currentLandlord: Landlord?
    @Binding var currentTenant: Tenant?

    @State private var isTenantLogin = false
    @State private var email = ""
    @State private var password = ""
    @State private var accessCode = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    private let authController = AuthController()

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(spacing: 10) {
                Text("Landlord")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(isTenantLogin ? Color.dormePeach.opacity(0.5) : Color.white)
                    .foregroundStyle(isTenantLogin ? Color.dormeGray : Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isTenantLogin ? Color.clear : Color.dormeMustard, lineWidth: 1.5)
                    )
                    .onTapGesture {
                        isTenantLogin = false
                        errorMessage = ""
                    }

                Text("Tenant")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(isTenantLogin ? Color.white : Color.dormePeach.opacity(0.5))
                    .foregroundStyle(isTenantLogin ? Color.black : Color.dormeGray)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isTenantLogin ? Color.dormeMustard : Color.clear, lineWidth: 1.5)
                    )
                    .onTapGesture {
                        isTenantLogin = true
                        errorMessage = ""
                    }
            }

            if isTenantLogin {
                LabeledField(label: "Email", placeholder: "name@email.com", text: $email, keyboard: .emailAddress)
                LabeledField(label: "Access Code", placeholder: "6-digit code from your landlord", text: $accessCode, keyboard: .numberPad)
            } else {
                LabeledField(label: "Email", placeholder: "name@email.com", text: $email, keyboard: .emailAddress)
                LabeledSecureField(label: "Password", placeholder: "Enter password", text: $password)

                HStack {
                    Spacer()

                    NavigationLink(destination: ForgotPasswordView()) {
                        Text("Forgot Password?")
                            .font(.system(.footnote, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                }
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(Color.dormeRed)
            }

            Spacer()

            Button(action: {
                logIn()
            }) {
                Text(isLoading ? "Logging in..." : "Log In")
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
        .navigationTitle("Log In")
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

    private func logIn() {
        if isTenantLogin {
            isLoading = true
            errorMessage = ""

            // If the landlord deletes this tenant or changes their code, log the tenant out.
            let tenantBinding = $currentTenant

            Task {
                do {
                    currentTenant = try await authController.tenantLogIn(email: email, code: accessCode, modelContext: modelContext, onRemoved: {
                        tenantBinding.wrappedValue = nil
                    })
                } catch {
                    errorMessage = authController.message(for: error)
                }
                isLoading = false
            }
        } else {
            if email.trimmingCharacters(in: .whitespaces) == "" || password == "" {
                errorMessage = "Please enter your email and password."
                return
            }

            isLoading = true
            errorMessage = ""

            Task {
                do {
                    currentLandlord = try await authController.logIn(email: email, password: password, landlords: landlords, modelContext: modelContext)
                } catch {
                    errorMessage = authController.message(for: error)
                }
                isLoading = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView(currentLandlord: .constant(nil), currentTenant: .constant(nil))
    }
    .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
