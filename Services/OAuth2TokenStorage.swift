import Foundation

final class OAuth2TokenStorage {

    // MARK: - Properties

    var token: String? {
        get {
            storage.string(forKey: "bearerToken")
        }
        set {
            storage.set(newValue, forKey: "bearerToken")
        }
    }

    // MARK: - Private Properties

    private let storage: UserDefaults = .standard
}
