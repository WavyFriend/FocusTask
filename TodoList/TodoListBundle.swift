//
//  TodoListBundle.swift
//  TodoList
//
//  Created by Lukas on 05/05/25.
//

import WidgetKit
import SwiftUI

@main
struct TodoListBundle: WidgetBundle {
    var body: some Widget {
        TodoList()
        TodoListControl()
        TodoListLiveActivity()
    }
}
