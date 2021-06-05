//
//  ProjectSY2App.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI

@main
struct ProjectSY2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            LandingView()
                .environmentObject(LandingViewData())
        }
    }
}
