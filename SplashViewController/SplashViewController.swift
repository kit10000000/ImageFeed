import UIKit

final class SplashViewController: UIViewController {

    // MARK: - Properties

    let showAuthenticationScreenSegueIdentifier = "showAuthenticationScreen"

    // MARK: - Private Properties

    private let storage = OAuth2TokenStorage()

    // MARK: - Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if storage.token != nil {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
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
}
