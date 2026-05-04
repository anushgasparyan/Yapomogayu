import SwiftUI

struct LearnView: View {
    @State private var currentCardIndex = 0
    @State private var showingArticle = false
    @State private var selectedArticle: Article? = nil
    @State private var loadingArticleId: UUID? = nil
    
    let factCards = [
        FactCard(
            title: "Чистая вода спасает жизни",
            fact: "Каждые 2 минуты ребенок умирает от болезней, связанных с грязной водой",
            image: "drop.fill",
            color: .blue
        ),
        FactCard(
            title: "Голод в мире",
            fact: "828 миллионов человек в мире страдают от голода каждый день",
            image: "heart.fill",
            color: .red
        ),
        FactCard(
            title: "Образование меняет жизнь",
            fact: "Каждый дополнительный год обучения увеличивает доходы на 10%",
            image: "book.fill",
            color: .green
        ),
        FactCard(
            title: "Благотворительность работает",
            fact: "Каждый доллар, потраченный на профилактику, экономит $7 на лечении",
            image: "star.fill",
            color: .orange
        ),
        FactCard(
            title: "Дети нуждаются в защите",
            fact: "152 миллиона детей в мире вынуждены работать вместо учебы",
            image: "shield.fill",
            color: .purple
        )
    ]
    
