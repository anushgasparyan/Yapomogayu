import SwiftUI

struct ContactsView: View {
    @State private var showingFeedback = false
    @State private var feedbackMessage = ""
    @State private var feedbackText = ""
    @State private var showingSuccess = false
    @State private var showingButton1 = false
    @State private var showingButton2 = false
    @State private var button1Text = ""
    @State private var button2Text = ""
    @State private var pendingAppStoreURL: URL?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Text("Свяжитесь с нами")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20) // Normal top padding
                
                // Contact Methods
                VStack(spacing: 16) {
                    ContactMethodCard(
                        icon: "envelope.fill",
                        title: "Email",
                        subtitle: "info@yapomogayu.ru",
                        action: {
                            openEmailApp()
                        }
                    )
                }
                
                
                // Feedback Form
                VStack(alignment: .leading, spacing: 16) {
                    Text("Обратная связь")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        feedbackText = ""
                        showingFeedback = true
                    }) {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Оставить отзыв")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 255/255, green: 234/255, blue: 0/255))
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                    }
                    
                    Button(action: {
                        button1Text = ""
                        showingButton1 = true
                    }) {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Оставить предложение")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 255/255, green: 234/255, blue: 0/255))
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                    }
                    
                    Button(action: {
                        button2Text = ""
                        showingButton2 = true
                    }) {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Для рекламодателей")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 255/255, green: 234/255, blue: 0/255))
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                    }
                }
                
                // About Section
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
            }
            .padding()
            .padding(.bottom, 200)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingFeedback) {
            FeedbackView(
                feedbackText: $feedbackText,
                isPresented: $showingFeedback,
                title: "Ваш отзыв",
                buttonText: "Отправить отзыв",
                onSubmit: { message in
                    openAppStoreReview(with: message)
                }
            )
        }
        .sheet(isPresented: $showingButton1) {
            FeedbackView(
                feedbackText: $button1Text,
                isPresented: $showingButton1,
                title: "Ваше предложение",
                buttonText: "Отправить предложение",
                onSubmit: { message in
                    openAppStoreReview(with: message)
                }
            )
        }
        .sheet(isPresented: $showingButton2) {
            FeedbackView(
                feedbackText: $button2Text,
                isPresented: $showingButton2,
                title: "Ваше предложение",
                buttonText: "Отправить предложение",
                onSubmit: { message in
                    openAppStoreReview(with: message)
                }
            )
        }
        .alert("Текст скопирован!", isPresented: $showingSuccess) {
            Button("OK") {
                // Open App Store review page after user dismisses the alert
                if let url = pendingAppStoreURL {
                    UIApplication.shared.open(url)
                    pendingAppStoreURL = nil
                }
            }
        } message: {
            Text("Ваш текст скопирован в буфер обмена. Откроется страница отзывов в App Store, где вы сможете вставить текст и отправить отзыв.")
        }
    }
    
    private func openEmailApp() {
        let email = "info@yapomogayu.ru"
        let subject = "Обратная связь по приложению Я ПОМОГАЮ"
        let body = "Здравствуйте!\n\n"
        
        // Encode parameters for mailto URL
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Create mailto URL to open mail app
        let mailtoURL = "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)"
        
        if let url = URL(string: mailtoURL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                // Fallback for simulator or devices without mail app
                // Open web-based email service
                let webMailURL = "https://mail.google.com/mail/?view=cm&fs=1&to=\(email)&su=\(encodedSubject)&body=\(encodedBody)"
                if let webURL = URL(string: webMailURL) {
                    UIApplication.shared.open(webURL)
                }
            }
        }
    }
    
    private func openAppStoreReview(with text: String) {
        // Copy text to clipboard
        UIPasteboard.general.string = text
        
        // App Store ID for "Я помогаю"
        let appStoreID = "6747246074"
        
        // Use the standard App Store review URL
        // This will open in the App Store app if available, or Safari as fallback
        let appStoreURLString = "https://apps.apple.com/app/id\(appStoreID)?action=write-review"
        
        if let url = URL(string: appStoreURLString) {
            // Store the URL and show alert first
            pendingAppStoreURL = url
            showingSuccess = true
        } else {
            showingSuccess = true
        }
    }
}

struct ContactMethodCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if action != nil {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .onTapGesture {
            action?()
        }
    }
}


struct FeedbackView: View {
    @Binding var feedbackText: String
    @Binding var isPresented: Bool
    let title: String
    let buttonText: String
    let onSubmit: (String) -> Void
    
    @State private var isSubmitting = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Text("Обратная связь")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Отмена")
                        .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
                }
            }
            .padding()
            .background(Color.black)
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("Расскажите, что вы думаете о приложении...", text: $feedbackText, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(5...10)
                }
                
                Button(action: {
                    isSubmitting = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        onSubmit(feedbackText)
                        isSubmitting = false
                        isPresented = false
                    }
                }) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "paperplane.fill")
                        }
                        
                        Text(isSubmitting ? "Отправляем..." : buttonText)
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 255/255, green: 234/255, blue: 0/255))
                    .cornerRadius(12)
                }
                .disabled(isSubmitting || feedbackText.isEmpty)
                
                Spacer()
            }
            .padding()
            .background(Color.black)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContactsView()
}
