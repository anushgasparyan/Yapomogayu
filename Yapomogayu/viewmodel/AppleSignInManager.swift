import Foundation
import AuthenticationServices
import SwiftUI

class AppleSignInManager: NSObject, ObservableObject {
    @Published var isSignedIn = false
    @Published var userIdentifier: String?
    @Published var userEmail: String?
    @Published var userName: String?
    @Published var errorMessage: String?
    
    override init() {
        super.init()
        checkSignInStatus()
    }
    
    private func checkSignInStatus() {
        if let userID = UserDefaults.standard.string(forKey: "appleUserID") {
            self.userIdentifier = userID
            self.isSignedIn = true
            self.userEmail = UserDefaults.standard.string(forKey: "appleUserEmail")
            self.userName = UserDefaults.standard.string(forKey: "appleUserName")
        }
    }
    
    func signInWithApple() {
        errorMessage = nil
                
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
                
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "appleUserID")
        UserDefaults.standard.removeObject(forKey: "appleUserEmail")
        UserDefaults.standard.removeObject(forKey: "appleUserName")
        
        DispatchQueue.main.async {
            self.isSignedIn = false
            self.userIdentifier = nil
            self.userEmail = nil
            self.userName = nil
        }
    }
    
    private func saveUserData(identifier: String, email: String?, name: String?) {
        UserDefaults.standard.set(identifier, forKey: "appleUserID")
        UserDefaults.standard.set(email, forKey: "appleUserEmail")
        UserDefaults.standard.set(name, forKey: "appleUserName")
        
        DispatchQueue.main.async {
            self.isSignedIn = true
            self.userIdentifier = identifier
            self.userEmail = email
            self.userName = name
        }
    }
}

extension AppleSignInManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let email = appleIDCredential.email
            let fullName = appleIDCredential.fullName
            
            var displayName: String?
            if let givenName = fullName?.givenName, let familyName = fullName?.familyName {
                displayName = "\(givenName) \(familyName)"
            } else if let givenName = fullName?.givenName {
                displayName = givenName
            } else if let familyName = fullName?.familyName {
                displayName = familyName
            }
            
            saveUserData(identifier: userIdentifier, email: email, name: displayName)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DispatchQueue.main.async {
            if let authError = error as? ASAuthorizationError {
                switch authError.code {
                case .canceled:
                    print("User canceled Apple Sign In")
                    self.errorMessage = "Вход отменен пользователем"
                case .failed:
                    print("Apple Sign In failed")
                    self.errorMessage = "Ошибка входа. Попробуйте снова"
                case .invalidResponse:
                    print("Invalid response from Apple Sign In")
                    self.errorMessage = "Неверный ответ от Apple. Проверьте настройки"
                case .notHandled:
                    print("Apple Sign In not handled")
                    self.errorMessage = "Apple Sign In не обработан. Проверьте конфигурацию"
                case .unknown:
                    print("Unknown Apple Sign In error")
                    self.errorMessage = "Неизвестная ошибка. Попробуйте позже"
                case .notInteractive:
                    print("Apple Sign In not interactive")
                    self.errorMessage = "Apple Sign In недоступен в текущем контексте"
                case .matchedExcludedCredential:
                    print("Apple Sign In matched excluded credential")
                    self.errorMessage = "Учетные данные исключены"
                case .credentialImport:
                    print("Apple Sign In credential import error")
                    self.errorMessage = "Ошибка импорта учетных данных"
                case .credentialExport:
                    print("Apple Sign In credential export error")
                    self.errorMessage = "Ошибка экспорта учетных данных"
                @unknown default:
                    print("Unknown Apple Sign In error code")
                    self.errorMessage = "Неизвестная ошибка Apple Sign In"
                }
            } else {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

extension AppleSignInManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window
        }
        // Fallback for older iOS versions
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window
        }
        return ASPresentationAnchor()
    }
}
