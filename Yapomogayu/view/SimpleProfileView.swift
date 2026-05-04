import SwiftUI
import AuthenticationServices

/// Simplified profile view for release builds - minimal functionality
/// This ensures App Store compliance while keeping full features in debug builds
struct SimpleProfileView: View {
    @ObservedObject var gameManager: GameManager
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Text("Профиль")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // User Info Card - Simplified
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
                    
                    // Simple Stats (no points/levels in release)
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
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            // Content - Simplified
            ScrollView {
                VStack(spacing: 20) {
                    // Basic Actions Section
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
                                print("🔴 Logout button clicked in SimpleProfileView")
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
                    
                    // App Info Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("О приложении")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            InfoCard(
                                title: "Я ПОМОГАЮ",
                                description: "Приложение для просмотра благотворительных видео и поддержки добрых дел",
                                icon: "heart.fill",
                                color: Color(red: 255/255, green: 234/255, blue: 0/255)
                            )
                            
                            InfoCard(
                                title: "Версия",
                                description: "1.1 - Базовая версия",
                                icon: "info.circle.fill",
                                color: .blue
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 220) // Bottom padding for tab bar
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
    }
    
    // MARK: - Supporting Views
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
    
    struct InfoCard: View {
        let title: String
        let description: String
        let icon: String
        let color: Color
        
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    SimpleProfileView(gameManager: GameManager())
}
