import Foundation
import SwiftUI

struct UserProfile: Codable, Identifiable {
    let id: UUID
    var name: String
    var email: String
    var avatar: String?
    var kindnessPoints: Int
    var level: Int
    var badges: [Badge]
    var watchedVideos: Set<Int>
    var likedVideos: Set<Int>
    var sharedVideos: Set<Int>
    var completedActions: [String]
    var joinDate: Date
    var lastActive: Date
    
    init(name: String, email: String) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.avatar = nil
        self.kindnessPoints = 0
        self.level = 1
        self.badges = []
        self.watchedVideos = []
        self.likedVideos = []
        self.sharedVideos = []
        self.completedActions = []
        self.joinDate = Date()
        self.lastActive = Date()
    }
    
    var pointsToNextLevel: Int {
        return (level * 100) - kindnessPoints
    }
    
    var impactScore: Int {
        return watchedVideos.count + likedVideos.count + sharedVideos.count + completedActions.count
    }
    
    var rank: String {
        switch level {
        case 1...5: return "Новичок"
        case 6...10: return "Помощник"
        case 11...20: return "Волонтер"
        case 21...50: return "Герой"
        default: return "Легенда"
        }
    }
}

struct Badge: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: String
    let pointsRequired: Int
    let isUnlocked: Bool
    let unlockedDate: Date?
    
    init(id: String, name: String, description: String, icon: String, color: String, pointsRequired: Int) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.color = color
        self.pointsRequired = pointsRequired
        self.isUnlocked = false
        self.unlockedDate = nil
    }
    
    static let allBadges = [
        Badge(id: "first_video", name: "Первый шаг", description: "Посмотрел первое видео", icon: "play.circle", color: "blue", pointsRequired: 1),
        Badge(id: "video_watcher", name: "Зритель", description: "Посмотрел 10 видео", icon: "eye", color: "green", pointsRequired: 10),
        Badge(id: "video_lover", name: "Любитель", description: "Лайкнул 5 видео", icon: "heart", color: "red", pointsRequired: 15),
        Badge(id: "sharer", name: "Распространитель", description: "Поделился 3 видео", icon: "square.and.arrow.up", color: "orange", pointsRequired: 9),
        Badge(id: "gamer", name: "Игрок", description: "Сыграл в игру", icon: "gamecontroller", color: "purple", pointsRequired: 5),
        Badge(id: "helper", name: "Помощник", description: "Заполнил форму помощи", icon: "hand.raised", color: "yellow", pointsRequired: 10),
        Badge(id: "dedicated", name: "Преданный", description: "Активен 7 дней подряд", icon: "calendar", color: "indigo", pointsRequired: 50),
        Badge(id: "champion", name: "Чемпион", description: "Набрал 100 очков", icon: "crown", color: "gold", pointsRequired: 100)
    ]
}

struct VolunteerForm: Codable, Identifiable {
    let id: UUID
    let name: String
    let email: String
    let city: String
    let helpType: HelpType
    let message: String
    let submissionDate: Date
    
    init(name: String, email: String, city: String, helpType: HelpType, message: String) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.city = city
        self.helpType = helpType
        self.message = message
        self.submissionDate = Date()
    }
}

enum HelpType: String, CaseIterable, Codable {
    case volunteer = "Волонтер"
    case donate = "Пожертвовать"
    case shareStory = "Поделиться историей"
    case other = "Другое"
}

struct LeaderboardEntry: Codable, Identifiable {
    let id: UUID
    let name: String
    let points: Int
    let rank: Int
    let avatar: String?
    
    init(name: String, points: Int, rank: Int, avatar: String? = nil) {
        self.id = UUID()
        self.name = name
        self.points = points
        self.rank = rank
        self.avatar = avatar
    }
}

struct VideoInteraction: Codable {
    let videoId: Int
    let isLiked: Bool
    let isShared: Bool
    let watchTime: TimeInterval
    let interactionDate: Date
    
    init(videoId: Int, isLiked: Bool = false, isShared: Bool = false, watchTime: TimeInterval = 0) {
        self.videoId = videoId
        self.isLiked = isLiked
        self.isShared = isShared
        self.watchTime = watchTime
        self.interactionDate = Date()
    }
}

struct GameAction: Codable, Identifiable {
    let id: UUID
    let actionType: GameActionType
    let points: Int
    let timestamp: Date
    
    init(actionType: GameActionType, points: Int) {
        self.id = UUID()
        self.actionType = actionType
        self.points = points
        self.timestamp = Date()
    }
}

enum GameActionType: String, CaseIterable, Codable {
    case feedAnimal = "Покормил животное"
    case plantTree = "Посадил дерево"
    case cleanEnvironment = "Очистил окружающую среду"
    case rescueAnimal = "Спас животное"
    case helpPerson = "Помог человеку"
    case recycle = "Переработал мусор"
}
