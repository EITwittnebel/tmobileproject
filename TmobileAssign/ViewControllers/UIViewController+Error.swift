//
//  UIViewController+Error.swift
//  TmobileAssign
//
//  Created by John Wittnebel on 5/25/20.
//  Copyright © 2020 John Wittnebel. All rights reserved.
//

import UIKit

extension UIViewController {
  
  private static var isShowingError: Bool = false
  
  func presentErrorAlert(title: String, message: String) {
    if UIViewController.isShowingError == true { return }
    UIViewController.isShowingError.toggle()
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(alert, animated: true)
  }
  
  func presentErrorAlert(error: GithubErrors) {
    switch error {
    case .other:
      self.presentErrorAlert(title: "Unknown Error", message: "An unknown error has occurred.")
    case .noConnection:
      self.presentErrorAlert(title: "No Connection", message: "Could not establish a connection, please check your internet connection.")
    case .badData:
      self.presentErrorAlert(title: "Bad Image Data", message: "Avatar image was invalid.")
    default:
      self.presentErrorAlert(title: "Rate Limited", message: "You have been rate limited, please login to substantially increase rate limit. You will only be able to see usernames and avatars for the next hour otherwise.")
    }
  }
}
