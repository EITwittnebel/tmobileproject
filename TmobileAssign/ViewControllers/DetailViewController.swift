//
//  DetailView.swift
//  TmobileAssign
//
//  Created by John Wittnebel on 5/24/20.
//  Copyright © 2020 John Wittnebel. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

class DetailViewController: UIViewController {
  
  var info: UserData?
  var reposToDisplay: [Repo]?
  var credentials: Credentials?
  
  @IBOutlet weak var emailLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var joinDateLabel: UILabel!
  @IBOutlet weak var followersLabel: UILabel!
  @IBOutlet weak var followingLabel: UILabel!
  @IBOutlet weak var bioLabel: UILabel!
  @IBOutlet weak var avatar: UIImageView!
  
  @IBOutlet weak var repoTable: UITableView!
  @IBOutlet weak var repoSearch: UISearchBar!
  
  override func viewDidLoad() {
    repoTable.delegate = self
    repoTable.dataSource = self
    repoSearch.delegate = self
    setupDisplay()
    getRepos()
    super.viewDidLoad()
  }
  
  func setupDisplay() {
    emailLabel.text = "Email: \(info?.moreData?.email ?? "")"
    locationLabel.text = "Location: \(info?.moreData?.location ?? "")"
    nameLabel.text = info?.basicData?.name
    followersLabel.text = "Followers: \(info?.moreData?.followers ?? "")"
    followingLabel.text = "Following: \(info?.moreData?.following ?? "")"
    bioLabel.text = "Bio: \(info?.moreData?.bio ?? "")"
    joinDateLabel.text = "Join Date: \(info?.moreData?.joinDate.split(separator: "T", maxSplits: 10, omittingEmptySubsequences: true)[0] ?? "")"
    avatar.image = info?.basicData?.avatarImage
  }
  
  func getRepos() {
    let urlString = "https://api.github.com/users/" + (info?.basicData!.name)! + "/repos"
    let headers: HTTPHeaders = [.authorization(username: credentials!.username, password: credentials!.password)]
    AF.request(urlString, headers: headers).responseJSON { response in
      let json: JSON = JSON(response.data as Any)
      let repoArr = json.arrayValue
      for repo in repoArr {
        self.info?.repos.append(Repo(name: repo["name"].stringValue, numStars: repo["stargazers_count"].stringValue, numForks: repo["forks_count"].stringValue))
      }
      self.reposToDisplay = self.info?.repos
      DispatchQueue.main.async {
        self.repoTable.reloadData()
      }
    }
  }
  
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return reposToDisplay?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = repoTable.dequeueReusableCell(withIdentifier: "repoCell")
    if reposToDisplay!.count <= indexPath.row { return cell! }
    
    if let label = cell!.viewWithTag(150) as? UILabel {
      label.text = reposToDisplay?[indexPath.row].name
    }
    
    if let label = cell!.viewWithTag(151) as? UILabel {
      label.text = "Forks: " + (reposToDisplay?[indexPath.row].numForks ?? "???")
    }
    
    if let label = cell!.viewWithTag(152) as? UILabel {
      label.text = "Stars: " + (reposToDisplay?[indexPath.row].numStars ?? "???")
    }
    
    return cell!
  }
 
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    repoTable.deselectRow(at: indexPath, animated: true)
    if let url = URL(string: "https://www.github.com/" + info!.basicData!.name + "/" + reposToDisplay![indexPath.row].name) {
        UIApplication.shared.open(url)
    }
  }
  
}

extension DetailViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if (searchText == "") {
      reposToDisplay = info?.repos
    } else {
      reposToDisplay = []
      for repo in info!.repos {
        if ((repo.name.range(of: searchText, options: String.CompareOptions.caseInsensitive, range: nil, locale: nil)) != nil) {
          reposToDisplay?.append(repo)
        }
      }
    }
    repoTable.reloadData()
  }
}
