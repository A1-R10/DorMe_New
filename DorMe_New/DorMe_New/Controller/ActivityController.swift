//
//  ActivityController.swift
//  DorMe_New
//
//  Created by Mac-LAB on 9/30/2026.
//

import Foundation
import SwiftData

struct ActivityController {

    func addActivity(message: String, kind: String, modelContext: ModelContext) {
        let activity = ActivityLog(message: message, kind: kind)
        modelContext.insert(activity)
        SyncController.shared.save(activity: activity)
    }
}
