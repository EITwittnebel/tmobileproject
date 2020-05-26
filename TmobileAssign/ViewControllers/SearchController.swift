//
//  ViewController.swift
//  TmobileAssign
//
//  Created by John Wittnebel on 5/23/20.
//  Copyright © 2020 John Wittnebel. All rights reserved.
//

import UIKit
import Alamofire

class SearchController: UIViewController {
  
  @IBOutlet weak var loginButton: UIBarButtonItem!
  @IBOutlet weak var gitUsers: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  var myInfo: [UserData]
  var newAPIRequest: Int
  
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
      dest.info = myInfo[indexPath?.row ?? 0]
    }
  }
}

extension SearchController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return myInfo.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "userCell")
    guard let cellvalue = cell else {
      return UITableViewCell()
    }
    
    if (indexPath.row >= myInfo.count) {
      return cellvalue
    }
    
    if let label = cellvalue.viewWithTag(1001) as? UILabel {
      let temptext = myInfo[indexPath.row].moreData?.numRepos ?? "loading..."
      label.text = "Number of public repos: \(temptext)"
    }
    
    if let label = cellvalue.viewWithTag(1000) as? UILabel {
      label.text = myInfo[indexPath.row].basicData?.name ?? "loading..."
    }
    
    if let avatar = cellvalue.viewWithTag(999) as? UIImageView {
      avatar.image = myInfo[indexPath.row].basicData?.avatarImage
    }
    
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
        print(error)
        let alert = UIAlertController(title: "Rate Limited", message: "You have been rate limited, please login to substantially increase rate limit. You will only be able to see usernames and avatars for the next hour otherwise.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in self.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true)
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
        
        DispatchQueue.main.async {
          self.gitUsers.reloadData()
        }
      case .failure(let error):
        print(error)
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
              self.downloadImage(forItemAt: index)
            }
          case .failure(let error):
            print(error.localizedDescription)
          }
        }
      }
    })
  }
  
}
