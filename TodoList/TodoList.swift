//
//  TodoList.swift
//  TodoList
//
//  Created by Lukas on 05/05/25.
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(),)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let entry = SimpleEntry(date: .now)
        entries.append(entry)

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct TodoListEntryView : View {
    var entry: Provider.Entry
    
    
    @Query(todoDescriptor, animation: .snappy) private var activeList: [Todo]
    var body: some View {
        Text("Aufgaben")
        VStack(alignment: .leading) {
            ForEach(activeList) { todo in
                HStack(spacing: 5) {
                    Button(intent: ToggleButton(id: todo.taskID)) {
                        Image(systemName: "circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(todo.priority.color.gradient)
                    }
                    .buttonStyle(.plain)

                    
                    Text(todo.task)
                        .font(.callout)
                        .lineLimit(1)
                    
                    Spacer(minLength: 0)
                }
                .transition(.push(from: .bottom))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay {
            if activeList.isEmpty {
                Text("Keine To-Dos")
                    .font(.callout)
                    .transition(.push(from: .bottom))
            }
        }

    }
    static var todoDescriptor: FetchDescriptor<Todo> {
        let predicate = #Predicate<Todo> { !$0.isCompleted }
        let sort = [SortDescriptor(\Todo.lastUpdated, order: .reverse)]
        
        var descriptor = FetchDescriptor(predicate: predicate, sortBy: sort)
        descriptor.fetchLimit = 4
        return descriptor
    }
}

struct TodoList: Widget {
    let kind: String = "TodoList"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            TodoListEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
            
                .modelContainer(for: Todo.self)
        }
    }
}




#Preview(as: .systemSmall) {
    TodoList()
} timeline: {
    SimpleEntry(date: .now)
    SimpleEntry(date: .now)
}


struct ToggleButton: AppIntent {
    static var title: LocalizedStringResource = .init(stringLiteral: "Toggle's Todo State")
    
    @Parameter(title: "Todo ID")
    var id: String
    
    init() {
        
    }
    
    init(id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        let context = try ModelContext(.init(for: Todo.self))
        
        let descriptor = FetchDescriptor(predicate: #Predicate<Todo> { $0.taskID == id })
        if let todo = try context.fetch(descriptor).first {
            todo.isCompleted = true
            todo.lastUpdated = .now
            
            try context.save()
        }
        return .result()
        
    }
}
