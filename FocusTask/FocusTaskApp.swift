//
//  FocusTaskApp.swift
//  FocusTask
//
//  Created by Lukas on 05/05/25.
//

import SwiftUI

@main
struct FocusTaskApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Todo.self)
    }
}
