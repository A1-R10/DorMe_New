//
//  DateController.swift
//  DorMe_New
//
//  Created by Mac-LAB on 10/21/2026.
//

import Foundation

struct DateController {

    func today() -> Date {
        return Calendar.current.startOfDay(for: Date())
    }

    func daysUntil(_ date: Date) -> Int {
        let dueDay = Calendar.current.startOfDay(for: date)
        let difference = Calendar.current.dateComponents([.day], from: today(), to: dueDay)
        return difference.day ?? 0
    }

    func status(for tenant: Tenant) -> PaymentStatus {
        let days = daysUntil(tenant.nextDueDate)

        if days < 0 {
            return .overdue
        } else if days <= 7 {
            return .dueSoon
        } else {
            return .paid
        }
    }

    func addOneMonth(to date: Date) -> Date {
        return Calendar.current.date(byAdding: .month, value: 1, to: date) ?? date
    }

    func subtractOneMonth(from date: Date) -> Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: date) ?? date
    }

    func daysFromNow(_ days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    func dayWord(_ count: Int) -> String {
        if count == 1 {
            return "day"
        }
        return "days"
    }

    func dueText(for tenant: Tenant) -> String {
        let days = daysUntil(tenant.nextDueDate)

        if days < 0 {
            return "Overdue by \(abs(days)) \(dayWord(abs(days)))"
        } else if days == 0 {
            return "Due today"
        } else if days <= 7 {
            return "Due in \(days) \(dayWord(days))"
        } else {
            return "Next due \(formattedDate(tenant.nextDueDate))"
        }
    }

    func timeAgo(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        let minutes = seconds / 60
        let hours = minutes / 60
        let days = hours / 24

        if seconds < 60 {
            return "Just now"
        } else if minutes < 60 {
            return "\(minutes) \(minutes == 1 ? "minute" : "minutes") ago"
        } else if hours < 24 {
            return "\(hours) \(hours == 1 ? "hour" : "hours") ago"
        } else {
            return "\(days) \(dayWord(days)) ago"
        }
    }

    func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())

        if hour < 12 {
            return "Good morning"
        } else if hour < 18 {
            return "Good afternoon"
        } else {
            return "Good evening"
        }
    }
}
