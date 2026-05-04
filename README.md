# Я ПОМОГАЮ (I Help) - iOS App

## 📱 Overview

**Я ПОМОГАЮ** is a comprehensive iOS application designed to make charity and social good accessible and engaging. The app combines video content, gamification, educational resources, and volunteer opportunities to create a meaningful user experience that encourages positive social impact.

## 🎯 App Store Compliance

This app is fully compliant with **App Store Guideline 4.2 (Minimum Functionality)** and provides:

- ✅ **User Authentication & Profiles** - Complete user management system
- ✅ **Interactive Content** - Video player with like, share, and save functionality
- ✅ **Gamification System** - Points, levels, badges, and leaderboards
- ✅ **Educational Content** - Articles and facts about social issues
- ✅ **Volunteer Forms** - Real interaction with charity opportunities
- ✅ **Push Notifications** - Engagement and achievement notifications
- ✅ **Social Features** - Leaderboards and community aspects

## 🚀 Key Features

### 1. **Video Feed with Interactions**
- **Pexels API Integration** - Real charity videos (50 per page)
- **Interactive Controls** - Like, share, and save videos
- **Smooth Navigation** - Vertical swipe gestures
- **Points System** - Earn points for watching, liking, and sharing

### 2. **Gamification System**
- **Kindness Points** - Earn points for all interactions
- **Level System** - Progress through levels (1-50+)
- **Badge System** - 8 different achievement badges
- **Leaderboard** - Compete with other users
- **Interactive Game** - "Help the World" mini-game with 3 scenarios

### 3. **Educational Content**
- **Fact Cards** - Rotating educational facts
- **Articles** - In-depth articles about social issues
- **Interactive Learning** - Engaging content about charity and social good

### 4. **Volunteer & Donation System**
- **Volunteer Forms** - Complete form submission system
- **Help Types** - Volunteer, donate, share story options
- **Data Persistence** - Local storage of volunteer applications
- **Points Rewards** - Earn points for form submissions

### 5. **User Management**
- **Profile System** - Complete user profiles with avatars
- **Progress Tracking** - Track videos watched, points earned, actions completed
- **Impact Score** - Measure user's social impact
- **Authentication** - Simple email-based login/signup

### 6. **Push Notifications**
- **Daily Reminders** - Encourage daily engagement
- **Achievement Notifications** - Celebrate user milestones
- **New Content Alerts** - Notify about new videos
- **Interactive Notifications** - Like and share from notifications

## 🏗️ Technical Architecture

### **Framework & Technologies**
- **SwiftUI** - Modern declarative UI framework
- **AVKit** - Video playback and controls
- **AVFoundation** - Audio/video session management
- **UserNotifications** - Push notification system
- **URLSession** - API integration with Pexels
- **UserDefaults** - Local data persistence

### **Architecture Pattern**
- **MVVM (Model-View-ViewModel)** - Clean separation of concerns
- **ObservableObject** - Reactive data binding
- **Environment Objects** - Shared state management

### **Data Models**
```swift
// Core Models
- UserProfile: User data, points, badges, progress
- Badge: Achievement system with 8 different badges
- VolunteerForm: Volunteer application data
- GameAction: In-game actions and points
- LeaderboardEntry: Ranking system
- VideoInteraction: User video engagement tracking
```

### **Key ViewModels**
- **UserManager** - User authentication and profile management
- **PexelsVideoService** - Video content management
- **GameManager** - Gamification and points system
- **NotificationManager** - Push notification handling
- **AppStateManager** - App state and onboarding

## 📁 Project Structure

```
Yapomogayu/
├── view/
│   ├── ContentView.swift          # Main app interface
│   ├── EnhancedVideoPlayer.swift  # Video player with interactions
│   ├── HelpTheWorldGame.swift     # Interactive mini-game
│   ├── EnhancedProfileView.swift  # User profile management
│   ├── LearnView.swift           # Educational content
│   ├── ContactsView.swift        # Contact and feedback
│   ├── VolunteerFormView.swift   # Volunteer application
│   ├── BadgesView.swift          # Achievement system
│   ├── LeaderboardView.swift     # User rankings
│   ├── LoginView.swift           # Authentication
│   └── OnboardingView.swift      # First-time user experience
├── viewmodel/
│   ├── UserManager.swift         # User management
│   ├── PexelsVideoService.swift  # Video API integration
│   ├── GameManager.swift         # Gamification system
│   ├── NotificationManager.swift # Push notifications
│   └── AppStateManager.swift     # App state management
├── model/
│   ├── UserProfile.swift         # User data models
│   ├── VideoResponse.swift       # Video API models
│   └── User.swift               # Basic user model
└── Assets.xcassets/             # App icons and images
```

## 🎮 Gamification System

### **Points System**
- **Watch Video**: +1 point
- **Like Video**: +2 points  
- **Share Video**: +3 points
- **Play Game**: +5 points per action
- **Submit Volunteer Form**: +10 points
- **Complete Actions**: Variable points

