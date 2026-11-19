//
//  TenantProfileView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/11/2026.
//

import SwiftUI
import SwiftData

struct TenantProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var rooms: [Room]

    var tenant: Tenant
    @Binding var currentTenant: Tenant?

    private let roomController = RoomController()
    private let authController = AuthController()

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Profile")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .padding(.top, 8)

            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 16) {
                    ProfileAvatar(name: tenant.name)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(tenant.name)
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(Color.black)

                        Text(roomController.roomNumber(for: tenant.roomID, rooms: rooms))
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(Color.dormeMaroon)
                    }

                    Spacer()
                }
                .padding(.bottom, 10)

                Divider()

                DetailRow(label: "Contact", value: tenant.contact.isEmpty ? "Not set" : tenant.contact)
                Divider()
                DetailRow(label: "Email", value: tenant.email.isEmpty ? "Not set" : tenant.email)
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Text("To update your details, please contact your landlord.")
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(Color.dormeGray)

            VStack(spacing: 0) {
                Button(action: {
                    currentTenant = nil
                    authController.tenantLogOut(modelContext: modelContext)
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

#Preview {
    NavigationStack {
        TenantProfileView(tenant: Tenant(name: "Juan Dela Cruz"), currentTenant: .constant(nil))
    }
    .modelContainer(for: [Landlord.self, Room.self, Tenant.self, Payment.self, ActivityLog.self], inMemory: true)
}
