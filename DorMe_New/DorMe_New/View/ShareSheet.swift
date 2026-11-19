//
//  ShareSheet.swift
//  DorMe_New
//
//  Created by Mac-LAB on 10/18/2026.
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {

    var text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}
