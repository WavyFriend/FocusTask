import SwiftUI
import SwiftData
import WidgetKit




struct TodoRowView: View {
    @Bindable var todo: Todo
    @State private var localTodo: Todo
    @FocusState private var isActive: Bool
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var phase

    var onDelete: (() -> Void)? = nil

    init(todo: Todo, onDelete: (() -> Void)? = nil) {
        _todo = Bindable(todo)
        _localTodo = State(initialValue: todo)
        self.onDelete = onDelete
    }

    var body: some View {
        HStack(spacing: 8) {
            if !isActive && !localTodo.task.isEmpty {
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    
                    todo.isCompleted.toggle()
                    localTodo.lastUpdated = .now
                    WidgetCenter.shared.reloadAllTimelines()
                    try? context.save()
                    updateWidgetTodos()
                }) {
                    Image(systemName: localTodo.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .padding(3)
                        .contentShape(.rect)
                        .foregroundStyle(localTodo.isCompleted ? .gray : .accentColor)
                        .contentTransition(.symbolEffect(.replace))
                }
            }

            TextField("Aufgabentitel", text: $localTodo.task)
                .padding()
                .strikethrough(localTodo.isCompleted)
                .foregroundStyle(localTodo.isCompleted ? .gray : .primary)
                .focused($isActive)
            


            if !isActive && !localTodo.task.isEmpty {
                Menu {
                    ForEach(Priority.allCases, id: \.rawValue) { priority in
                        Button(action: {
                            localTodo.priority = priority
                            try? context.save()
                            updateWidgetTodos()
                        }) {
                            HStack {
                                Text(priority.rawValue)
                                if localTodo.priority == priority {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "circle.fill")
                        .font(.title2)
                        .padding(3)
                        .contentShape(.rect)
                        .foregroundStyle(localTodo.priority.color.gradient)
                }
            }
        }
        .listRowInsets(.init(top: 5, leading: 5, bottom: 5, trailing: 5))
        .animation(.snappy, value: isActive)
        .onAppear {
            if todo.task.isEmpty {
                isActive = true
            }
        }

        .onDisappear {
            if localTodo.task.isEmpty {
                context.delete(todo)
                try? context.save()
                updateWidgetTodos()
            }
        }
        .onSubmit(of: .text) {
            if localTodo.task.isEmpty {
                context.delete(todo)
                WidgetCenter.shared.reloadAllTimelines()
                try? context.save()
                updateWidgetTodos()
            } else {
                updateWidgetTodos()
            }
        }
        .onChange(of: phase) { _, newValue in
            if newValue != .active && todo.task.isEmpty {
                WidgetCenter.shared.reloadAllTimelines()
                context.delete(todo)
                try? context.save()
                updateWidgetTodos()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }

        .task {
            todo.isCompleted = todo.isCompleted
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete?()
            } label: {
                Label("Löschen", systemImage: "trash")
            }
        }
    }
}

func updateWidgetTodos() {
    guard let container = try? ModelContainer(for: Todo.self) else { return }
    let context = ModelContext(container)

    let fetchDescriptor = FetchDescriptor<Todo>(predicate: #Predicate { !$0.isCompleted })
    let todos = (try? context.fetch(fetchDescriptor)) ?? []
    let tasks = todos.map { $0.task }

    let defaults = UserDefaults(suiteName: "group.com.luki.FocusTasks")
    defaults?.set(tasks, forKey: "todos")

    WidgetCenter.shared.reloadAllTimelines()
}

#Preview {
    ContentView()
}
