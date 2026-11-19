//
//  RoomDetailView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/8/2026.
//

import SwiftUI
import SwiftData

struct RoomDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var rooms: [Room]
    @Query private var tenants: [Tenant]

    var roomID: UUID

    @State private var showDeleteAlert = false

    private let roomController = RoomController()
    private let formatController = FormatController()

    private var room: Room? {
        return rooms.first(where: { $0.id == roomID })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let room = room {
                roomContent(for: room)
            } else {
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(Color.dormeBackground)
        .navigationTitle(room?.number ?? "")
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
        .alert("Delete Room?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let room = room {
                    roomController.deleteRoom(room: room, modelContext: modelContext)
                }
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This room will be permanently removed.")
        }
    }

    @ViewBuilder
    private func roomContent(for room: Room) -> some View {
        let occupant = roomController.tenant(in: room, tenants: tenants)

        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.dormeMustard)

            VStack(spacing: 8) {
                Image(systemName: "house.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)

                Text(room.number)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }
        .frame(height: 160)
        .padding(.top, 8)

        VStack(spacing: 0) {
            HStack {
                Text("Current Status")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Color.dormeGray)

                Spacer()

                Text(occupant == nil ? "Available" : "Occupied")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(occupant == nil ? Color.dormePositiveGreen : Color.dormeAmber)
            }
            .padding(.vertical, 10)

            Divider()
            DetailRow(label: "Tenant", value: occupant?.name ?? "No active tenant")
            Divider()
            DetailRow(label: "Monthly Rent", value: formatController.peso(room.monthlyRent))
            Divider()
            DetailRow(label: "Dormitory Wing", value: room.wing)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))

        Spacer()

        VStack(spacing: 12) {
            if occupant == nil {
                NavigationLink(destination: AddTenantView(preselectedRoom: room)) {
                    Text("Assign Tenant")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.dormeMaroon)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }

            NavigationLink(destination: EditRoomView(room: room)) {
                Text("Edit Room")
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

            if occupant == nil {
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Text("Delete Room")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Color.dormeRed)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.dormeRed, lineWidth: 1.5)
                        )
                }
            } else {
                Text("Remove or move the tenant before deleting this room.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(Color.dormeGray)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    NavigationStack {
        RoomDetailView(roomID: UUID())
    }
    .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
