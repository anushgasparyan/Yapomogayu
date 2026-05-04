import SwiftUI

struct CharityQuizView: View {
    @ObservedObject var gameManager: GameManager
    @StateObject private var buildConfig = BuildConfigurationManager.shared
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var score = 0
    @State private var quizCompleted = false
    @State private var quizStarted = false
    @State private var timeRemaining = 30
    @State private var timer: Timer?
    @State private var showingTimeUpAlert = false
    @State private var showingProfile = false
    
    let allCharityQuestions = [
        CharityQuestion(
            question: "Сколько детей в мире не имеют доступа к образованию?",
            options: ["57 миллионов", "100 миллионов", "200 миллионов", "50 миллионов"],
            correctAnswer: 0,
            explanation: "По данным ЮНЕСКО, около 57 миллионов детей не имеют доступа к образованию."
        ),
        CharityQuestion(
            question: "Какой процент населения мира живет в условиях крайней нищеты?",
            options: ["5%", "10%", "15%", "20%"],
            correctAnswer: 1,
            explanation: "Около 10% населения мира живет менее чем на $2.15 в день."
        ),
        CharityQuestion(
            question: "Сколько людей в мире не имеют доступа к чистой питьевой воде?",
            options: ["200 миллионов", "500 миллионов", "771 миллион", "1 миллиард"],
            correctAnswer: 2,
            explanation: "771 миллион человек не имеют доступа к чистой питьевой воде."
        ),
        CharityQuestion(
            question: "Какая организация получила Нобелевскую премию мира в 2020 году?",
            options: ["Врачи без границ", "Красный Крест", "Всемирная продовольственная программа", "ЮНИСЕФ"],
            correctAnswer: 2,
            explanation: "Всемирная продовольственная программа получила Нобелевскую премию мира в 2020 году."
        ),
        CharityQuestion(
            question: "Сколько детей в возрасте до 5 лет умирают каждый день?",
            options: ["5,000", "10,000", "15,000", "20,000"],
            correctAnswer: 2,
            explanation: "Ежедневно около 15,000 детей умирают от предотвратимых причин."
        ),
        CharityQuestion(
            question: "Какая страна тратит наибольший процент ВВП на благотворительность?",
            options: ["США", "Великобритания", "Нидерланды", "Австралия"],
            correctAnswer: 2,
            explanation: "Нидерланды тратят около 0.7% ВВП на международную помощь."
        ),
        CharityQuestion(
            question: "Сколько людей в мире страдают от голода?",
            options: ["690 миллионов", "1 миллиард", "1.5 миллиарда", "2 миллиарда"],
            correctAnswer: 0,
            explanation: "Около 690 миллионов человек страдают от хронического голода."
        ),
        CharityQuestion(
            question: "Какой процент детей в развивающихся странах не ходят в школу?",
            options: ["10%", "20%", "30%", "40%"],
            correctAnswer: 1,
            explanation: "Около 20% детей в развивающихся странах не имеют доступа к образованию."
        ),
        CharityQuestion(
            question: "Какая организация основала Красный Крест?",
            options: ["Анри Дюнан", "Флоренс Найтингейл", "Мать Тереза", "Нельсон Мандела"],
            correctAnswer: 0,
            explanation: "Анри Дюнан основал Красный Крест в 1863 году."
        ),
        CharityQuestion(
            question: "Сколько людей в мире живут без электричества?",
            options: ["500 миллионов", "800 миллионов", "1 миллиард", "1.2 миллиарда"],
            correctAnswer: 1,
            explanation: "Около 800 миллионов человек не имеют доступа к электричеству."
        ),
        CharityQuestion(
            question: "Какая благотворительная организация самая крупная в мире?",
            options: ["ЮНИСЕФ", "Врачи без границ", "Красный Крест", "Оксфам"],
            correctAnswer: 0,
            explanation: "ЮНИСЕФ - самая крупная благотворительная организация в мире."
        ),
        CharityQuestion(
            question: "Сколько людей в мире являются беженцами?",
            options: ["26 миллионов", "50 миллионов", "80 миллионов", "100 миллионов"],
            correctAnswer: 2,
            explanation: "Около 80 миллионов человек являются беженцами или внутренне перемещенными лицами."
        ),
        CharityQuestion(
            question: "Какая болезнь является основной причиной смерти детей в развивающихся странах?",
            options: ["Малярия", "Пневмония", "Диарея", "Корь"],
            correctAnswer: 1,
            explanation: "Пневмония является основной причиной смерти детей в развивающихся странах."
        ),
        CharityQuestion(
            question: "Сколько людей в мире не умеют читать и писать?",
            options: ["750 миллионов", "1 миллиард", "1.5 миллиарда", "2 миллиарда"],
            correctAnswer: 0,
            explanation: "Около 750 миллионов взрослых не умеют читать и писать."
        ),
        CharityQuestion(
            question: "Какая организация получила Нобелевскую премию мира в 2019 году?",
            options: ["Грета Тунберг", "Абий Ахмед", "Дональд Трамп", "Владимир Путин"],
            correctAnswer: 1,
            explanation: "Абий Ахмед, премьер-министр Эфиопии, получил Нобелевскую премию мира в 2019 году."
        )
    ]
    
