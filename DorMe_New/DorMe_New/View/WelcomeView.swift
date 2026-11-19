//
//  WelcomeView.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/3/2026.
//

import SwiftUI

struct WelcomeView: View {

    @Binding var currentLandlord: Landlord?
    @Binding var currentTenant: Tenant?

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.dormeMaroon)
                            .frame(width: 72, height: 72)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.dormeMustard, lineWidth: 3)
                            )

                        Image(systemName: "building.2.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                    }

                    HStack(spacing: 0) {
                        Text("Dor")
                            .foregroundStyle(Color.dormeMaroon)
                        Text("Me")
                            .foregroundStyle(Color.dormeMustard)
                    }
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                }

                Spacer()

                VStack(spacing: 16) {
                    NavigationLink(destination: LoginView(currentLandlord: $currentLandlord, currentTenant: $currentTenant)) {
                        Text("Log In")
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.dormeMaroon)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    HStack {
                        Text("Don't have an account?")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(Color.dormeGray)

                        NavigationLink(destination: SignUpView(currentLandlord: $currentLandlord, currentTenant: $currentTenant)) {
                            Text("Sign Up")
                                .font(.system(.footnote, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(Color.white)
        }
    }
}

#Preview {
    WelcomeView(currentLandlord: .constant(nil), currentTenant: .constant(nil))
}
