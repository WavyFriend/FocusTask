import SwiftUI
import SwiftData

struct Home: View {
    @Query(filter: #Predicate<Todo> { !$0.isCompleted }, sort: [SortDescriptor(\Todo.lastUpdated, order: .reverse)], animation: .snappy)
    private var activeList: [Todo]

    @Environment(\.modelContext) private var context
    @State private var showAll: Bool = false
    @State private var showUndo: Bool = false
    @State private var isActive: Bool = false // Fokussteuerung für TextField

    @State private var recentlyDeleted: Todo?

    var body: some View {
        ZStack {
            if activeList.isEmpty && completedListIsEmpty {
                VStack(spacing: 16) {
                    Spacer().frame(height: 70)

                    Image(systemName: "square.on.square")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Keine Aufgaben gefunden")
                        .font(.system(size: 24, weight: .bold)) // Schriftgröße direkt setzen
                        .foregroundColor(.white)
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        
                        let todo = Todo(task: "", priority: .normal)
                        context.insert(todo)
                    }) {
                        Text("Neue Aufgabe erstellen")
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                    }
                            .padding(.top, 8)
                    
                    Spacer()

                }
                .multilineTextAlignment(.center)
                .padding()
            } else {
                List {
                    Section(activeSectionTitle) {
                        ForEach(activeList) { todo in
                            TodoRowView(todo: todo) {
                                deleteWithUndo(todo: todo)
                            }


                        }
                    }

                    CompletedTodoList(showAll: $showAll, onDelete: deleteWithUndo)
                }

            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            
                            let todo = Todo(task: "", priority: .normal)
                            context.insert(todo)
                        }
                    }, label: {
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundColor(.black)
                            .padding()
                            .background(Circle().fill(Color.white))
                    })

                }
            }
            
        }
        // MARK: Undo Snackbar
        if showUndo {
            VStack {
                Spacer()
                HStack {
                    Text("Aufgabe gelöscht")
                    Spacer()
                    Button("Rückgängig") {
                        if let deleted = recentlyDeleted {
                            context.insert(deleted)
                        }
                        showUndo = false
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .padding(.bottom, 15)
        }

    }
    func deleteWithUndo(todo: Todo) {
        recentlyDeleted = todo
        context.delete(todo)
        try? context.save()
        updateWidgetTodos()

        withAnimation {
            showUndo = true
        }

        // Hide Undo after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation {
                showUndo = false
                recentlyDeleted = nil
            }
        }
    }


    private var completedListIsEmpty: Bool {
        let descriptor = FetchDescriptor<Todo>(
            predicate: #Predicate { $0.isCompleted }
        )
        return (try? context.fetchCount(descriptor)) == 0
    }
    
    var activeSectionTitle: String {
        let count = activeList.count
        return count == 0 ? "Active" : "Active (\(count))"
    }
}




#Preview {
    ContentView()
}
