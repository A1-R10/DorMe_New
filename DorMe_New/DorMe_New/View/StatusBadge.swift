//
//  StatusBadge.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/14/2026.
//

import SwiftUI

struct StatusBadge: View {

    var status: PaymentStatus

    var body: some View {
        Text(status.rawValue)
            .font(.system(.caption2, design: .rounded))
            .fontWeight(.bold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch status {
        case .paid:
            return .dormeTransparentGreen
        case .dueSoon:
            return .dormePeach
        case .overdue:
            return Color.dormeRed.opacity(0.12)
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .paid:
            return .dormePositiveGreen
        case .dueSoon:
            return .dormeAmber
        case .overdue:
            return .dormeRed
        }
    }
}

struct RoomStatusBadge: View {

    var status: RoomStatus

    var body: some View {
        Text(status.rawValue)
            .font(.system(.caption2, design: .rounded))
            .fontWeight(.bold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(status == .occupied ? Color.dormePeach : Color.dormeTransparentGreen)
            .foregroundStyle(status == .occupied ? Color.dormeAmber : Color.dormePositiveGreen)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 12) {
        StatusBadge(status: .paid)
        StatusBadge(status: .dueSoon)
        StatusBadge(status: .overdue)
        RoomStatusBadge(status: .occupied)
        RoomStatusBadge(status: .available)
    }
    .padding()
    .background(Color.dormeBackground)
}
