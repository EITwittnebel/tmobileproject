//
//  LoginController.swift
//  TmobileAssign
//
//  Created by John Wittnebel on 5/25/20.
//  Copyright © 2020 John Wittnebel. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

class LoginController: UIViewController {
  
  var credentials: Credentials?
  @IBOutlet weak var userField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBAction func loginButton(_ sender: Any) {
    validateCredentials()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func validateCredentials() {
    if (userField.text! == "" || passwordField.text! == "") {
      let alert = UIAlertController(title: "Invalid Credentials", message: "Please try again.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
      self.present(alert, animated: true)
      return
    }
    
    let urlString: String = "https://api.github.com/"
    let headers: HTTPHeaders = [.authorization(username: userField.text!, password: passwordField.text!)]
    
    AF.request(urlString, headers: headers).responseJSON { response in
      let json: JSON = JSON(response.data as Any)
      if (json["message"].stringValue == "Bad credentials") {
        let alert = UIAlertController(title: "Invalid Credentials", message: "Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
      } else {
        self.credentials?.username = self.userField!.text!
        self.credentials?.password = self.passwordField!.text!
        self.dismiss(animated: true, completion: nil)
      }
    }
  }
  
}
