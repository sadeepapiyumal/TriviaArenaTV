//
//  TriviaArenaTVApp.swift
//  TriviaArenaTV
//
//  Created by IM Student on 2025-11-16.
//

import SwiftUI
import CoreData

@main
struct TriviaArenaTVApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