    @State private var charityQuestions: [CharityQuestion] = []
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    
                    if !quizStarted {
                        startView
                    } else if !quizCompleted {
                        quizContentView
                    } else {
                        resultsView
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 220)
            }
        }
        .onAppear {
            randomizeQuestions()
        }
        .onDisappear(perform: stopTimer)
        .alert("Время вышло!", isPresented: $showingTimeUpAlert) {
            Button("OK") {
                nextQuestion()
            }
        } message: {
            Text("Вы не успели ответить на вопрос.")
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
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
            
            Text("Благотворительная Викторина")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Проверьте свои знания о благотворительности!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Start View
    private var startView: some View {
        VStack(spacing: 24) {
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
            
            VStack(spacing: 16) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
                
                Text("Готовы начать викторину?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Ответьте на \(charityQuestions.count) вопросов о благотворительности и заработайте очки!")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            
            VStack(spacing: 12) {
                Text("Правила:")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.orange)
                        Text("30 секунд на каждый вопрос")
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("10 очков за правильный ответ")
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
                        Text("Проверьте свои знания о благотворительности")
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            
            Button(action: {
                startQuiz()
            }) {
                Text("Начать викторину")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 255/255, green: 234/255, blue: 0/255))
                    .cornerRadius(12)
                    .contentShape(Rectangle())
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Quiz Content View
    private var quizContentView: some View {
        VStack(spacing: 20) {
            // Progress and Timer
            HStack {
                Text("Вопрос \(currentQuestionIndex + 1) из \(charityQuestions.count)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Очки: \(score)")
                    .font(.headline)
                    .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
            }
            
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(.orange)
                Text("\(timeRemaining) сек")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.orange.opacity(0.2))
            .cornerRadius(12)
            
            // Question
            Text(charityQuestions[currentQuestionIndex].question)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
            
            // Answer Options
            VStack(spacing: 12) {
                ForEach(0..<charityQuestions[currentQuestionIndex].options.count, id: \.self) { index in
                    Button(action: {
                        selectAnswer(index)
                    }) {
                        HStack {
                            Text(charityQuestions[currentQuestionIndex].options[index])
                                .font(.headline)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                            
                            if selectedAnswer == index {
                                Image(systemName: index == charityQuestions[currentQuestionIndex].correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(index == charityQuestions[currentQuestionIndex].correctAnswer ? .green : .red)
                            }
                        }
                        .padding()
                        .background(
                            selectedAnswer == index ? 
                            (index == charityQuestions[currentQuestionIndex].correctAnswer ? Color.green.opacity(0.3) : Color.red.opacity(0.3)) : 
                            Color.gray.opacity(0.1)
                        )
                        .cornerRadius(12)
                    }
                    .disabled(selectedAnswer != nil)
                }
            }
            
            // Next Button
            if selectedAnswer != nil {
                Button(action: {
                    nextQuestion()
                }) {
                    Text(currentQuestionIndex < charityQuestions.count - 1 ? "Следующий вопрос" : "Завершить викторину")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 255/255, green: 234/255, blue: 0/255))
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Results View
    private var resultsView: some View {
        VStack(spacing: 24) {
            Image(systemName: score >= Int(Double(charityQuestions.count) * 0.8) ? "trophy.fill" : "star.fill")
                .font(.system(size: 80))
                .foregroundColor(score >= Int(Double(charityQuestions.count) * 0.8) ? .yellow : .orange)
            
            Text("Викторина завершена!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Ваш результат: \(score) из \(charityQuestions.count * 10)")
                .font(.title2)
                .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
            
            Text(score >= Int(Double(charityQuestions.count) * 0.8) ? 
                 "Отлично! Вы настоящий эксперт в благотворительности! 🌟" :
                 "Хорошая работа! Продолжайте изучать благотворительность! 💪")
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: {
                restartQuiz()
            }) {
                Text("Начать заново")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 255/255, green: 234/255, blue: 0/255))
                    .cornerRadius(12)
                    .contentShape(Rectangle())
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Quiz Logic
    private func startQuiz() {
        quizStarted = true
        resetQuiz()
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timeRemaining = 30
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                showingTimeUpAlert = true
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
    }
    
    private func selectAnswer(_ index: Int) {
        timer?.invalidate()
        selectedAnswer = index
        
        if index == charityQuestions[currentQuestionIndex].correctAnswer {
            score += 10
            gameManager.addPoints(10)
            print("✅ Correct answer! Score: \(score), Total points: \(gameManager.totalPoints)")
        } else {
            print("❌ Wrong answer. Score: \(score)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            nextQuestion()
        }
    }
    
    private func nextQuestion() {
        selectedAnswer = nil
        if currentQuestionIndex < charityQuestions.count - 1 {
            currentQuestionIndex += 1
            startTimer()
        } else {
            quizCompleted = true
            gameManager.completeQuiz(score: score)
            stopTimer()
            print("🎉 Quiz completed! Final score: \(score), Total points: \(gameManager.totalPoints)")
        }
    }
    
    private func restartQuiz() {
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        quizCompleted = false
        quizStarted = false
        showingTimeUpAlert = false
        randomizeQuestions()
    }
    
    private func randomizeQuestions() {
        // Select 5 random questions from all available questions
        charityQuestions = Array(allCharityQuestions.shuffled().prefix(5))
        print("🎲 Randomized \(charityQuestions.count) questions for quiz")
    }
    
    private func resetQuiz() {
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        quizCompleted = false
        showingTimeUpAlert = false
    }
}

struct CharityQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
}

#Preview {
    CharityQuizView(gameManager: GameManager())
}