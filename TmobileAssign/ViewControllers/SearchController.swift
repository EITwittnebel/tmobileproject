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
  var currentRequest: DispatchWorkItem?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    gitUsers.dataSource = self
    gitUsers.delegate = self
    searchBar.delegate = self
    searchBar.becomeFirstResponder()
  }
  
  required init?(coder: NSCoder) {
    myInfo = []
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
    let name = myInfo[indexPath.row].basicData?.name ?? "loading..."
    cellvalue.nameLabel.text = name
    cellvalue.numReposLabel.text = "Number of public repos: \(myInfo[indexPath.row].moreData?.numRepos ?? "loading...")"
    if let imageURL = self.myInfo[indexPath.row].basicData?.avatarImageURL {
      cellvalue.avatarImage.image = nil
      AFManager.shared.getImage(imageURL:imageURL,
                                key: self.myInfo[indexPath.row].basicData?.name) { [name] (result) in
                                  guard self.myInfo.count > indexPath.row, self.myInfo[indexPath.row].basicData?.name == name else { return }
                                  if case .success(let image) = result {
                                    self.myInfo[indexPath.row].basicData?.avatarImage = image
                                    cellvalue.avatarImage.image = self.myInfo[indexPath.row].basicData?.avatarImage
                                  } else {
                                    cellvalue.avatarImage.image = nil
                                  }
      }
    }
    return cellvalue
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    gitUsers.deselectRow(at: indexPath, animated: true)
  }
  
  func getMoreInfo(forItemAt index: Int, completion: @escaping ()->Void) {
    guard let name = myInfo[index].basicData?.name else {
      completion()
      return
    }
    AFManager.shared.getUserInfo(name: name) { result in
      switch result {
      case .success(let info):
        guard self.myInfo.count > index, self.myInfo[index].basicData?.name == name else { return }
        self.myInfo[index].moreData = info
      case .failure(let error):
        self.presentErrorAlert(error: error)
      }
      completion()
    }
  }
}

extension SearchController: UISearchBarDelegate {

  func downloadImage(forItemAt index: Int) {
    guard let imageURL = myInfo[index].basicData?.avatarImageURL else { return }
    
    AFManager.shared.getImage(imageURL: imageURL,
                              key: self.myInfo[index].basicData?.name) { result in
      switch result {
      case .success(let image):
        self.myInfo[index].basicData?.avatarImage = image
        DispatchQueue.main.async {
          self.gitUsers.reloadData()
        }
      case .failure(let error):
        self.presentErrorAlert(error: error)
      }
    }
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    currentRequest?.cancel()
    let request = DispatchWorkItem {
      AFManager.shared.basicInfoPull(searchQuery: searchText) { result in
        switch result {
        case .success(let basicInfo):
          self.myInfo = basicInfo
          let group = DispatchGroup()
          for index in 0..<self.myInfo.count {
            group.enter()
            self.getMoreInfo(forItemAt: index) {
              group.leave()
            }
          }
          group.notify(queue: .main) {
              self.gitUsers.reloadData()
          }
        case .failure(let error):
          self.presentErrorAlert(error: error)
        }
      }
    }
    currentRequest = request
    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.4, execute: request)
  }
  
}
