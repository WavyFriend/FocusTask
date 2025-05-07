//
//  CompletedTodoList.swift
//  FocusTask
//
//  Created by Lukas on 05/05/25.
//

import SwiftUI
import SwiftData

struct CompletedTodoList: View {
    @Binding var showAll: Bool
    var onDelete: (Todo) -> Void


    @Query private var completedList: [Todo]

    init(showAll: Binding<Bool>, onDelete: @escaping (Todo) -> Void = { _ in }) {
        self._showAll = showAll
        self.onDelete = onDelete
        
        let predicate = #Predicate<Todo> { $0.isCompleted }
        let sort = [SortDescriptor(\Todo.lastUpdated, order: .reverse)]
        
        var descriptor = FetchDescriptor(predicate: predicate, sortBy: sort)
        if !showAll.wrappedValue {
            descriptor.fetchLimit = 3
        }
        
        _completedList = Query(descriptor, animation: .snappy)
    }

    var body: some View {
        Section {
            ForEach(completedList) { todo in
                TodoRowView(todo: todo) {
                    onDelete(todo) 
                }
            }
        } header: {
            HStack {
                Text("Completed")
                Spacer(minLength: 0)
                if showAll && !completedList.isEmpty {
                    Button("Show Recents") {
                        showAll = false
                    }
                }
            }
            .font(.caption)
        } footer: {
            if completedList.count == 3 && !showAll && !completedList.isEmpty {
                HStack {
                    Text("Showing Recent 3 Tasks")
                        .foregroundStyle(.gray)
                    Spacer(minLength: 0)
                    Button("Show All") {
                        showAll = true
                    }
                }
                .font(.caption)
            }
        }
    }
}

#Preview {
    ContentView()
}
