import Foundation
import SwiftUI

class GameManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var totalPoints: Int = 0
    @Published var currentLevel: Int = 1
    @Published var currentLevelPoints: Int = 0
    @Published var pointsForNextLevel: Int = 100
    @Published var quizzesCompleted: Int = 0
    @Published var videosWatched: Int = 0
    @Published var videosLiked: Int = 0
    @Published var sharesCount: Int = 0
    @Published var recentAchievements: [Achievement] = []
    @Published var allAchievements: [Achievement] = []
    
    private let buildConfig = BuildConfigurationManager.shared
    
    init() {
        // Simple initialization
        loadGameData()
        setupAchievements()
    }
    
    private func loadGameData() {
        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        totalPoints = UserDefaults.standard.integer(forKey: "totalPoints")
        currentLevel = UserDefaults.standard.integer(forKey: "currentLevel")
        if currentLevel == 0 { currentLevel = 1 }
        currentLevelPoints = UserDefaults.standard.integer(forKey: "currentLevelPoints")
        quizzesCompleted = UserDefaults.standard.integer(forKey: "quizzesCompleted")
        videosWatched = UserDefaults.standard.integer(forKey: "videosWatched")
        videosLiked = UserDefaults.standard.integer(forKey: "videosLiked")
        sharesCount = UserDefaults.standard.integer(forKey: "sharesCount")
        
        // Load achievements
        if let achievementsData = UserDefaults.standard.data(forKey: "recentAchievements"),
           let achievements = try? JSONDecoder().decode([Achievement].self, from: achievementsData) {
            recentAchievements = achievements
        }
        
        // Load all achievements with their unlock status
        if let allAchievementsData = UserDefaults.standard.data(forKey: "allAchievements"),
           let savedAchievements = try? JSONDecoder().decode([Achievement].self, from: allAchievementsData) {
            allAchievements = savedAchievements
        }
        
        updateLevel()
    }
    
    private func saveGameData() {
        UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(userEmail, forKey: "userEmail")
        UserDefaults.standard.set(totalPoints, forKey: "totalPoints")
        UserDefaults.standard.set(currentLevel, forKey: "currentLevel")
        UserDefaults.standard.set(currentLevelPoints, forKey: "currentLevelPoints")
        UserDefaults.standard.set(quizzesCompleted, forKey: "quizzesCompleted")
        UserDefaults.standard.set(videosWatched, forKey: "videosWatched")
        UserDefaults.standard.set(videosLiked, forKey: "videosLiked")
        UserDefaults.standard.set(sharesCount, forKey: "sharesCount")
        
        // Save achievements
        if let achievementsData = try? JSONEncoder().encode(recentAchievements) {
            UserDefaults.standard.set(achievementsData, forKey: "recentAchievements")
        }
        
        // Save all achievements with their unlock status
        if let allAchievementsData = try? JSONEncoder().encode(allAchievements) {
            UserDefaults.standard.set(allAchievementsData, forKey: "allAchievements")
        }
    }
    
    private func setupAchievements() {
        // Only create achievements if they don't exist in storage
        if allAchievements.isEmpty {
            allAchievements = [
            // Video Achievements
            Achievement(
                id: "first_video",
                title: "Первый шаг",
                description: "Посмотрите первое видео",
                icon: "play.circle.fill",
                pointsRequired: 0,
                isUnlocked: videosWatched >= 1
            ),
            Achievement(
                id: "video_watcher",
                title: "Наблюдатель",
                description: "Посмотрите 5 видео",
                icon: "play.circle.fill",
                pointsRequired: 30,
                isUnlocked: videosWatched >= 5
            ),
            Achievement(
                id: "video_binger",
                title: "Киноман",
                description: "Посмотрите 20 видео",
                icon: "play.rectangle.fill",
                pointsRequired: 100,
                isUnlocked: videosWatched >= 20
            ),
            Achievement(
                id: "video_master",
                title: "Мастер просмотра",
                description: "Посмотрите 50 видео",
                icon: "play.tv.fill",
                pointsRequired: 250,
                isUnlocked: videosWatched >= 50
            ),
            
            // Like Achievements
            Achievement(
                id: "first_like",
                title: "Первый лайк",
                description: "Поставьте первый лайк",
                icon: "heart.fill",
                pointsRequired: 0,
                isUnlocked: videosLiked >= 1
            ),
            Achievement(
                id: "liker",
                title: "Лайкер",
                description: "Поставьте 10 лайков",
                icon: "heart.circle.fill",
                pointsRequired: 30,
                isUnlocked: videosLiked >= 10
            ),
            Achievement(
                id: "heart_master",
                title: "Мастер сердец",
                description: "Поставьте 50 лайков",
                icon: "heart.rectangle.fill",
                pointsRequired: 150,
                isUnlocked: videosLiked >= 50
            ),
            
            // Share Achievements
            Achievement(
                id: "first_share",
                title: "Первый шаринг",
                description: "Поделитесь первым видео",
                icon: "square.and.arrow.up.fill",
                pointsRequired: 0,
                isUnlocked: sharesCount >= 1
            ),
            Achievement(
                id: "sharer",
                title: "Распространитель",
                description: "Поделитесь 5 видео",
                icon: "square.and.arrow.up.circle.fill",
                pointsRequired: 75,
                isUnlocked: sharesCount >= 5
            ),
            Achievement(
                id: "viral_master",
                title: "Вирусный мастер",
                description: "Поделитесь 20 видео",
                icon: "megaphone.fill",
                pointsRequired: 300,
                isUnlocked: sharesCount >= 20
            ),
            
            // Quiz Achievements
            Achievement(
                id: "first_quiz",
                title: "Первая викторина",
                description: "Пройдите свою первую викторину",
                icon: "questionmark.circle.fill",
                pointsRequired: 0,
                isUnlocked: quizzesCompleted >= 1
            ),
            Achievement(
                id: "quiz_master",
                title: "Мастер викторин",
                description: "Пройдите 5 викторин",
                icon: "brain.head.profile",
                pointsRequired: 50,
                isUnlocked: quizzesCompleted >= 5
            ),
            Achievement(
                id: "quiz_expert",
                title: "Эксперт викторин",
                description: "Пройдите 15 викторин",
                icon: "brain.filled.head.profile",
                pointsRequired: 200,
                isUnlocked: quizzesCompleted >= 15
            ),
            
            // Points Achievements
            Achievement(
                id: "points_starter",
                title: "Начинающий",
                description: "Заработайте 50 очков",
                icon: "star.fill",
                pointsRequired: 50,
                isUnlocked: totalPoints >= 50
            ),
            Achievement(
                id: "points_collector",
                title: "Коллекционер очков",
                description: "Заработайте 200 очков",
                icon: "star.circle.fill",
                pointsRequired: 200,
                isUnlocked: totalPoints >= 200
            ),
            Achievement(
                id: "points_master",
                title: "Мастер очков",
                description: "Заработайте 500 очков",
                icon: "star.rectangle.fill",
                pointsRequired: 500,
                isUnlocked: totalPoints >= 500
            ),
            Achievement(
                id: "charity_expert",
                title: "Эксперт благотворительности",
                description: "Заработайте 1000 очков",
                icon: "heart.fill",
                pointsRequired: 1000,
                isUnlocked: totalPoints >= 1000
            ),
            Achievement(
                id: "charity_legend",
                title: "Легенда благотворительности",
                description: "Заработайте 2000 очков",
                icon: "crown.fill",
                pointsRequired: 2000,
                isUnlocked: totalPoints >= 2000
            ),
            
            // Level Achievements
            Achievement(
                id: "level_up",
                title: "Повышение уровня",
                description: "Достигните 5 уровня",
                icon: "arrow.up.circle.fill",
                pointsRequired: 400,
                isUnlocked: currentLevel >= 5
            ),
            Achievement(
                id: "high_level",
                title: "Высокий уровень",
                description: "Достигните 10 уровня",
                icon: "arrow.up.square.fill",
                pointsRequired: 900,
                isUnlocked: currentLevel >= 10
            ),
            
            // Special Achievements
            Achievement(
                id: "daily_user",
                title: "Ежедневный пользователь",
                description: "Используйте приложение 7 дней подряд",
                icon: "calendar.badge.checkmark",
                pointsRequired: 100,
                isUnlocked: false // This would need daily tracking
            ),
            Achievement(
                id: "helper",
                title: "Помощник",
                description: "Выполните 5 реальных добрых дел",
                icon: "hand.raised.fill",
                pointsRequired: 150,
                isUnlocked: false // This would track checklist completions
            )
        ]
        }
        
        // Update achievement status based on current progress
        updateAchievementStatus()
        updateRecentAchievements()
    }
    
    private func updateAchievementStatus() {
        // Update all achievement unlock status based on current progress
        for i in 0..<allAchievements.count {
            switch allAchievements[i].id {
            // Video Achievements
            case "first_video":
                allAchievements[i].isUnlocked = videosWatched >= 1
            case "video_watcher":
                allAchievements[i].isUnlocked = videosWatched >= 5
            case "video_binger":
                allAchievements[i].isUnlocked = videosWatched >= 20
            case "video_master":
                allAchievements[i].isUnlocked = videosWatched >= 50
                
            // Like Achievements
            case "first_like":
                allAchievements[i].isUnlocked = videosLiked >= 1
            case "liker":
                allAchievements[i].isUnlocked = videosLiked >= 10
            case "heart_master":
                allAchievements[i].isUnlocked = videosLiked >= 50
                
            // Share Achievements
            case "first_share":
                allAchievements[i].isUnlocked = sharesCount >= 1
            case "sharer":
                allAchievements[i].isUnlocked = sharesCount >= 5
            case "viral_master":
                allAchievements[i].isUnlocked = sharesCount >= 20
                
            // Quiz Achievements
            case "first_quiz":
                allAchievements[i].isUnlocked = quizzesCompleted >= 1
            case "quiz_master":
                allAchievements[i].isUnlocked = quizzesCompleted >= 5
            case "quiz_expert":
                allAchievements[i].isUnlocked = quizzesCompleted >= 15
                
            // Points Achievements
            case "points_starter":
                allAchievements[i].isUnlocked = totalPoints >= 50
            case "points_collector":
                allAchievements[i].isUnlocked = totalPoints >= 200
            case "points_master":
                allAchievements[i].isUnlocked = totalPoints >= 500
            case "charity_expert":
                allAchievements[i].isUnlocked = totalPoints >= 1000
            case "charity_legend":
                allAchievements[i].isUnlocked = totalPoints >= 2000
                
            // Level Achievements
            case "level_up":
                allAchievements[i].isUnlocked = currentLevel >= 5
            case "high_level":
                allAchievements[i].isUnlocked = currentLevel >= 10
                
            // Special Achievements (these would need additional tracking)
            case "daily_user":
                // This would need daily usage tracking
                allAchievements[i].isUnlocked = false
            case "helper":
                // This would need checklist completion tracking
                allAchievements[i].isUnlocked = false
                
            default:
                break
            }
        }
    }
    
    private func updateRecentAchievements() {
        recentAchievements = allAchievements.filter { $0.isUnlocked }.suffix(3).reversed()
    }
    
    private func updateLevel() {
        let newLevel = (totalPoints / 100) + 1
        if newLevel != currentLevel {
            currentLevel = newLevel
            currentLevelPoints = totalPoints % 100
            pointsForNextLevel = 100
        } else {
            currentLevelPoints = totalPoints % 100
        }
    }
    
    func addPoints(_ points: Int) {
        guard isLoggedIn else {
            print("⚠️ Cannot add points - user not logged in")
            return
        }
        totalPoints += points
        updateLevel()
        saveGameData()
        checkAchievements()
    }
    
    func removePoints(_ points: Int) {
        guard isLoggedIn else {
            print("⚠️ Cannot remove points - user not logged in")
            return
        }
        totalPoints = max(0, totalPoints - points)
        updateLevel()
        saveGameData()
        print("📉 Points removed: \(points), Total: \(totalPoints)")
    }
    
    func completeQuiz(score: Int = 0) {
        guard isLoggedIn else {
            print("⚠️ Cannot complete quiz - user not logged in")
            return
        }
        quizzesCompleted += 1
        addPoints(score)
        saveGameData()
        checkAchievements()
    }
    
    func watchVideo() {
        guard isLoggedIn else {
            print("⚠️ Cannot watch video - user not logged in")
            return
        }
        videosWatched += 1
        
        // Only award points in debug builds
        if buildConfig.enablePointsSystem {
            addPoints(5)
            checkAchievements()
        }
        
        saveGameData()
        print("📹 Video watched! Total: \(videosWatched)")
    }
    
    func shareApp() {
        guard isLoggedIn else {
            print("⚠️ Cannot share app - user not logged in")
            return
        }
        sharesCount += 1
        
        // Only award points in debug builds
        if buildConfig.enablePointsSystem {
            addPoints(15)
            checkAchievements()
        }
        
        saveGameData()
        print("📤 App shared! Total shares: \(sharesCount)")
    }
    
    func login() {
        isLoggedIn = true
        saveGameData()
    }
    
    func loginWithEmail(email: String, name: String) {
        print("🔐 Logging in with email: \(email)")
        isLoggedIn = true
        userEmail = email
        userName = name
        saveGameData()
        print("✅ Login successful - User: \(name), Email: \(email)")
    }
    
    func loginWithApple(email: String, name: String) {
        print("🍎 Logging in with Apple: \(name)")
        isLoggedIn = true
        userEmail = email
        userName = name
        saveGameData()
        print("✅ Apple login successful - User: \(name), Email: \(email)")
    }
    
    func logout() {
        print("🚪 Starting logout process...")
        print("🔍 Before logout - isLoggedIn: \(isLoggedIn)")
        print("🔍 Before logout - totalPoints: \(totalPoints), videosLiked: \(videosLiked)")
        
        isLoggedIn = false
        userEmail = ""
        userName = ""
        totalPoints = 0
        currentLevel = 1
        currentLevelPoints = 0
        quizzesCompleted = 0
        videosWatched = 0
        videosLiked = 0
        sharesCount = 0
        recentAchievements = []
        
        // Clear all UserDefaults data
        clearAllUserData()
        
        print("🔍 After logout - isLoggedIn: \(isLoggedIn)")
        print("🔍 After logout - totalPoints: \(totalPoints), videosLiked: \(videosLiked)")
        print("🚪 User logged out successfully - all data cleared")
    }
    
    func deleteAccount() {
        print("🗑️ Starting account deletion process...")
        print("🔍 Before deletion - isLoggedIn: \(isLoggedIn)")
        print("🔍 Before deletion - totalPoints: \(totalPoints), videosLiked: \(videosLiked)")
        
        // Same as logout but with different messaging
        isLoggedIn = false
        userEmail = ""
        userName = ""
        totalPoints = 0
        currentLevel = 1
        currentLevelPoints = 0
        quizzesCompleted = 0
        videosWatched = 0
        videosLiked = 0
        sharesCount = 0
        recentAchievements = []
        
        // Clear all UserDefaults data
        clearAllUserData()
        
        print("🔍 After deletion - isLoggedIn: \(isLoggedIn)")
        print("🔍 After deletion - totalPoints: \(totalPoints), videosLiked: \(videosLiked)")
        print("🗑️ Account deleted successfully - all data permanently removed")
    }
    
    private func clearAllUserData() {
        let keys = [
            "isLoggedIn", "userName", "userEmail", "totalPoints", "currentLevel",
            "currentLevelPoints", "quizzesCompleted", "videosWatched", "videosLiked",
            "sharesCount", "recentAchievements", "allAchievements"
        ]
        
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        UserDefaults.standard.synchronize()
    }
    
    func likeVideo() {
        guard isLoggedIn else {
            print("⚠️ Cannot like video - user not logged in")
            return
        }
        videosLiked += 1
        
        // Only award points in debug builds
        if buildConfig.enablePointsSystem {
            addPoints(3)
            checkAchievements()
        }
        
        saveGameData()
        print("❤️ Video liked! Total likes: \(videosLiked)")
    }
    
    func unlikeVideo() {
        guard isLoggedIn else {
            print("⚠️ Cannot unlike video - user not logged in")
            return
        }
        if videosLiked > 0 {
            videosLiked -= 1
            
            // Only remove points in debug builds
            if buildConfig.enablePointsSystem {
                totalPoints = max(0, totalPoints - 3) // Remove points but don't go below 0
            }
            
            saveGameData()
            print("💔 Video unliked! Total likes: \(videosLiked)")
        }
    }
    
    // Trivia Questions - Expanded with more questions
    let allTriviaQuestions: [TriviaQuestion] = [
        TriviaQuestion(
            question: "Сколько детей не имеют доступа к чистой воде?",
            options: ["Около 100 миллионов", "Около 200 миллионов", "Около 400 миллионов", "Около 700 миллионов"],
            correctAnswer: 2,
            explanation: "По данным ЮНИСЕФ, около 400 миллионов детей не имеют доступа к базовым услугам питьевой воды."
        ),
        TriviaQuestion(
            question: "Какой процент населения мира живет в условиях крайней нищеты?",
            options: ["Менее 5%", "Около 10%", "Около 15%", "Более 20%"],
            correctAnswer: 1,
            explanation: "По данным Всемирного банка, около 8-10% мирового населения живет в условиях крайней нищеты."
        ),
        TriviaQuestion(
            question: "Какова основная причина голода в мире?",
            options: ["Изменение климата", "Войны и конфликты", "Экономические кризисы", "Все вышеперечисленное"],
            correctAnswer: 3,
            explanation: "Голод в мире вызван сложным взаимодействием факторов, включая изменение климата, конфликты, экономические потрясения и бедность."
        ),
        TriviaQuestion(
            question: "Сколько людей в мире не имеют доступа к электричеству?",
            options: ["Около 200 миллионов", "Около 500 миллионов", "Около 700 миллионов", "Более 1 миллиарда"],
            correctAnswer: 2,
            explanation: "По данным Международного энергетического агентства, около 700 миллионов человек в мире не имеют доступа к электричеству."
        ),
        TriviaQuestion(
            question: "Какая организация является крупнейшим поставщиком гуманитарной помощи?",
            options: ["Красный Крест", "Врачи без границ", "ООН (через различные агентства)", "Oxfam"],
            correctAnswer: 2,
            explanation: "Организация Объединенных Наций, через свои различные агентства, является крупнейшим поставщиком гуманитарной помощи в мире."
        ),
        TriviaQuestion(
            question: "Сколько детей в мире не ходят в школу?",
            options: ["50 миллионов", "100 миллионов", "150 миллионов", "200 миллионов"],
            correctAnswer: 2,
            explanation: "По данным ЮНЕСКО, около 150 миллионов детей не имеют доступа к образованию."
        ),
        TriviaQuestion(
            question: "Какой процент благотворительных пожертвований идет на административные расходы?",
            options: ["5-10%", "10-15%", "15-20%", "20-25%"],
            correctAnswer: 1,
            explanation: "Хорошие благотворительные организации тратят 10-15% на административные расходы."
        ),
        TriviaQuestion(
            question: "Сколько людей в мире голодают?",
            options: ["500 миллионов", "800 миллионов", "1 миллиард", "1.2 миллиарда"],
            correctAnswer: 1,
            explanation: "По данным ООН, около 800 миллионов человек страдают от голода."
        ),
        TriviaQuestion(
            question: "Какая страна тратит больше всего на благотворительность?",
            options: ["США", "Германия", "Великобритания", "Канада"],
            correctAnswer: 0,
            explanation: "США тратят больше всего на благотворительность - около 2% ВВП."
        ),
        TriviaQuestion(
            question: "Сколько времени в среднем тратят волонтеры на благотворительность?",
            options: ["1-2 часа в неделю", "3-4 часа в неделю", "5-6 часов в неделю", "7+ часов в неделю"],
            correctAnswer: 1,
            explanation: "Средний волонтер тратит около 3-4 часов в неделю на благотворительную деятельность."
        ),
        TriviaQuestion(
            question: "Какой процент людей в мире живут менее чем на $1.90 в день?",
            options: ["5%", "10%", "15%", "20%"],
            correctAnswer: 0,
            explanation: "По данным Всемирного банка, около 5% населения мира живет менее чем на $1.90 в день."
        ),
        TriviaQuestion(
            question: "Какая самая распространенная форма благотворительности?",
            options: ["Денежные пожертвования", "Волонтерство", "Пожертвование вещей", "Кровь и органы"],
            correctAnswer: 0,
            explanation: "Денежные пожертвования являются самой распространенной формой благотворительности."
        ),
        TriviaQuestion(
            question: "Сколько людей в мире являются беженцами?",
            options: ["20 миллионов", "40 миллионов", "60 миллионов", "80 миллионов"],
            correctAnswer: 3,
            explanation: "По данным УВКБ ООН, около 80 миллионов человек в мире являются беженцами или внутренне перемещенными лицами."
        ),
        TriviaQuestion(
            question: "Какой процент детей в развивающихся странах не получают базовое образование?",
            options: ["10%", "20%", "30%", "40%"],
            correctAnswer: 1,
            explanation: "Около 20% детей в развивающихся странах не получают базовое образование."
        ),
        TriviaQuestion(
            question: "Какая организация была основана первой?",
            options: ["Красный Крест", "ЮНИСЕФ", "Врачи без границ", "Oxfam"],
            correctAnswer: 0,
            explanation: "Красный Крест был основан в 1863 году, что делает его одной из старейших международных гуманитарных организаций."
        )
    ]
    
    // Get randomized questions for a quiz
    func getRandomQuestions(count: Int = 5) -> [TriviaQuestion] {
        return Array(allTriviaQuestions.shuffled().prefix(count))
    }
    
    private func checkAchievements() {
        var hasNewAchievement = false
        
        for i in 0..<allAchievements.count {
            let achievement = allAchievements[i]
            let wasUnlocked = achievement.isUnlocked
            
            // Update achievement status
            switch achievement.id {
            // Video Achievements
            case "first_video":
                allAchievements[i].isUnlocked = videosWatched >= 1
            case "video_watcher":
                allAchievements[i].isUnlocked = videosWatched >= 5
            case "video_binger":
                allAchievements[i].isUnlocked = videosWatched >= 20
            case "video_master":
                allAchievements[i].isUnlocked = videosWatched >= 50
                
            // Like Achievements
            case "first_like":
                allAchievements[i].isUnlocked = videosLiked >= 1
            case "liker":
                allAchievements[i].isUnlocked = videosLiked >= 10
            case "heart_master":
                allAchievements[i].isUnlocked = videosLiked >= 50
                
            // Share Achievements
            case "first_share":
                allAchievements[i].isUnlocked = sharesCount >= 1
            case "sharer":
                allAchievements[i].isUnlocked = sharesCount >= 5
            case "viral_master":
                allAchievements[i].isUnlocked = sharesCount >= 20
                
            // Quiz Achievements
            case "first_quiz":
                allAchievements[i].isUnlocked = quizzesCompleted >= 1
            case "quiz_master":
                allAchievements[i].isUnlocked = quizzesCompleted >= 5
            case "quiz_expert":
                allAchievements[i].isUnlocked = quizzesCompleted >= 15
                
            // Points Achievements
            case "points_starter":
                allAchievements[i].isUnlocked = totalPoints >= 50
            case "points_collector":
                allAchievements[i].isUnlocked = totalPoints >= 200
            case "points_master":
                allAchievements[i].isUnlocked = totalPoints >= 500
            case "charity_expert":
                allAchievements[i].isUnlocked = totalPoints >= 1000
            case "charity_legend":
                allAchievements[i].isUnlocked = totalPoints >= 2000
                
            // Level Achievements
            case "level_up":
                allAchievements[i].isUnlocked = currentLevel >= 5
            case "high_level":
                allAchievements[i].isUnlocked = currentLevel >= 10
                
            // Special Achievements (these would need additional tracking)
            case "daily_user":
                // This would need daily usage tracking
                allAchievements[i].isUnlocked = false
            case "helper":
                // This would need checklist completion tracking
                allAchievements[i].isUnlocked = false
                
            default:
                break
            }
            
            if !wasUnlocked && allAchievements[i].isUnlocked {
                hasNewAchievement = true
                print("🏆 New achievement unlocked: \(allAchievements[i].title)")
            }
        }
        
        if hasNewAchievement {
            updateRecentAchievements()
            saveGameData()
        }
    }
}

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let pointsRequired: Int
    var isUnlocked: Bool
}

struct TriviaQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
}
