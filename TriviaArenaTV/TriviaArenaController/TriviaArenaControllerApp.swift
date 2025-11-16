//
//  TriviaArenaControllerApp.swift
//  TriviaArenaController
//
//  Created by IM Student on 2025-11-16.
//

import SwiftUI
import CoreData

@main
struct TriviaArenaControllerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
