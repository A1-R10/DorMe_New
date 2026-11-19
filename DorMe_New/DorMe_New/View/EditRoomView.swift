//
//  EditRoomView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 10/5/2026.
//

import SwiftUI
import SwiftData

struct EditRoomView: View {
    @Environment(\.dismiss) var dismiss
    @Query private var rooms: [Room]

    var room: Room

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
            .padding(.top, 10)
        }
        .background(Color.dormeBackground)
        .navigationTitle("Edit Room")
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
            roomNumber = room.number
            wing = room.wing
            monthlyRent = "\(room.monthlyRent)"
        }
    }

    private func saveChanges() {
        if roomNumber.trimmingCharacters(in: .whitespaces) == "" {
            errorMessage = "Please enter a room number."
            return
        }

        if roomController.roomNumberExists(number: roomNumber, rooms: rooms, excluding: room) {
            errorMessage = "That room number already exists."
            return
        }

        guard let rent = Int(monthlyRent.replacingOccurrences(of: ",", with: "")), rent > 0 else {
            errorMessage = "Please enter a valid monthly rent."
            return
        }

        roomController.updateRoom(room: room, number: roomNumber, wing: wing, monthlyRent: rent)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        EditRoomView(room: Room(number: "Room 201", wing: "2nd Floor, East Wing", monthlyRent: 5000))
    }
    .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
