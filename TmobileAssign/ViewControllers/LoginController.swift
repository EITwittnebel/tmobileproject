//
//  LoginController.swift
//  TmobileAssign
//
//  Created by John Wittnebel on 5/25/20.
//  Copyright © 2020 John Wittnebel. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
  
  @IBOutlet weak var userField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBAction func loginButton(_ sender: Any) {
    validateCredentials()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func validateCredentials() {
    guard let username = userField.text,
      username.isEmpty == false,
      let password = passwordField.text,
      password.isEmpty == false else {
      self.presentAlertController(title: "Empty Credentials", message: "Please try again.")
      return
    }
    AFManager.shared.login(userName: username, password: password) { result in
      switch result {
      case .failure(let error):
        print(error)
        self.presentAlertController(title: "Invalid Credentials", message: "Please try again.", error: error)
      case .success(_):
        self.presentAlertController(title: "Login Successful", message: "Logged in successfully.", error: nil)
      }
    }
  }
  
  private func presentAlertController(title: String, message: String, error: GithubErrors? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
      if error == nil {
        self.dismiss(animated: true, completion: nil)
      }
    }))
    self.present(alert, animated: true)
  }
  
}
