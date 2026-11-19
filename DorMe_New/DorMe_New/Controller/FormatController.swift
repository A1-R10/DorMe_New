//
//  FormatController.swift
//  DorMe_New
//
//  Created by Mac-LAB on 10/23/2026.
//

import Foundation

struct FormatController {

    func initials(for name: String) -> String {
        let words = name.split(separator: " ")

        if words.count == 0 {
            return "?"
        }

        let firstLetter = String(words[0].prefix(1))

        if words.count == 1 {
            return firstLetter.uppercased()
        }

        let lastLetter = String(words[words.count - 1].prefix(1))
        return (firstLetter + lastLetter).uppercased()
    }

    func cleanEmail(_ email: String) -> String {
        return email.trimmingCharacters(in: .whitespaces).lowercased()
    }

    func firstName(from name: String) -> String {
        let words = name.split(separator: " ")

        if words.count == 0 {
            return ""
        }

        return String(words[0])
    }

    func peso(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let text = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "₱" + text
    }
}
