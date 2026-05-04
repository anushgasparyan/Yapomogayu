import SwiftUI

struct HelpTheWorldGame: View {
    @ObservedObject var gameManager: GameManager
    @StateObject private var buildConfig = BuildConfigurationManager.shared
    @State private var currentScene = 0
    @State private var score = 0
    @State private var gameTime = 0
    @State private var isGameActive = false
    @State private var showingGameOver = false
    @State private var completedActions: [GameAction] = []
    @State private var timer: Timer?
    @State private var showingProfile = false
    
    let gameScenes = [
        GameScene(
            id: 0,
            title: "Спасение животных",
            description: "Помогите накормить голодных животных",
            icon: "pawprint.fill",
            color: .orange,
            actions: [
                GameAction(actionType: .feedAnimal, points: 5),
                GameAction(actionType: .rescueAnimal, points: 10)
            ]
        ),
        GameScene(
            id: 1,
            title: "Озеленение",
            description: "Посадите деревья для чистого воздуха",
            icon: "leaf.fill",
            color: .green,
            actions: [
                GameAction(actionType: .plantTree, points: 8),
                GameAction(actionType: .cleanEnvironment, points: 6)
            ]
        ),
        GameScene(
            id: 2,
            title: "Помощь людям",
            description: "Окажите помощь нуждающимся",
            icon: "person.2.fill",
            color: .blue,
            actions: [
                GameAction(actionType: .helpPerson, points: 7),
                GameAction(actionType: .recycle, points: 4)
            ]
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if !isGameActive {
                    gameStartView
                } else {
                    gamePlayView
                }
            }
            .padding(.top, 60) // Top padding for status bar and header
            .padding(.bottom, 200) // Bottom padding for Yandex buttons and navigation
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
        .alert("Игра завершена!", isPresented: $showingGameOver) {
            Button("Играть снова") {
                resetGame()
            }
            Button("Закрыть") {
                endGame()
            }
        } message: {
            Text("Вы набрали \(score) очков и помогли миру! 🌍")
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
    
    // MARK: - Game Start View
    private var gameStartView: some View {
        VStack(spacing: 24) {
            // Game Title
            VStack(spacing: 16) {
                Image(systemName: "globe")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
                
                Text("Помоги миру")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Выполняйте добрые дела и зарабатывайте очки!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            // Game Scenes
            VStack(spacing: 16) {
                ForEach(gameScenes) { scene in
                    GameSceneCard(scene: scene) {
                        startGame(with: scene)
                    }
                }
            }
            
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
            }
            
            // Instructions
            VStack(spacing: 12) {
                Text("Как играть:")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    InstructionRow(icon: "hand.tap.fill", text: "Нажимайте на объекты для помощи")
                    InstructionRow(icon: "star.fill", text: "Зарабатывайте очки за каждое действие")
                    InstructionRow(icon: "clock.fill", text: "У вас есть 60 секунд")
                    InstructionRow(icon: "trophy.fill", text: "Помогите как можно больше!")
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
        .padding()
    }
    
    // MARK: - Game Play View
    private var gamePlayView: some View {
        VStack(spacing: 20) {
            // Game Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Время: \(60 - gameTime)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Очки: \(score)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
                }
                
                Spacer()
                
                Button("Завершить") {
                    endGame()
                }
                .font(.subheadline)
                .foregroundColor(.red)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.2))
                .cornerRadius(8)
            }
            .padding(.horizontal)
            
            // Current Scene
            if currentScene < gameScenes.count {
                let scene = gameScenes[currentScene]
                GameSceneView(scene: scene) { action in
                    performAction(action)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Game Logic
    private func startGame(with scene: GameScene) {
        currentScene = scene.id
        score = 0
        gameTime = 0
        isGameActive = true
        completedActions = []
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            gameTime += 1
            if gameTime >= 60 {
                endGame()
            }
        }
    }
    
    private func performAction(_ action: GameAction) {
        score += action.points
        completedActions.append(action)
        
        // Add points to GameManager
        gameManager.addPoints(action.points)
            print("🎮 Game action completed: \(action.actionType.rawValue) (+\(action.points) points)")
        
        // Show success animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            // Animation handled in GameSceneView
        }
        
        // Move to next scene after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if currentScene < gameScenes.count - 1 {
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentScene += 1
                }
            } else {
                // Cycle back to first scene
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentScene = 0
                }
            }
        }
    }
    
    private func endGame() {
        isGameActive = false
        timer?.invalidate()
        timer = nil
        showingGameOver = true
    }
    
    private func resetGame() {
        currentScene = 0
        score = 0
        gameTime = 0
        isGameActive = false
        completedActions = []
        showingGameOver = false
    }
}

// MARK: - Game Scene Model
struct GameScene: Identifiable {
    let id: Int
    let title: String
    let description: String
    let icon: String
    let color: Color
    let actions: [GameAction]
}

// MARK: - Game Scene Card
struct GameSceneCard: View {
    let scene: GameScene
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(scene.color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: scene.icon)
                        .font(.title2)
                        .foregroundColor(scene.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(scene.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(scene.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Game Scene View
struct GameSceneView: View {
    let scene: GameScene
    let onAction: (GameAction) -> Void
    
    @State private var showingSuccess = false
    @State private var lastAction: GameAction?
    
    var body: some View {
        VStack(spacing: 20) {
            // Scene Header
            VStack(spacing: 12) {
                Image(systemName: scene.icon)
                    .font(.system(size: 40))
                    .foregroundColor(scene.color)
                
                Text(scene.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(scene.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            
            // Action Buttons
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(scene.actions, id: \.id) { action in
                    ActionButton(action: action) {
                        onAction(action)
                        lastAction = action
                        showingSuccess = true
                        
                        // Hide success after delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            showingSuccess = false
                        }
                    }
                }
            }
            
            // Success Animation
            if showingSuccess, let action = lastAction {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                    
                    Text("+\(action.points) очков!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let action: GameAction
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: getActionIcon(action.actionType))
                    .font(.title)
                    .foregroundColor(.white)
                
                Text(action.actionType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("+\(action.points) очков")
                    .font(.caption)
                    .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 255/255, green: 234/255, blue: 0/255).opacity(0.8),
                        Color(red: 255/255, green: 234/255, blue: 0/255).opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color(red: 255/255, green: 234/255, blue: 0/255).opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: action.id)
    }
    
    private func getActionIcon(_ actionType: GameActionType) -> String {
        switch actionType {
        case .feedAnimal: return "pawprint.fill"
        case .plantTree: return "leaf.fill"
        case .cleanEnvironment: return "trash.fill"
        case .rescueAnimal: return "heart.fill"
        case .helpPerson: return "person.2.fill"
        case .recycle: return "arrow.3.trianglepath"
        }
    }
}

// MARK: - Instruction Row
struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

#Preview {
    HelpTheWorldGame(gameManager: GameManager())
}
