//
//  ProfileAvatar.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/15/2026.
//

import SwiftUI

struct ProfileAvatar: View {

    var name: String
    var size: CGFloat = 56

    private let formatController = FormatController()

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.dormePeach.opacity(0.4))
                .frame(width: size, height: size)

            Circle()
                .stroke(Color.dormeMustard, lineWidth: 2)
                .frame(width: size, height: size)

            Text(formatController.initials(for: name))
                .font(.system(size: size * 0.32, weight: .bold, design: .rounded))
                .foregroundStyle(Color.dormeMaroon)
        }
    }
}

#Preview {
    ProfileAvatar(name: "Juan Cruz")
}
