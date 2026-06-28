import Foundation

final class ProfileImageService {

    // MARK: - Constants

    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    // MARK: - Properties

    private(set) var avatarURL: String?

    // MARK: - Private Properties

    private let urlSession = URLSession.shared
    private let jsonDecoder = JSONDecoder()
    private var task: URLSessionTask?

    // MARK: - Initializers

    private init() {}

    // MARK: - Methods

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()

        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
            return
        }

        guard let request = createProfileImageRequest(username: username, token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var task: URLSessionTask?
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            guard self.task === task else { return }
            switch result {
            case .success(let data):
                let userResult = data.profileImage
                self.avatarURL = userResult.large
                completion(.success(userResult.large))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": self.avatarURL ?? ""])
            case .failure(let error):
                print("[ProfileImageService]: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        guard let task else { return }
        self.task = task
        task.resume()
    }

    // MARK: - Private Methods

    private func createProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "\(Constants.defaultBaseURLString)/users/\(username)") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
