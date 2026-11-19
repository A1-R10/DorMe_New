//
//  RoomsListView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/16/2026.
//

import SwiftUI
import SwiftData

struct RoomsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Room.number) private var rooms: [Room]
    @Query private var tenants: [Tenant]

    @State private var showOccupiedAlert = false

    private let roomController = RoomController()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rooms")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)

                    Text("Overview of your dormitory units.")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Color.dormeGray)
                }

                Spacer()

                NavigationLink(destination: AddRoomView()) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.dormeMustard)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 8)

            if rooms.isEmpty {
                Spacer()
                Text("No rooms yet. Tap + to add one.")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Color.dormeGray)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                List {
                    ForEach(rooms) { room in
                        ZStack(alignment: .leading) {
                            NavigationLink(destination: RoomDetailView(roomID: room.id)) {
                                EmptyView()
                            }
                            .opacity(0)

                            RoomRow(room: room, tenantName: roomController.tenant(in: room, tenants: tenants)?.name, status: roomController.status(of: room, tenants: tenants))
                        }
                    }
                    .onDelete(perform: deleteRoom)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.dormeBackground)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color.dormeBackground)
        .navigationBarHidden(true)
        .alert("Room Is Occupied", isPresented: $showOccupiedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Remove the tenant or move them to another room before deleting this room.")
        }
    }

    private func deleteRoom(indexSet: IndexSet) {
        for index in indexSet {
            let room = rooms[index]

            if roomController.isOccupied(room: room, tenants: tenants) {
                showOccupiedAlert = true
            } else {
                roomController.deleteRoom(room: room, modelContext: modelContext)
            }
        }
    }
}

struct RoomRow: View {

    var room: Room
    var tenantName: String?
    var status: RoomStatus

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(room.number)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.black)

                Text(tenantName.map { "Tenant: \($0)" } ?? "No active tenant")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(Color.dormeGray)
            }

            Spacer()

            RoomStatusBadge(status: status)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        RoomsListView()
    }
    .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
