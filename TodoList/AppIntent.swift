//
//  AppIntent.swift
//  TodoList
//
//  Created by Lukas on 05/05/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "k")
    var favoriteEmoji: String
}
