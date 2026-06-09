//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Ekaterina on 03.06.2026.
//

import UIKit

final class ProfileViewController: UIViewController {

    @IBAction func didTapLogoutButton(_ sender: Any) {
    }
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nickLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}