    let articles = [
        Article(
            title: "Почему чистая вода важна",
            content: """
            Доступ к чистой воде — это не просто удобство, это право человека и основа здоровой жизни.
            
            🔹 Каждый день 2 миллиарда человек пьют загрязненную воду
            🔹 80% болезней в развивающихся странах связаны с плохой водой
            🔹 Чистая вода может спасти 1,4 миллиона детских жизней ежегодно
            🔹 Каждый доллар, вложенный в водоснабжение, приносит $4 экономии
            
            Простые решения, такие как колодцы и фильтры, могут кардинально изменить жизнь целых сообществ.
            """,
            image: "drop.fill",
            color: .blue
        ),
        Article(
            title: "5 фактов о детском голоде",
            content: """
            Детский голод — это глобальная проблема, которую мы можем решить вместе.
            
            🔹 149 миллионов детей в мире страдают от задержки роста из-за недоедания
            🔹 Каждый 3-й ребенок в возрасте до 5 лет не получает достаточно питательных веществ
            🔹 Школьные обеды увеличивают посещаемость на 20%
            🔹 Правильное питание в первые 1000 дней жизни критически важно
            🔹 $1 в день может накормить ребенка в школе целый месяц
            
            Инвестиции в детское питание — это инвестиции в будущее человечества.
            """,
            image: "heart.fill",
            color: .red
        ),
        Article(
            title: "Образование спасает жизни",
            content: """
            Образование — это не просто знания, это инструмент спасения жизней.
            
            🔹 Каждый дополнительный год обучения матери снижает детскую смертность на 5-10%
            🔹 Образованные женщины рожают меньше детей, но лучше заботятся о них
            🔹 Грамотность помогает людям принимать правильные решения о здоровье
            🔹 Образование снижает риск ранних браков и подростковой беременности
            🔹 Образованные люди живут в среднем на 6 лет дольше
            
            Образование — это вакцина против бедности и болезней.
            """,
            image: "book.fill",
            color: .green
        ),
        Article(
            title: "Как работает благотворительность",
            content: """
            Благотворительность — это не просто помощь, это инвестиция в лучшее будущее.
            
            🔹 Каждый $1, потраченный на профилактику, экономит $7 на лечении
            🔹 Благотворительные организации помогают 1,5 миллиарда людей ежегодно
            🔹 85% благотворительных средств идет непосредственно на помощь
            🔹 Волонтеры вносят вклад в $1,5 триллиона в мировую экономику
            🔹 Помощь создает эффект мультипликатора в местных сообществах
            
            Даже небольшая помощь может изменить чью-то жизнь навсегда.
            """,
            image: "star.fill",
            color: .orange
        ),
        Article(
            title: "Климатические изменения и помощь",
            content: """
            Изменение климата создает новые вызовы для благотворительности.
            
            🔹 100 миллионов человек ежегодно страдают от стихийных бедствий
            🔹 Климатические беженцы составляют 70% всех перемещенных лиц
            🔹 Адаптация к климату требует $300 миллиардов ежегодно
            🔹 Зеленые технологии помогают 2 миллиардам людей
            🔹 Устойчивое развитие спасает 1,5 миллиона жизней в год
            
            Помощь в адаптации к климату — это помощь будущим поколениям.
            """,
            image: "leaf.fill",
            color: .green
        ),
        Article(
            title: "Психическое здоровье и поддержка",
            content: """
            Психическое здоровье — невидимая, но критически важная проблема.
            
            🔹 1 миллиард человек страдают от психических расстройств
            🔹 Депрессия — ведущая причина инвалидности в мире
            🔹 Каждые 40 секунд кто-то умирает от суицида
            🔹 75% психических расстройств начинаются до 24 лет
            🔹 Поддержка может снизить суициды на 50%
            
            Психическое здоровье — это здоровье всего общества.
            """,
            image: "brain.head.profile",
            color: .purple
        ),
        Article(
            title: "Женщины и гендерное равенство",
            content: """
            Равенство полов — основа устойчивого развития.
            
            🔹 130 миллионов девочек не ходят в школу
            🔹 Женщины зарабатывают на 23% меньше мужчин
            🔹 1 из 3 женщин подвергается насилию
            🔹 Женщины составляют 70% беднейших людей мира
            🔹 Образование девочек снижает детскую смертность на 50%
            
            Инвестиции в женщин — инвестиции в будущее всего мира.
            """,
            image: "person.2.fill",
            color: .pink
        ),
        Article(
            title: "Технологии для добра",
            content: """
            Цифровые технологии революционизируют благотворительность.
            
            🔹 Мобильные платежи помогают 1,7 миллиарда людей
            🔹 ИИ диагностирует болезни у 2 миллиардов пациентов
            🔹 Блокчейн обеспечивает прозрачность пожертвований
            🔹 Телемедицина доступна 500 миллионам людей
            🔹 Цифровое образование получают 1,2 миллиарда детей
            
            Технологии делают помощь более эффективной и доступной.
            """,
            image: "laptopcomputer",
            color: .blue
        ),
        Article(
            title: "Пожилые люди и забота",
            content: """
            Старение населения требует новых подходов к заботе.
            
            🔹 К 2050 году 2 миллиарда людей будут старше 60 лет
            🔹 1 из 6 пожилых людей подвергается насилию
            🔹 Одиночество сокращает жизнь на 8 лет
            🔹 80% пожилых людей живут в развивающихся странах
            🔹 Социальная поддержка продлевает жизнь на 5 лет
            
            Забота о пожилых — это забота о нашем будущем.
            """,
            image: "figure.walk",
            color: .gray
        ),
        Article(
            title: "Беженцы и миграция",
            content: """
            Миграция — глобальная реальность, требующая сострадания.
            
            🔹 100 миллионов людей — беженцы или перемещенные лица
            🔹 50% беженцев — дети младше 18 лет
            🔹 85% беженцев живут в развивающихся странах
            🔹 Средний срок жизни в лагере беженцев — 17 лет
            🔹 1% беженцев получают высшее образование
            
            Помощь беженцам — это помощь человечеству.
            """,
            image: "figure.walk.circle",
            color: .brown
        ),
        Article(
            title: "Доступность и инклюзия",
            content: """
            Инклюзивное общество — общество для всех.
            
            🔹 1 миллиард людей живут с инвалидностью
            🔹 80% инвалидов живут в развивающихся странах
            🔹 Только 1% детей с инвалидностью получают образование
            🔹 Инклюзивные рабочие места увеличивают прибыль на 28%
            🔹 Доступность помогает 15% населения мира
            
            Инклюзия делает мир лучше для всех.
            """,
            image: "accessibility",
            color: .cyan
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(red: 255 / 255.0, green: 234 / 255.0, blue: 0 / 255.0))
                    
                    Text("Узнайте больше")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Изучайте важные факты о благотворительности и социальных проблемах")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Did you know? Cards
                VStack(alignment: .leading, spacing: 16) {
                    Text("Знаете ли вы?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    TabView(selection: $currentCardIndex) {
                        ForEach(0..<factCards.count, id: \.self) { index in
                            FactCardView(card: factCards[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height: 200)
                    .onAppear {
                        // Auto-advance cards every 5 seconds
                        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                            withAnimation {
                                currentCardIndex = (currentCardIndex + 1) % factCards.count
                            }
                        }
                    }
                }
                
                // Articles Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Статьи")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(articles) { article in
                            ArticleCardView(article: article) {
                                // Ensure proper state management
                                print("📖 Article tapped: \(article.title)")
                                loadingArticleId = article.id
                                
                                DispatchQueue.main.async {
                                    selectedArticle = article
                                    print("📖 State updated - selectedArticle: \(selectedArticle?.title ?? "nil")")
                                    
                                    // Small delay to ensure state is properly set
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        showingArticle = true
                                        loadingArticleId = nil
                                        print("📖 Sheet presentation triggered - showingArticle: \(showingArticle)")
                                    }
                                }
                            }
                            .disabled(loadingArticleId == article.id)
                            .opacity(loadingArticleId == article.id ? 0.6 : 1.0)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 220) // Bottom padding for Yandex buttons and tab bar
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingArticle) {
            if let article = selectedArticle {
                ArticleDetailView(article: article)
                    .onDisappear {
                        // Reset state when sheet is dismissed
                        selectedArticle = nil
                    }
            } else {
                // Fallback view if article is nil
                VStack {
                    Text("Ошибка загрузки статьи")
                        .font(.title2)
                        .foregroundColor(.red)
                    
                    Button("Закрыть") {
                        showingArticle = false
                        selectedArticle = nil
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
        }
    }
}

struct FactCard: Identifiable {
    let id = UUID()
    let title: String
    let fact: String
    let image: String
    let color: Color
}

struct Article: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let image: String
    let color: Color
}

struct FactCardView: View {
    let card: FactCard
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: card.image)
                .font(.system(size: 40))
                .foregroundColor(card.color)
            
            Text(card.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(card.fact)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
        .padding(20)
        .background(card.color.opacity(0.1))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

struct ArticleCardView: View {
    let article: Article
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: article.image)
                    .font(.title2)
                    .foregroundColor(article.color)
                    .frame(width: 40, height: 40)
                    .background(article.color.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text("Нажмите, чтобы прочитать")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct ArticleDetailView: View {
    let article: Article
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Text("Статья")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Закрыть")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.black)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        Image(systemName: article.image)
                            .font(.title)
                            .foregroundColor(article.color)
                            .frame(width: 50, height: 50)
                            .background(article.color.opacity(0.1))
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading) {
                            Text(article.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    // Content
                    Text(article.content)
                        .font(.body)
                        .foregroundColor(.white)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .background(Color.black)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    LearnView()
}
