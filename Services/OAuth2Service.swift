import Foundation

final class OAuth2Service {

    // MARK: - Constants

    static let shared = OAuth2Service()

    // MARK: - Private Properties

    private let jsonDecoder = JSONDecoder()

    // MARK: - Initializers

    private init() {}

    // MARK: - Methods

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = createOAuthTokenRequest(code: code) else {
            print("Ошибка: не удалось создать URLRequest")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try self.jsonDecoder.decode(OAuthTokenResponseBody.self, from: data)
                    OAuth2TokenStorage().token = response.accessToken
                    completion(.success(response.accessToken))
                } catch {
                    print("Ошибка декодирования: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .httpStatusCode(let code):
                        print("Ошибка сервера Unsplash, HTTP код: \(code)")
                    case .urlRequestError(let error):
                        print("Сетевая ошибка: \(error)")
                    case .urlSessionError:
                        print("Ошибка URLSession")
                    default:
                        break
                    }
                }
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // MARK: - Private Methods

    private func createOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("Ошибка: не удалось создать URLComponents")
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
            print("Ошибка: не удалось создать URL")
            return nil
        }

        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
}
