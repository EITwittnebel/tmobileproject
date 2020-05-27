//
//  DetailView.swift
//  TmobileAssign
//
//  Created by John Wittnebel on 5/24/20.
//  Copyright © 2020 John Wittnebel. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
  
  var info: UserData?
  var reposToDisplay: [Repo] = []
  
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
    AFManager.shared.getRepos(name: (info?.basicData?.name ?? "")) { result in
      switch result {
      case .success(let repos):
        self.info?.repos = repos
        self.reposToDisplay = repos
        DispatchQueue.main.async {
          self.repoTable.reloadData()
        }
      case .failure(let error):
        self.presentErrorAlert(error: error)
      }
    }
  }
  
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return reposToDisplay.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = repoTable.dequeueReusableCell(withIdentifier: "repoCell") as? RepoTableCell
    guard let cellVal = cell else { return UITableViewCell() }
    cellVal.repoNameLabel.text = reposToDisplay[indexPath.row].name
    cellVal.numForksLabel.text = "Forks: " + (reposToDisplay[indexPath.row].numForks ?? "???")
    cellVal.numStarsLabel.text = "Stars: " + (reposToDisplay[indexPath.row].numStars ?? "???")
    
    return cellVal
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    repoTable.deselectRow(at: indexPath, animated: true)
    if let url = URL(string: "https://www.github.com/" + (info?.basicData?.name ?? "error") + "/" + (reposToDisplay[indexPath.row].name ?? "")) {
      UIApplication.shared.open(url)
    }
  }
  
}

extension DetailViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      reposToDisplay = info?.repos ?? []
    } else {
      reposToDisplay = []
      for repo in (info?.repos ?? []) {
        if ((repo.name.range(of: searchText, options: String.CompareOptions.caseInsensitive, range: nil, locale: nil)) != nil) {
          reposToDisplay.append(repo)
        }
      }
    }
    repoTable.reloadData()
  }
  
}
