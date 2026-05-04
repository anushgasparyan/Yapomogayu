import SwiftUI
import AuthenticationServices

struct LoginPageView: View {
    @StateObject private var appleSignInManager = AppleSignInManager()
    @ObservedObject var gameManager: GameManager
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isRegularLogin = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Main Header
                VStack(spacing: 20) {
                    Text("Добро пожаловать!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Войдите, чтобы помогать миру и зарабатывать очки добра")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)
                }
            
            // Login Options
            VStack(spacing: 20) {
                // Apple Sign In Button
                if appleSignInManager.isSignedIn {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Вход выполнен через Apple")
                                .foregroundColor(.white)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        if let userName = appleSignInManager.userName {
                            Text("Добро пожаловать, \(userName)!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Button("Продолжить") {
                            let email = appleSignInManager.userEmail ?? "apple@yapomogayu.ru"
                            let name = appleSignInManager.userName ?? "Apple User"
                            gameManager.loginWithApple(email: email, name: name)
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(red: 255/255, green: 234/255, blue: 0/255))
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                } else {
                    // Regular Login Form
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            TextField("Email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            SecureField("Пароль", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        Button("Войти") {
                            performRegularLogin()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(red: 255/255, green: 234/255, blue: 0/255))
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                        .disabled(email.isEmpty || password.isEmpty)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                        Text("или")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 16)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                    }
                    
                    // Apple Sign In Button
                    Button(action: {
                        print("🍎 Attempting Apple Sign In...")
                        appleSignInManager.signInWithApple()
                    }) {
                        HStack {
                            Image(systemName: "applelogo")
                                .font(.title2)
                            Text("Войти через Apple")
                                .font(.headline)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    
                    // Show error message if any
                    if let errorMessage = appleSignInManager.errorMessage {
                        Text("Ошибка: \(errorMessage)")
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // App Info
            VStack(spacing: 12) {
                Text("Я ПОМОГАЮ")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 255/255, green: 234/255, blue: 0/255))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Делаем благотворительность доступной и увлекательной")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            .padding(.horizontal, 20)
            
            Spacer()
            }
            .padding(.top, 60)
            .padding(.bottom, 220) // Bottom padding for Yandex buttons and tab bar
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
        .alert("Ошибка входа", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func performRegularLogin() {
        // Check credentials
        if email == "yapomogayu@mail.ru" && password == "12345678" {
            print("✅ Regular login successful")
            print("🔍 Before login - isLoggedIn: \(gameManager.isLoggedIn)")
            gameManager.loginWithEmail(email: email, name: "Пользователь")
            print("🔍 After login - isLoggedIn: \(gameManager.isLoggedIn)")
        } else {
            print("❌ Invalid credentials")
            errorMessage = "Неверный email или пароль"
            showingError = true
        }
    }
}

#Preview {
    LoginPageView(gameManager: GameManager())
}
