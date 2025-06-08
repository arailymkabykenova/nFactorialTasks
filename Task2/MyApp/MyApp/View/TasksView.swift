import SwiftUI

struct TasksView: View {
    @StateObject private var viewModel: TaskViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showingAddTaskAlert = false
    @State private var newTaskTitle = ""
    
    init(authViewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: TaskViewModel(authViewModel: authViewModel))
    }
    
    var body: some View {
        
        List {
            ForEach(viewModel.tasks) { task in
                HStack {
                    Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                        .onTapGesture {
                            viewModel.toggleIsDone(for: task)
                        }
                    Text(task.title)
                        .strikethrough(task.isDone)
                }
            }
            .onDelete(perform: viewModel.deleteTask)
        }
        .navigationTitle("My To-Do List")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Log Out") { authViewModel.logOut()}
                    .foregroundColor(Color.second)
                    .cornerRadius(4)
                    .padding()
                
                
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddTaskAlert = true }) {
                    Image(systemName: "plus")
                }
                .foregroundColor(Color.second)
                .cornerRadius(4)
                .frame(alignment:.leading)
                
            }
        }
        .sheet(isPresented: $showingAddTaskAlert) {
            ZStack{
                Image("task")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .cornerRadius(16)
                    .padding(.top,30)
                    .frame(alignment:.center)
                    .clipped()
                
                VStack(spacing: 20) {
                    Text("New To-Do")
                        .font(.headline)
                        .padding(.bottom,440)
                        .foregroundColor(Color.white)
                    
                    TextField("Task title", text: $newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                        .cornerRadius(8)
                        .padding()
                        .foregroundColor(Color.second)
                    
                    HStack {
                        Button("Cancel") {
                            newTaskTitle = ""
                            showingAddTaskAlert = false
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                        
                        Button("Add") {
                            viewModel.addTask(title: newTaskTitle)
                            newTaskTitle = ""
                            showingAddTaskAlert = false
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.second)
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
            
            
            
            
        }
        .cornerRadius(20)
    }
}
#Preview {
    NavigationStack {
        TasksView(authViewModel:AuthViewModel())
            .environmentObject(AuthViewModel())
    }
}
