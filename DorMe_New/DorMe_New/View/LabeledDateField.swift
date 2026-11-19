//
//  LabeledDateField.swift
//  DorMe_New
//
//  Created by Mac-LAB on 10/14/2026.
//

import SwiftUI

struct LabeledDateField: View {

    var label: String
    @Binding var date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)

            HStack {
                DatePicker("", selection: $date, displayedComponents: .date)
                    .labelsHidden()

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}

#Preview {
    LabeledDateField(label: "Payment Date", date: .constant(Date()))
        .padding()
}
