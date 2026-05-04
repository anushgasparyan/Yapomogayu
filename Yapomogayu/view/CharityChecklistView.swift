import SwiftUI

struct CharityChecklistView: View {
    @ObservedObject var gameManager: GameManager
    @StateObject private var buildConfig = BuildConfigurationManager.shared
    @State private var completedTasks: Set<String> = []
    @State private var showingCompletionAlert = false
    @State private var lastCompletedTask: CharityTask? = nil
    @State private var showingProfile = false
    
    let charityTasks = [
        CharityTask(
            id: "donate_clothes",
            title: "Пожертвовать одежду",
            description: "Отдайте ненужную одежду в благотворительные организации",
            points: 20,
            icon: "tshirt.fill",
            color: "blue",
            category: "Помощь нуждающимся"
        ),
        CharityTask(
            id: "volunteer_food",
            title: "Волонтерство в столовой",
            description: "Помогите раздавать еду бездомным или нуждающимся",
            points: 50,
            icon: "fork.knife",
            color: "orange",
            category: "Помощь нуждающимся"
        ),
        CharityTask(
            id: "plant_tree",
            title: "Посадить дерево",
            description: "Посадите дерево для улучшения экологии",
            points: 30,
            icon: "leaf.fill",
            color: "green",
            category: "Экология"
        ),
        CharityTask(
            id: "help_elderly",
            title: "Помочь пожилому человеку",
            description: "Помогите пожилому человеку с покупками или домашними делами",
            points: 40,
            icon: "figure.walk",
            color: "purple",
            category: "Помощь пожилым"
        ),
        CharityTask(
            id: "donate_blood",
            title: "Сдать кровь",
            description: "Сдайте кровь в медицинском центре",
            points: 100,
            icon: "heart.fill",
            color: "red",
            category: "Медицина"
        ),
        CharityTask(
            id: "clean_park",
            title: "Убрать парк",
            description: "Помогите убрать мусор в парке или на улице",
            points: 25,
            icon: "trash.fill",
            color: "brown",
            category: "Экология"
        ),
        CharityTask(
            id: "teach_skills",
            title: "Обучить навыкам",
            description: "Поделитесь своими навыками с теми, кто в них нуждается",
            points: 60,
            icon: "book.fill",
            color: "indigo",
            category: "Образование"
        ),
        CharityTask(
            id: "help_animal",
            title: "Помочь животному",
            description: "Помогите бездомному животному или в приюте",
            points: 35,
            icon: "pawprint.fill",
            color: "pink",
            category: "Животные"
        ),
        CharityTask(
            id: "donate_money",
            title: "Денежное пожертвование",
            description: "Сделайте денежное пожертвование в благотворительный фонд",
            points: 80,
            icon: "dollarsign.circle.fill",
            color: "yellow",
            category: "Финансовая помощь"
        ),
        CharityTask(
            id: "organize_event",
            title: "Организовать мероприятие",
            description: "Организуйте благотворительное мероприятие",
            points: 120,
            icon: "calendar.badge.plus",
            color: "cyan",
            category: "Организация"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "checklist")
                        .font(.system(size: 60))
                        .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
                    
                    Text("Чек-лист добрых дел")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Выполняйте добрые дела в реальной жизни и получайте очки!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Progress
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(completedTasks.count)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
                            Text("Выполнено")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text("\(charityTasks.count)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Всего")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text("\(completedTasks.count * 100 / charityTasks.count)%")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Прогресс")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                }
                .padding(.top, 20)
                
                // Login Message
                if !gameManager.isLoggedIn {
                    Button(action: {
                        showingProfile = true
                    }) {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
                                
                                Text("Войдите в аккаунт")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Text("Чтобы сохранить прогресс, заработать очки и получить достижения, войдите в аккаунт в разделе 'Профиль'")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .background(Color(red: 255/255, green: 234/255, blue: 0/255).opacity(0.1))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 255/255, green: 234/255, blue: 0/255).opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                }
                
                // Tasks by Category
                LazyVStack(spacing: 20) {
                    ForEach(groupedTasks.keys.sorted(), id: \.self) { category in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            ForEach(groupedTasks[category] ?? []) { task in
                                TaskCardView(
                                    task: task,
                                    isCompleted: completedTasks.contains(task.id),
                                    onToggle: {
                                        toggleTask(task)
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 220) // Bottom padding for Yandex buttons and tab bar
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
        .alert("Отлично! 🎉", isPresented: $showingCompletionAlert) {
            Button("OK") { }
        } message: {
            if let task = lastCompletedTask {
                Text("Вы выполнили: \(task.title)\nПолучено очков: \(task.points)")
            }
        }
        .onAppear {
            loadCompletedTasks()
        }
        .sheet(isPresented: $showingProfile) {
            if gameManager.isLoggedIn {
                if buildConfig.simplifiedProfileInRelease {
                    SimpleProfileView(gameManager: gameManager)
                } else {
                    EnhancedProfileView(gameManager: gameManager)
                }
            } else {
                LoginPageView(gameManager: gameManager)
            }
        }
    }
    
    private var groupedTasks: [String: [CharityTask]] {
        Dictionary(grouping: charityTasks) { $0.category }
    }
    
    private func toggleTask(_ task: CharityTask) {
        if completedTasks.contains(task.id) {
            // Uncomplete task
            completedTasks.remove(task.id)
            gameManager.removePoints(task.points)
            print("❌ Task uncompleted: \(task.title)")
        } else {
            // Complete task
            completedTasks.insert(task.id)
            gameManager.addPoints(task.points)
            lastCompletedTask = task
            showingCompletionAlert = true
            print("✅ Task completed: \(task.title) (+\(task.points) points)")
        }
        saveCompletedTasks()
    }
    
    private func loadCompletedTasks() {
        if let data = UserDefaults.standard.data(forKey: "completedCharityTasks"),
           let tasks = try? JSONDecoder().decode(Set<String>.self, from: data) {
            completedTasks = tasks
        }
    }
    
    private func saveCompletedTasks() {
        if let data = try? JSONEncoder().encode(completedTasks) {
            UserDefaults.standard.set(data, forKey: "completedCharityTasks")
        }
    }
}

struct CharityTask: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let points: Int
    let icon: String
    let color: String
    let category: String
}

struct TaskCardView: View {
    let task: CharityTask
    let isCompleted: Bool
    let onToggle: () -> Void
    
    private func colorFromString(_ colorString: String) -> Color {
        switch colorString {
        case "blue": return .blue
        case "orange": return .orange
        case "green": return .green
        case "purple": return .purple
        case "red": return .red
        case "brown": return .brown
        case "indigo": return .indigo
        case "pink": return .pink
        case "yellow": return .yellow
        case "cyan": return .cyan
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(colorFromString(task.color).opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: task.icon)
                    .font(.title2)
                    .foregroundColor(colorFromString(task.color))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .strikethrough(isCompleted)
                    .opacity(isCompleted ? 0.6 : 1.0)
                
                Text(task.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text("+\(task.points) очков")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
                    
                    Spacer()
                    
                    Text(task.category)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isCompleted ? .green : .gray)
            }
        }
        .padding()
        .background(
            isCompleted ? 
            Color.green.opacity(0.1) : 
            Color.gray.opacity(0.1)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isCompleted ? 
                    Color.green.opacity(0.3) : 
                    Color.clear, 
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    CharityChecklistView(gameManager: GameManager())
}
