import UIKit

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(_):
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                print("Ошибка авторизации: \(error)")
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
