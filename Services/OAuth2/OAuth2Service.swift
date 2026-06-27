import Foundation

enum AuthServiceError: Error {
    case invalidRequest
    case missingToken
}

final class OAuth2Service {

    // MARK: - Constants

    static let shared = OAuth2Service()

    // MARK: - Properties

    private(set) var authToken: String? {
        get {
            dataStorage.token
        }
        set {
            dataStorage.token = newValue
        }
    }

    // MARK: - Private Properties

    private let urlSession = URLSession.shared
    private let dataStorage = OAuth2TokenStorage.shared
    private let jsonDecoder = JSONDecoder()
    private var task: URLSessionTask?
    private var lastCode: String?

    // MARK: - Initializers

    private init() {}

    // MARK: - Methods

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if self.task != nil {
            if lastCode != code {
                self.task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code

        guard let request = createOAuthTokenRequest(code: code) else {
            print("[OAuth2Service]: Ошибка — не удалось создать URLRequest")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            self.task = nil
            self.lastCode = nil
            switch result {
            case .success(let data):
                let accessToken = data.accessToken
                self.authToken = accessToken
                completion(.success(accessToken))
            case .failure(let error):
                print("[OAuth2Service]: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        self.task = task
        task.resume()
    }

    // MARK: - Private Methods

    private func createOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("[OAuth2Service]: Ошибка — не удалось создать URLComponents")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]

        guard let authTokenUrl = urlComponents.url else {
            print("[OAuth2Service]: Ошибка — не удалось создать URL")
            return nil
        }

        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
}
