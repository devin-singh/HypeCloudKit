//
//  SignUpViewController.swift
//  HypeCloudKit
//
//  Created by Devin Singh on 2/6/20.
//  Copyright © 2020 Devin Singh. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var signUpTexField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
    }
    
    // MARK: - Actions
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        guard let username = signUpTexField.text, !username.isEmpty else { return }
        UserController.shared.createUser(withUsername: username) { (result) in
            switch result {
            case .success(let user):
                UserController.shared.currentUser = user
                self.presentHypeListVC()
            case .failure(let error):
                print(error.errorDescription ?? error.localizedDescription)
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func fetchUser() {
        UserController.shared.fetchUser { (result) in
            switch result {
            case .success(let currentUser):
                UserController.shared.currentUser = currentUser
                self.presentHypeListVC()
                print(currentUser != nil)
            case .failure(let error):
                print(error, error.localizedDescription)
            }
        }
    }
    
    private func presentHypeListVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "HypeList", bundle: nil)
            guard let viewController = storyboard.instantiateInitialViewController() else { return }
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        }
    }
}
