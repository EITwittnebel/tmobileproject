//
//  ViewController.swift
//  TmobileAssign
//
//  Created by John Wittnebel on 5/23/20.
//  Copyright © 2020 John Wittnebel. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class SearchController: UIViewController {

  @IBOutlet weak var loginButton: UIBarButtonItem!
  @IBOutlet weak var gitUsers: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  var myInfo: [UserData]
  var thingsToPrint: Int
  var credentials: Credentials?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    gitUsers.dataSource = self
    gitUsers.delegate = self
    searchBar.delegate = self
    searchBar.becomeFirstResponder()
  }
  
  required init?(coder: NSCoder) {
    myInfo = []
    thingsToPrint = 0
    credentials = Credentials(username: "", password: "")
    super.init(coder: coder)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let dest = segue.destination as? DetailViewController {
      let cell = sender as? UITableViewCell
      let indexPath = gitUsers.indexPath(for: cell!)
      dest.info = myInfo[indexPath!.row]
      dest.credentials = credentials
    }
    
    if let dest = segue.destination as? LoginController {
      dest.credentials = credentials
    }
  }
}

extension SearchController: UITableViewDelegate, UITableViewDataSource {
  
  func reloadTable() {
    gitUsers.reloadData()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return myInfo.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "userCell")
    
    if (indexPath.row >= myInfo.count) {
      return cell!
    }
    
    if let label = cell!.viewWithTag(1001) as? UILabel {
      let temptext = myInfo[indexPath.row].moreData?.numRepos ?? "loading..."
      label.text = "Number of public repos: \(temptext)"
      if (label.text == "") {
        label.text = "No bio written."
      }
    }
    
    if let label = cell!.viewWithTag(1000) as? UILabel {
      label.text = myInfo[indexPath.row].basicData?.name ?? "loading..."
      if (label.text == "") {
        label.text = "No bio written."
      }
    }
    
    if let avatar = cell!.viewWithTag(999) as? UIImageView {
      avatar.image = myInfo[indexPath.row].basicData?.avatarImage
    }
    
    let backup = UITableViewCell()
    backup.textLabel!.text = "error"
    return cell ?? backup
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    gitUsers.deselectRow(at: indexPath, animated: true)
  }
  
  func getMoreInfo(forItemAt index: Int) {
    let urlString: String = "https://api.github.com/users/" + myInfo[index].basicData!.name
    
    var headers: HTTPHeaders = [.authorization(username: "", password: "")]
    if let cred = credentials {
      if cred.username != "" {
        let user = cred.username
        let password = cred.password
        headers = [.authorization(username: user, password: password)]
      }
    }
    
    AF.request(urlString, headers: headers).responseJSON { response in
      if (self.myInfo.count <= index) { return }
      let json: JSON = JSON(response.data as Any)
      if (json["message"].stringValue != "") {
        let alert = UIAlertController(title: "Rate Limited", message: "You have been rate limited, please login to substantially increase rate limit. You will only be able to see usernames and avatars for the next hour otherwise.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in self.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true)
      }
      let userMoreInfo = MoreInfo(followers: json["followers"].stringValue, following: json["following"].stringValue, numRepos: json["public_repos"].stringValue, joinDate: json["created_at"].stringValue, email: json["email"].stringValue, bio: json["bio"].stringValue, location: json["location"].stringValue)
      self.myInfo[index].moreData = userMoreInfo
      DispatchQueue.main.async {
        self.gitUsers.reloadData()
      }
    }
  }
  
}

extension SearchController: UISearchBarDelegate {
  
  func populateBasicData(results: [JSON]) {
    for user in results {
      let username: String = user["login"].stringValue
      let avatarURL: String = user["avatar_url"].stringValue
      let userBasicInfo: BasicInfo = BasicInfo(name: username, avatarImageURL: avatarURL)
      myInfo.append(UserData(basicData: userBasicInfo, moreData: nil, repos: []))
    }
  }
  
  func downloadImage(forItemAt index: Int) {
    let picURL = URL(string: myInfo[index].basicData!.avatarImageURL)
    let session = URLSession(configuration: .default)
    let downloadPicTask = session.dataTask(with: picURL!) { (data, response, error) in
      if let imageData = data {
        let image = UIImage(data: imageData)
        self.myInfo[index].basicData?.avatarImage = image
      }
      
      DispatchQueue.main.async {
        self.gitUsers.reloadData()
      }
    }
    downloadPicTask.resume()
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    thingsToPrint += 1
    Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: { time in
      self.thingsToPrint -= 1
      if self.thingsToPrint > 0 {
        // search bar was editted, dont bother doing the pervious api call
        return
      } else {
        let urlString: String = "https://api.github.com/search/users?q=" + searchText
        let url: URL? = URL(string: urlString)
        
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
          if ((error) != nil) {
            print(error as Any)
          }
          let json: JSON = JSON(data!)
          let userArr: [JSON] = json["items"].arrayValue
          self.myInfo = []
          self.populateBasicData(results: userArr)
          
          for index in 0..<self.myInfo.count {
            self.getMoreInfo(forItemAt: index)
            self.downloadImage(forItemAt: index)
          }
          
        })
        task.resume()
      }
    })
  }
  
}
