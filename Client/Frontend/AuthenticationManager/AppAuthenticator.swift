// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import LocalAuthentication
import WebKit

enum AuthenticationError: Error {
    case failedEvaluation(message: String)
    case failedAutentication(message: String)
}

/// `ProtectedScreen` signifies any screen in the app that needs biometric authentication to view it.
///
/// This is typically used in conjunction with `AppAuthenticator`.
enum ProtectedScreen {
    case editCreditCard, password
}

protocol AppAuthenticationProtocol {
    func authenticateWithDeviceOwnerAuthentication(screen: ProtectedScreen,
                                                   _ completion: @escaping (Result<Void, AuthenticationError>) -> Void)
    func canAuthenticateDeviceOwner() -> Bool
}

class AppAuthenticator: AppAuthenticationProtocol {
    func authenticateWithDeviceOwnerAuthentication(screen: ProtectedScreen,
                                                   _ completion: @escaping (Result<Void, AuthenticationError>) -> Void) {
        // Get a fresh context for each login. If you use the same context on multiple attempts
        //  (by commenting out the next line), then a previously successful authentication
        //  causes the next policy evaluation to succeed without testing biometry again.
        //  That's usually not what you want.
        let context = LAContext()

        context.localizedFallbackTitle = .AuthenticationEnterPasscode

        let authReasonString = getAuthenticationReasonFor(screen: screen, with: context.biometryType)

        // First check if we have the needed hardware support.
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: authReasonString) { success, error in
                if success {
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(.failedAutentication(message: error?.localizedDescription ?? "Failed to authenticate")))
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(.failure(.failedEvaluation(message: error?.localizedDescription ?? "Can't evaluate policy")))
            }
        }
    }

    func canAuthenticateDeviceOwner() -> Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }

    private func getAuthenticationReasonFor(screen: ProtectedScreen, with context: LABiometryType) -> String {
        var authReason = ""

        switch (screen, context) {
        case (.editCreditCard, .touchID):
            authReason = .Biometry.Screen.EditCreditCardWithFingerprint
        case (.editCreditCard, .faceID):
            authReason = .Biometry.Screen.EditCreditCardWithFaceId
        case (.password, .touchID):
            authReason = .Biometry.Screen.PasswordsWithFingerprint
        case (.password, .faceID):
            authReason = .Biometry.Screen.PasswordsWithFaceId

        default: break
        }

        return authReason
    }
}
