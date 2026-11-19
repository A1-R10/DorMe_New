//
//  AddRoomView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/9/2026.
//

import SwiftUI
import SwiftData

struct AddRoomView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var rooms: [Room]

    @State private var roomNumber = ""
    @State private var wing = ""
    @State private var monthlyRent = ""
    @State private var errorMessage = ""

    private let roomController = RoomController()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LabeledField(label: "Room Number", placeholder: "Room 206", text: $roomNumber)
                LabeledField(label: "Dormitory Wing", placeholder: "2nd Floor, East Wing", text: $wing)
                LabeledField(label: "Monthly Rent (₱)", placeholder: "5,000", text: $monthlyRent, keyboard: .numberPad)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Color.dormeRed)
                }

                Button(action: {
                    saveRoom()
                }) {
                    Text("Save Room")
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
        .navigationTitle("Add Room")
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

    private func saveRoom() {
        if roomNumber.trimmingCharacters(in: .whitespaces) == "" {
            errorMessage = "Please enter a room number."
            return
        }

        if roomController.roomNumberExists(number: roomNumber, rooms: rooms) {
            errorMessage = "That room number already exists."
            return
        }

        guard let rent = Int(monthlyRent.replacingOccurrences(of: ",", with: "")), rent > 0 else {
            errorMessage = "Please enter a valid monthly rent."
            return
        }

        roomController.addRoom(number: roomNumber, wing: wing, monthlyRent: rent, modelContext: modelContext)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        AddRoomView()
    }
    .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
