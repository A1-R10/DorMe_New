//
//  ProfileView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/15/2026.
//

import SwiftUI

struct ProfileView: View {

    var landlord: Landlord
    @Binding var currentLandlord: Landlord?

    private let authController = AuthController()

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Profile")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .padding(.top, 8)

            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 16) {
                    ProfileAvatar(name: landlord.fullName)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(landlord.fullName)
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(Color.black)

                        Text(landlord.dormitoryName.isEmpty ? "Add your dormitory name" : landlord.dormitoryName)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(Color.dormeMaroon)
                    }

                    Spacer()
                }
                .padding(.bottom, 10)

                Divider()

                DetailRow(label: "Contact", value: landlord.contact.isEmpty ? "Not set" : landlord.contact)
                Divider()
                DetailRow(label: "Email", value: landlord.email)
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(spacing: 0) {
                NavigationLink(destination: EditProfileView(landlord: landlord)) {
                    ProfileMenuRow(title: "Edit Profile")
                }

                Divider()

                NavigationLink(destination: SettingsView()) {
                    ProfileMenuRow(title: "Settings")
                }

                Divider()

                Button(action: {
                    authController.logOut()
                    currentLandlord = nil
                }) {
                    Text("Log Out")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.dormeRed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                        .background(Color.white)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()
        }
        .padding(.horizontal, 20)
        .background(Color.dormeBackground)
        .navigationBarHidden(true)
    }
}

struct ProfileMenuRow: View {

    var title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Color.black)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.dormeGray)
        }
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

#Preview {
    NavigationStack {
        ProfileView(landlord: Landlord(fullName: "Roberto Reyes", email: "roberto@email.com"), currentLandlord: .constant(nil))
    }
}
