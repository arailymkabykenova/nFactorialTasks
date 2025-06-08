import Foundation
import SwiftUI

@MainActor
class TaskViewModel: ObservableObject {
    
    @Published var tasks: [Task]
    private var authViewModel: AuthViewModel
    
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        self.tasks = authViewModel.user?.tasks ?? []
    }
    
    
    func addTask(title: String) {
        guard !title.trimmingCharacters(in:.whitespaces).isEmpty else { return }
        
        let newTask = Task(id: UUID(), title: title, isDone: false)
        tasks.append(newTask)
        saveChanges()
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveChanges()
    }
    
    func toggleIsDone(for task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isDone.toggle()
            saveChanges()
        }
    }
    
    private func saveChanges() {
        authViewModel.updateUserTasks(newTasks: tasks)
    }
}
