import SwiftUI
import AuthenticationServices

struct EnhancedProfileView: View {
    @ObservedObject var gameManager: GameManager
    @StateObject private var buildConfig = BuildConfigurationManager.shared
    @State private var showingLogin = false
    @State private var showingBadges = false
    @State private var showingLeaderboard = false
    @State private var showingVolunteerForm = false
    @State private var showingDeleteConfirmation = false
    
    // Demo user data
    private let demoUser: UserProfile = {
        var user = UserProfile(name: "Демо Пользователь", email: "demo@yapomogayu.ru")
        user.kindnessPoints = 45
        user.level = 1
        user.watchedVideos = [1, 2, 3, 4, 5]
        user.likedVideos = [1, 2, 3]
        user.sharedVideos = [1, 2]
        user.completedActions = ["Watched video", "Liked video", "Shared video"]
        return user
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Text("Профиль")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // User Info Card
                VStack(spacing: 12) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(Color(red: 255/255, green: 234/255, blue: 0/255))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "person.fill")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                    
                    // User Details
                    VStack(spacing: 4) {
                        Text(gameManager.userName.isEmpty ? "Пользователь" : gameManager.userName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(gameManager.userEmail.isEmpty ? "user@yapomogayu.ru" : gameManager.userEmail)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Points and Level - only show in debug builds
                    if buildConfig.isDebugBuild {
                        HStack(spacing: 30) {
                            VStack(spacing: 4) {
                                Text("\(gameManager.totalPoints)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
                                Text("Очки")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(spacing: 4) {
                                Text("\(gameManager.currentLevel)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("Уровень")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(spacing: 4) {
                                Text("\(gameManager.videosLiked)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text("Лайки")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        // Simple stats for release builds
                        HStack(spacing: 30) {
                            VStack(spacing: 4) {
                                Text("\(gameManager.videosWatched)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Text("Видео")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(spacing: 4) {
                                Text("\(gameManager.videosLiked)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                Text("Лайки")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(spacing: 4) {
                                Text("\(gameManager.sharesCount)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                Text("Поделился")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            // Content
            ScrollView {
                VStack(spacing: 20) {
                    // Stats Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Моя активность")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 20)
                        
                        HStack(spacing: 20) {
                            StatCard(title: "Видео", value: "\(gameManager.videosWatched)", icon: "play.circle.fill", color: .blue)
                            StatCard(title: "Лайки", value: "\(gameManager.videosLiked)", icon: "hand.thumbsup.fill", color: .red)
                            StatCard(title: "Поделился", value: "\(gameManager.sharesCount)", icon: "square.and.arrow.up.fill", color: .orange)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Actions Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Действия")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            // Logout Button
                            ActionButton(
                                title: "Выйти",
                                icon: "arrow.right.square",
                                color: .red
                            ) {
                                print("🔴 Logout button clicked in EnhancedProfileView")
                                gameManager.logout()
                            }
                            
                            // Delete Account Button
                            ActionButton(
                                title: "Удалить аккаунт",
                                icon: "trash.fill",
                                color: .red
                            ) {
                                print("🗑️ Delete account button clicked")
                                showingDeleteConfirmation = true
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Achievements Section - only show in debug builds
                    if buildConfig.isDebugBuild {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Достижения")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                                
                                Text("\(gameManager.allAchievements.filter { $0.isUnlocked }.count)/\(gameManager.allAchievements.count)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(gameManager.allAchievements) { achievement in
                                        AchievementCard(achievement: achievement)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.bottom, 220) // Bottom padding for Yandex buttons and tab bar
            }
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
        .alert("Удалить аккаунт", isPresented: $showingDeleteConfirmation) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                gameManager.deleteAccount()
            }
        } message: {
            Text("Вы уверены, что хотите удалить свой аккаунт? Это действие нельзя отменить. Все ваши данные будут безвозвратно удалены.")
        }
        // .sheet(isPresented: $showingBadges) {
        //     BadgesView()
        // }
        // .sheet(isPresented: $showingLeaderboard) {
        //     LeaderboardView()
        // }
        // .sheet(isPresented: $showingVolunteerForm) {
        //     VolunteerFormView()
        // }
    }
    
    // MARK: - Supporting Views
    struct StatCard: View {
        let title: String
        let value: String
        let icon: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    struct ActionButton: View {
        let title: String
        let icon: String
        let color: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    struct AchievementCard: View {
        let achievement: Achievement
        
        var body: some View {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(achievement.isUnlocked ? Color(red: 255/255, green: 234/255, blue: 0/255).opacity(0.3) : Color.gray.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: achievement.icon)
                        .font(.title3)
                        .foregroundColor(achievement.isUnlocked ? Color(red: 255/255, green: 234/255, blue: 0/255) : .gray)
                    
                    // Lock icon for locked achievements
                    if !achievement.isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .offset(x: 15, y: 15)
                    }
                }
                
                Text(achievement.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(width: 80)
        }
    }
    
    struct BadgeCard: View {
        let name: String
        let icon: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(width: 80)
        }
    }
}

#Preview {
    EnhancedProfileView(gameManager: GameManager())
}
