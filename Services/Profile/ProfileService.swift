import Foundation

final class ProfileService {

    // MARK: - Constants

    static let shared = ProfileService()

    // MARK: - Properties

    private(set) var profile: Profile?

    // MARK: - Private Properties

    private let urlSession = URLSession.shared
    private let jsonDecoder = JSONDecoder()
    private var task: URLSessionTask?

    // MARK: - Initializers

    private init() {}

    // MARK: - Methods

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()

        guard let request = createProfileRequest(token: token) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        var task: URLSessionTask?
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            
            guard let self else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
            guard self.task === task else { return }
            
            switch result {
            case .success(let data):
                let profile = Profile(result: data)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService]: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self.task = nil
        }
        
        guard let task else { return }
        self.task = task
        task.resume()
    }

    // MARK: - Private Methods

    private func createProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "\(Constants.defaultBaseURLString)/me") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
