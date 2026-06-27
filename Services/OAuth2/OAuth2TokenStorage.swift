import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {

    // MARK: - Constants

    static let shared = OAuth2TokenStorage()

    // MARK: - Properties

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }

    // MARK: - Private Properties

    private let tokenKey = "token"

    // MARK: - Initializers

    private init() {}
}