### **Badge System**
1. **Первый шаг** - Watch first video (1 point)
2. **Зритель** - Watch 10 videos (10 points)
3. **Любитель** - Like 5 videos (15 points)
4. **Распространитель** - Share 3 videos (9 points)
5. **Игрок** - Play the game (5 points)
6. **Помощник** - Submit volunteer form (10 points)
7. **Преданный** - Active for 7 days (50 points)
8. **Чемпион** - Reach 100 points (100 points)

### **Level System**
- **Level 1-5**: Новичок (Beginner)
- **Level 6-10**: Помощник (Helper)
- **Level 11-20**: Волонтер (Volunteer)
- **Level 21-50**: Герой (Hero)
- **Level 50+**: Легенда (Legend)

## 🎯 Interactive Game: "Help the World"

### **Game Scenarios**
1. **Animal Rescue** - Feed and rescue animals
2. **Environmental Care** - Plant trees and clean environment
3. **Humanitarian Aid** - Help people and recycle

### **Game Mechanics**
- **60-second timer** per scenario
- **Multiple actions** per scenario
- **Points for each action** (4-10 points)
- **Smooth transitions** between scenarios
- **Success animations** for completed actions

## 📊 User Engagement Features

### **Video Interactions**
- **Like System** - Heart animation with points
- **Share System** - Native iOS share sheet
- **Save System** - Bookmark videos for later
- **Watch Tracking** - Track viewing progress

### **Social Features**
- **Leaderboard** - Global user rankings
- **Impact Score** - Measure social contribution
- **Progress Tracking** - Visual progress indicators
- **Achievement System** - Unlockable badges

### **Educational Content**
- **Fact Cards** - Auto-rotating educational facts
- **Articles** - In-depth social issue articles
- **Interactive Learning** - Engaging content presentation

## 🔔 Notification System

### **Notification Types**
- **Daily Reminders** - 9 AM daily engagement prompts
- **Achievement Notifications** - Badge unlock celebrations
- **Level Up Notifications** - Level progression alerts
- **New Content** - New video availability
- **Volunteer Reminders** - Encourage form submissions

### **Interactive Notifications**
- **Like Action** - Like videos directly from notifications
- **Share Action** - Share content from notifications
- **Open App Action** - Direct app launch

## 🎨 Design System

### **Color Palette**
- **Primary Yellow**: #FFD600 (RGB: 255, 214, 0)
- **Black**: #000000 (RGB: 0, 0, 0)
- **White**: #FFFFFF (RGB: 255, 255, 255)
- **Accent Colors**: Blue, Green, Red, Orange, Purple

### **Typography**
- **Headlines**: Large, bold fonts for emphasis
- **Body Text**: Readable, medium-weight fonts
- **Captions**: Small, light fonts for secondary information

### **UI Components**
- **Rounded Buttons** - 12px corner radius
- **Card Design** - Subtle shadows and rounded corners
- **Progress Indicators** - Linear and circular progress views
- **SF Symbols** - Consistent iconography throughout

## 📱 App Store Submission

### **App Store Review Note**
> "The updated version of Я Помогаю now provides meaningful user functionality. Users can log in, create profiles, earn kindness points by watching and sharing charity videos, play an interactive educational mini-game, and submit volunteer forms. These features make the app interactive, useful, and fully compliant with App Store Guideline 4.2."

### **Key Compliance Points**
- ✅ **Meaningful Functionality** - Real user interactions and value
- ✅ **User Engagement** - Gamification and social features
- ✅ **Educational Content** - Learning about social issues
- ✅ **Community Features** - Leaderboards and social interaction
- ✅ **Real-world Impact** - Volunteer forms and charity connections
- ✅ **Data Persistence** - User progress and achievements
- ✅ **Push Notifications** - Engagement and retention

## 🚀 Future Enhancements

### **Backend Integration**
- **Firebase Authentication** - Secure user management
- **Cloud Storage** - User data synchronization
- **Real-time Leaderboards** - Live ranking updates
- **Analytics** - User behavior tracking

### **Advanced Features**
- **Social Sharing** - Enhanced sharing capabilities
- **Video Comments** - Community interaction
- **Charity Partnerships** - Direct donation integration
- **Offline Mode** - Cached content access

### **Scalability**
- **Multi-language Support** - International expansion
- **Content Management** - Admin panel for content updates
- **API Integration** - Third-party charity APIs
- **Advanced Analytics** - Detailed user insights

## 📄 License

This project is proprietary software. All rights reserved.

## 👥 Team

- **Development**: Senior iOS Developer
- **Design**: UI/UX Designer
- **Content**: Social Impact Specialist
- **Testing**: Quality Assurance Team

---

**Я ПОМОГАЮ** - Making charity accessible, engaging, and impactful for everyone. 🌟