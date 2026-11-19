//
//  AddTenantView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/9/2026.
//

import SwiftUI
import SwiftData

struct AddTenantView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var rooms: [Room]
    @Query private var tenants: [Tenant]

    var preselectedRoom: Room?

    @State private var fullName = ""
    @State private var contactNumber = ""
    @State private var email = ""
    @State private var selectedRoomID = UUID()
    @State private var monthlyRent = ""
    @State private var firstDueDate = Date()
    @State private var optionalNotes = ""
    @State private var errorMessage = ""
    @State private var newAccessCode = ""
    @State private var showCodeAlert = false
    @State private var showShareSheet = false
    @State private var shareText = ""

    private let tenantController = TenantController()
    private let roomController = RoomController()

    init(preselectedRoom: Room? = nil) {
        self.preselectedRoom = preselectedRoom
    }

    private var availableRooms: [Room] {
        return roomController.availableRooms(rooms: rooms, tenants: tenants)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LabeledField(label: "Full Name", placeholder: "Juan Dela Cruz", text: $fullName)
                LabeledField(label: "Contact Number", placeholder: "+63 9123456789", text: $contactNumber, keyboard: .phonePad)
                LabeledField(label: "Email", placeholder: "name@email.com", text: $email, keyboard: .emailAddress)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Select Room")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)

                    if availableRooms.isEmpty {
                        Text("No rooms are available. Add a room or free one up first.")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(Color.dormeGray)
                    } else {
                        Picker("Select Room", selection: $selectedRoomID) {
                            ForEach(availableRooms) { room in
                                Text("\(room.number) (Available)").tag(room.id)
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
                }

                LabeledField(label: "Monthly Rent (₱)", placeholder: "5,000", text: $monthlyRent, keyboard: .numberPad)
                LabeledDateField(label: "First Due Date", date: $firstDueDate)
                LabeledField(label: "Optional Notes", placeholder: "Extra Details", text: $optionalNotes)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Color.dormeRed)
                }

                Button(action: {
                    saveTenant()
                }) {
                    Text("Save Tenant")
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
            .padding(.top, 10)
        }
        .background(Color.dormeBackground)
        .navigationTitle("Add Tenant")
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
            if let preselectedRoom {
                selectedRoomID = preselectedRoom.id
                monthlyRent = "\(preselectedRoom.monthlyRent)"
            } else if let firstAvailable = availableRooms.first {
                selectedRoomID = firstAvailable.id
                monthlyRent = "\(firstAvailable.monthlyRent)"
            }
        }
        .onChange(of: selectedRoomID) {
            if let room = rooms.first(where: { $0.id == selectedRoomID }) {
                monthlyRent = "\(room.monthlyRent)"
            }
        }
        .alert("Tenant Added", isPresented: $showCodeAlert) {
            Button("Share Code") {
                showShareSheet = true
            }
            Button("Done", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Give this login code to \(fullName): \(newAccessCode)")
        }
        .sheet(isPresented: $showShareSheet, onDismiss: {
            dismiss()
        }) {
            ShareSheet(text: shareText)
                .presentationDetents([.medium, .large])
        }
    }

    private func saveTenant() {
        if fullName.trimmingCharacters(in: .whitespaces) == "" {
            errorMessage = "Please enter the tenant's full name."
            return
        }

        if email.trimmingCharacters(in: .whitespaces) == "" || !email.contains("@") {
            errorMessage = "Please enter the tenant's email address."
            return
        }

        if availableRooms.isEmpty || !availableRooms.contains(where: { $0.id == selectedRoomID }) {
            errorMessage = "Please select an available room."
            return
        }

        guard let rent = Int(monthlyRent.replacingOccurrences(of: ",", with: "")), rent > 0 else {
            errorMessage = "Please enter a valid monthly rent."
            return
        }

        let tenant = tenantController.addTenant(name: fullName, contact: contactNumber, email: email, roomID: selectedRoomID, monthlyRent: rent, firstDueDate: firstDueDate, notes: optionalNotes, tenants: tenants, modelContext: modelContext)

        newAccessCode = tenant.accessCode
        shareText = tenantController.shareMessage(for: tenant)
        errorMessage = ""
        showCodeAlert = true
    }
}

#Preview {
    NavigationStack {
        AddTenantView()
    }
    .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
