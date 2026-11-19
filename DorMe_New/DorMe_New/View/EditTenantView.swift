//
//  EditTenantView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 10/14/2026.
//

import SwiftUI
import SwiftData

struct EditTenantView: View {
    @Environment(\.dismiss) var dismiss
    @Query private var rooms: [Room]
    @Query private var tenants: [Tenant]

    var tenant: Tenant

    @State private var fullName = ""
    @State private var contactNumber = ""
    @State private var email = ""
    @State private var selectedRoomID = UUID()
    @State private var monthlyRent = ""
    @State private var optionalNotes = ""
    @State private var errorMessage = ""

    private let tenantController = TenantController()
    private let roomController = RoomController()

    private var roomOptions: [Room] {
        return rooms.filter { !roomController.isOccupied(room: $0, tenants: tenants) || $0.id == tenant.roomID }
    }

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
                LabeledField(label: "Contact Number", placeholder: "+63 9123456789", text: $contactNumber, keyboard: .phonePad)
                LabeledField(label: "Email", placeholder: "name@email.com", text: $email, keyboard: .emailAddress)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Room")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)

                    Picker("Room", selection: $selectedRoomID) {
                        ForEach(roomOptions) { room in
                            Text(room.number).tag(room.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }

                LabeledField(label: "Monthly Rent (₱)", placeholder: "5,000", text: $monthlyRent, keyboard: .numberPad)
                LabeledField(label: "Optional Notes", placeholder: "Extra Details", text: $optionalNotes)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Color.dormeRed)
                }

                Button(action: {
                    saveChanges()
                }) {
                    Text("Save Changes")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.dormeMaroon)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 24)
        }
        .background(Color.dormeBackground)
        .navigationTitle("Edit Tenant")
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
            fullName = tenant.name
            contactNumber = tenant.contact
            email = tenant.email
            selectedRoomID = tenant.roomID
            monthlyRent = "\(tenant.monthlyRent)"
            optionalNotes = tenant.notes
        }
    }

    private func saveChanges() {
        if fullName.trimmingCharacters(in: .whitespaces) == "" {
            errorMessage = "Please enter the tenant's full name."
            return
        }

        if email.trimmingCharacters(in: .whitespaces) == "" || !email.contains("@") {
            errorMessage = "Please enter the tenant's email address."
            return
        }

        guard let rent = Int(monthlyRent.replacingOccurrences(of: ",", with: "")), rent > 0 else {
            errorMessage = "Please enter a valid monthly rent."
            return
        }

        tenantController.updateTenant(tenant: tenant, name: fullName, contact: contactNumber, email: email, roomID: selectedRoomID, monthlyRent: rent, notes: optionalNotes)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        EditTenantView(tenant: Tenant(name: "Juan Dela Cruz", monthlyRent: 5000))
    }
    .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
