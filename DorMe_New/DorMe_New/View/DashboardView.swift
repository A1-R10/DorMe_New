//
//  DashboardView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/3/2026.
//

import SwiftUI
import SwiftData

struct DashboardView: View {

    @Query private var rooms: [Room]
    @Query private var tenants: [Tenant]
    @Query(sort: \ActivityLog.date, order: .reverse) private var activities: [ActivityLog]

    var landlord: Landlord
    @Binding var selectedTab: Int

    private let roomController = RoomController()
    private let dateController = DateController()
    private let formatController = FormatController()

    private var occupiedCount: Int {
        return rooms.filter { roomController.isOccupied(room: $0, tenants: tenants) }.count
    }

    private var unpaidCount: Int {
        return tenants.filter { dateController.status(for: $0) != .paid }.count
    }

    private var overdueCount: Int {
        return tenants.filter { dateController.status(for: $0) == .overdue }.count
    }

    private var recentActivities: [ActivityLog] {
        return Array(activities.prefix(5))
    }

    private var greetingText: String {
        let name = formatController.firstName(from: landlord.fullName)
        return "\(dateController.greeting()), \(name.isEmpty ? "Landlord" : name)!"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(greetingText)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Overview")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Color.dormeGray)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(title: "Total Rooms", value: "\(rooms.count)", color: Color.dormeMaroon)
                        StatCard(title: "Occupied", value: "\(occupiedCount)", color: Color.dormeMaroon)
                        StatCard(title: "Available", value: "\(rooms.count - occupiedCount)", color: Color.dormePositiveGreen)
                        StatCard(title: "Tenants", value: "\(tenants.count)", color: Color.dormeMaroon)
                        StatCard(title: "Unpaid", value: "\(unpaidCount)", color: Color.dormeMustard)
                        StatCard(title: "Overdue", value: "\(overdueCount)", color: Color.dormeRed)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Actions")
                        .font(.system(.headline, design: .rounded))

                    HStack(spacing: 12) {
                        NavigationLink(destination: AddTenantView()) {
                            QuickActionButton(title: "Add Tenant", systemImage: "plus", style: .outline(Color.dormeMustard))
                        }

                        NavigationLink(destination: RecordPaymentView()) {
                            QuickActionButton(title: "Record Pay", systemImage: "dollarsign.circle.fill", style: .outline(Color.dormePositiveGreen))
                        }

                        Button(action: {
                            selectedTab = 2
                        }) {
                            QuickActionButton(title: "View Rooms", systemImage: "eye", style: .subtleFill)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Activity")
                        .font(.system(.headline, design: .rounded))

                    if recentActivities.isEmpty {
                        Text("No activity yet.")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(Color.dormeGray)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        VStack(spacing: 0) {
                            ForEach(recentActivities) { activity in
                                ActivityRow(title: activity.message, timeAgo: dateController.timeAgo(from: activity.date), dotColor: dotColor(for: activity.kind))

                                if activity.id != recentActivities.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.dormeBackground)
        .navigationBarHidden(true)
    }

    private func dotColor(for kind: String) -> Color {
        if kind == "payment" {
            return Color.dormePositiveGreen
        } else if kind == "tenant" {
            return Color.blue
        } else {
            return Color.dormeGray
        }
    }
}

struct StatCard: View {

    var title: String
    var value: String
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(Color.dormeGray)

            Text(value)
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

enum QuickActionStyle {
    case outline(Color)
    case subtleFill
}

struct QuickActionButton: View {

    var title: String
    var systemImage: String
    var style: QuickActionStyle

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))

            Text(title)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .foregroundStyle(foregroundColor)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderColor, lineWidth: 1.5)
        )
    }

    private var foregroundColor: Color {
        switch style {
        case .outline(let color): return color
        case .subtleFill: return Color.black
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .outline: return Color.white
        case .subtleFill: return Color.dormeMustard.opacity(0.08)
        }
    }

    private var borderColor: Color {
        switch style {
        case .outline(let color): return color
        case .subtleFill: return Color.clear
        }
    }
}

struct ActivityRow: View {

    var title: String
    var timeAgo: String
    var dotColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)

            Text(title)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Color.black)

            Spacer()

            Text(timeAgo)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(Color.dormeGray)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        DashboardView(landlord: Landlord(fullName: "Roberto Reyes"), selectedTab: .constant(0))
    }
    .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
