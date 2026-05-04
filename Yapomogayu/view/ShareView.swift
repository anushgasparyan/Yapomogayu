import SwiftUI

struct ShareView: View {
    @State private var showingShareSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Text("Пригласить")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Text("Пригласите друзей в приложение")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20) // Normal top padding
            .padding(.bottom, 20)
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // App Share Section
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(spacing: 12) {
                            AppShareCard(
                                title: "Я ПОМОГАЮ",
                                description: "Поделитесь ссылкой на App Store",
                                icon: "heart.fill",
                                color: Color(red: 255/255, green: 234/255, blue: 0/255)
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Share Actions
                    VStack(spacing: 16) {
                        Button(action: {
                            showingShareSheet = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title2)
                                
                                Text("Пригласить")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 255/255, green: 234/255, blue: 0/255))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // App Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("О приложении")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Я ПОМОГАЮ — платформа, которая помогает за счет рекламодателей и не просит каких-либо подписок или переводов денежных средств!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                        
                        Text("Версия 1.2")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 100)
            }
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [getAppShareText()])
        }
    }
    
    private func getAppShareText() -> String {
        return """
        Присоединяйтесь к движению добра и помогайте миру вместе с нами! ❤️
        https://apps.apple.com/am/app/%D1%8F-%D0%BF%D0%BE%D0%BC%D0%BE%D0%B3%D0%B0%D1%8E/id6747246074
        """
    }
    
}

struct AppShareCard: View {
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

#Preview {
    ShareView()
}
