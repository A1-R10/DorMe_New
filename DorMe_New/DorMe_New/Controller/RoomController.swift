//
//  RoomController.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/25/2026.
//

import Foundation
import SwiftData

struct RoomController {

    func tenant(in room: Room, tenants: [Tenant]) -> Tenant? {
        return tenants.first(where: { $0.roomID == room.id })
    }

    func isOccupied(room: Room, tenants: [Tenant]) -> Bool {
        return tenant(in: room, tenants: tenants) != nil
    }

    func status(of room: Room, tenants: [Tenant]) -> RoomStatus {
        if isOccupied(room: room, tenants: tenants) {
            return .occupied
        }
        return .available
    }

    func availableRooms(rooms: [Room], tenants: [Tenant]) -> [Room] {
        return rooms.filter { !isOccupied(room: $0, tenants: tenants) }
    }

    func roomNumber(for roomID: UUID, rooms: [Room]) -> String {
        let room = rooms.first(where: { $0.id == roomID })
        return room?.number ?? "No room"
    }

    func roomNumberExists(number: String, rooms: [Room], excluding: Room? = nil) -> Bool {
        for room in rooms {
            if room.number.lowercased() == number.trimmingCharacters(in: .whitespaces).lowercased() && room.id != excluding?.id {
                return true
            }
        }
        return false
    }

    func addRoom(number: String, wing: String, monthlyRent: Int, modelContext: ModelContext) {
        let room = Room(number: number.trimmingCharacters(in: .whitespaces), wing: wing.trimmingCharacters(in: .whitespaces), monthlyRent: monthlyRent)

        modelContext.insert(room)
        SyncController.shared.save(room: room)
        ActivityController().addActivity(message: "\(room.number) was added", kind: "room", modelContext: modelContext)
    }

    func updateRoom(room: Room, number: String, wing: String, monthlyRent: Int) {
        room.number = number.trimmingCharacters(in: .whitespaces)
        room.wing = wing.trimmingCharacters(in: .whitespaces)
        room.monthlyRent = monthlyRent

        SyncController.shared.save(room: room)

        // Tenants in this room see the room number and wing in their portal.
        if let modelContext = room.modelContext {
            PortalController.shared.publishTenants(inRoom: room.id, modelContext: modelContext)
        }
    }

    func deleteRoom(room: Room, modelContext: ModelContext) {
        ActivityController().addActivity(message: "\(room.number) was removed", kind: "room", modelContext: modelContext)
        SyncController.shared.delete(room: room)
        modelContext.delete(room)
    }
}
