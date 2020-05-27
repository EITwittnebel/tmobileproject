//
//  ViewController.swift
//  TmobileAssign
//
//  Created by John Wittnebel on 5/23/20.
//  Copyright © 2020 John Wittnebel. All rights reserved.
//

import UIKit

class SearchController: UIViewController {
  
  @IBOutlet weak var loginButton: UIBarButtonItem!
  @IBOutlet weak var gitUsers: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  var myInfo: [UserData]
  var newAPIRequest: Int
  let cache = NSCache<NSString, UIImage>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    gitUsers.dataSource = self
    gitUsers.delegate = self
    searchBar.delegate = self
    searchBar.becomeFirstResponder()
  }
  
  required init?(coder: NSCoder) {
    myInfo = []
    newAPIRequest = 0
    super.init(coder: coder)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let dest = segue.destination as? DetailViewController {
      guard let cell = sender as? UITableViewCell else { return }
      let indexPath = gitUsers.indexPath(for: cell)
      if let path = indexPath?.row {
        dest.info = myInfo[path]
      } else {
        dest.info = UserData(basicData: nil, moreData: nil, repos: [])
      }
    }
  }
}

extension SearchController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return myInfo.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserSearchCell
    guard let cellvalue = cell else { return UITableViewCell() }
    guard (indexPath.row < myInfo.count) else {
      return cellvalue
    }
    cellvalue.nameLabel.text = myInfo[indexPath.row].basicData?.name ?? "loading..."
    cellvalue.numReposLabel.text = "Number of public repos: \(myInfo[indexPath.row].moreData?.numRepos ?? "loading...")"
    cellvalue.avatarImage.image = myInfo[indexPath.row].basicData?.avatarImage
    
    return cellvalue
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    gitUsers.deselectRow(at: indexPath, animated: true)
  }
  
  func getMoreInfo(forItemAt index: Int) {
    guard let name = myInfo[index].basicData?.name else { return }
    
    AFManager.shared.getUserInfo(name: name) { result in
      switch result {
      case .success(let info):
        guard self.myInfo.count > index else { return }
        self.myInfo[index].moreData = info
        DispatchQueue.main.async {
          self.gitUsers.reloadData()
        }
      case .failure(let error):
        if (error == .other) {
          self.presentErrorAlert(title: "Unknown Error", message: "An unknown error has occurred.")
        } else if (error == .noConnection) {
          self.presentErrorAlert(title: "No Connection", message: "Could not establish a connection, please check your internet connection.")
        } else {
          self.presentErrorAlert(title: "Rate Limited", message: "You have been rate limited, please login to substantially increase rate limit. You will only be able to see usernames and avatars for the next hour otherwise.")
        }
      }
    }
  }
  
}

extension SearchController: UISearchBarDelegate {

  func downloadImage(forItemAt index: Int) {
    guard let imageURL = myInfo[index].basicData?.avatarImageURL else { return }
    
    AFManager.shared.getImage(imageURL: imageURL) { result in
      switch result {
      case .success(let image):
        self.myInfo[index].basicData?.avatarImage = image
        let imageToCache = self.myInfo[index].basicData?.avatarImage
        self.cache.setObject(imageToCache ?? UIImage(), forKey: self.myInfo[index].basicData?.name as NSString? ?? "")
        
        DispatchQueue.main.async {
          self.gitUsers.reloadData()
        }
      case .failure(let error):
        if (error == .noConnection) {
          self.presentErrorAlert(title: "No Connection", message: "Could not establish a connection, please check your internet connection.")
        } else if (error == .badData) {
          self.presentErrorAlert(title: "Bad Image Data", message: "Avatar image was invalid.")
        }
      }
    }
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    newAPIRequest += 1
    Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: { time in
      self.newAPIRequest -= 1
      if self.newAPIRequest > 0 {
        // search bar was edited, dont bother doing the previous api call
        return
      } else {
        AFManager.shared.basicInfoPull(searchQuery: searchText) { result in
          switch result {
          case .success(let basicInfo):
            self.myInfo = basicInfo
            for index in 0..<self.myInfo.count {
              self.getMoreInfo(forItemAt: index)
              if let cachedImage = self.cache.object(forKey: self.myInfo[index].basicData?.name as NSString? ?? "" as NSString) {
                self.myInfo[index].basicData?.avatarImage = cachedImage
              } else {
                self.downloadImage(forItemAt: index)
              }
            }
          case .failure(let error):
            if (error == .other) {
              self.presentErrorAlert(title: "Unknown Error", message: "An unknown error has occurred.")
            } else if (error == .noConnection) {
              self.presentErrorAlert(title: "No Connection", message: "Could not establish a connection, please check your internet connection.")
            }
          }
        }
      }
    })
  }
 
  private func presentErrorAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(alert, animated: true)
  }
  
}
