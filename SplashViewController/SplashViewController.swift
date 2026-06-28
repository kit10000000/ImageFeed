import UIKit

final class SplashViewController: UIViewController {

    // MARK: - Private Properties

    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage.shared

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .splashScreenLogo)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
        setupConstraints()
        checkAuthStatus()
    }

    // MARK: - Methods

    func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")

        window.rootViewController = tabBarController
    }

    // MARK: - Private Methods

    private func checkAuthStatus() {
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            showAuthViewController()
        }
    }

    private func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
        authViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypBlack)
        view.addSubview(iconImageView)
    }

    private func showProfileLoadError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось загрузить профиль",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default) { [weak self] _ in
            self?.storage.token = nil
            self?.showAuthViewController()
        })
        present(alert, animated: true)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        guard let token = storage.token else { return }
        fetchProfile(token: token)
    }

    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self else { return }

            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
            case .failure(let error):
                print("[SplashViewController]: Ошибка загрузки профиля — \(error.localizedDescription)")
                self.showProfileLoadError()
            }
        }
    }
}
