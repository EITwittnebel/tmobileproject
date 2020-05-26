//
//  AFManager.swift
//  TmobileAssign
//
//  Created by John Wittnebel on 5/26/20.
//  Copyright © 2020 John Wittnebel. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum GithubErrors: Error {
  case badURL
  case badCredentials
  case dataLimitReached
  case badData
  case noConnection
  case something
}

struct URLStrings {
  static let login = "https://api.github.com/"
  static let detailBase = "https://api.github.com/users/"
  static let basicBase = "https://api.github.com/search/users?q="
  static let repoBase = "https://api.github.com/users/"
}

final class AFManager {
  
  static var shared = AFManager()
  private var credentials: Credentials?
  
  private init() { }
  
  func getCredentials() -> Credentials? {
    return self.credentials
  }
  
  func login(userName: String, password: String, completion: @escaping (_ result: Result<Credentials?, GithubErrors>) -> ()) {
    let headers: HTTPHeaders = [.authorization(username: userName, password: password)]
    
    AF.request(URLStrings.login, headers: headers).responseJSON { response in
      let json: JSON = JSON(response.data as Any)
      
      if (json["message"].stringValue == "Bad credentials") {
        completion(.failure(.badCredentials))
      } else {
        self.credentials = Credentials(username: userName, password: password)
        completion(.success(nil))
      }
    }
  }
  
  func getUserInfo(name: String, completion: @escaping (_ result: Result<MoreInfo, GithubErrors>) -> ()) {
    let urlString: String = URLStrings.detailBase + name
    let headers: HTTPHeaders = [.authorization(username: self.credentials?.username ?? "", password: self.credentials?.password ?? "")]
    
    AF.request(urlString, headers: headers).responseJSON { response in
      let json: JSON = JSON(response.data as Any)
      if (json["message"].stringValue != "") {
        completion(.failure(.dataLimitReached))
      }
      let userMoreInfo = MoreInfo(followers: json["followers"].stringValue, following: json["following"].stringValue, numRepos: json["public_repos"].stringValue, joinDate: json["created_at"].stringValue, email: json["email"].stringValue, bio: json["bio"].stringValue, location: json["location"].stringValue)
      completion(.success(userMoreInfo))
      
    }
  }
  
  func basicInfoPull(searchQuery: String, completion: @escaping (_ result: Result<[UserData], GithubErrors>) -> ()) {
    let urlString: String = URLStrings.basicBase + searchQuery
    let headers: HTTPHeaders = [.authorization(username: self.credentials?.username ?? "", password: self.credentials?.password ?? "")]
    
    AF.request(urlString, headers: headers).responseJSON { response in
      if let error = response.error {
        print(error.errorDescription ?? "")
        completion(.failure(.something))
      }
      
      let json: JSON = JSON(response.data as Any)
      let userArr: [JSON] = json["items"].arrayValue
      var returnArr: [UserData] = []
      for user in userArr {
        let username: String = user["login"].stringValue
        let avatarURL: String = user["avatar_url"].stringValue
        let userBasicInfo: BasicInfo = BasicInfo(name: username, avatarImageURL: avatarURL)
        returnArr.append(UserData(basicData: userBasicInfo, moreData: nil, repos: []))
      }
      completion(.success(returnArr))
    }
  }
  
  func getImage(imageURL: String, completion: @escaping (_ result: Result<UIImage, GithubErrors>) -> ()) {
    
    let headers: HTTPHeaders = [.authorization(username: self.credentials?.username ?? "", password: self.credentials?.password ?? "")]
    
    AF.request(imageURL, headers: headers).responseJSON { response in
      guard let imageData = response.data else {
        completion(.failure(.badData))
        return
      }
      guard let image = UIImage(data: imageData) else {
        completion(.failure(.badData))
        return
      }
      completion(.success(image))
    }
  }
  
  func getRepos(name: String, completion: @escaping (_ result: Result<[Repo], GithubErrors>) -> ()) {
    let urlString = URLStrings.repoBase + name + "/repos"
    let headers: HTTPHeaders = [.authorization(username: self.credentials?.username ?? "", password: self.credentials?.password ?? "")]
    AF.request(urlString, headers: headers).responseJSON { response in
      let json: JSON = JSON(response.data as Any)
      let repoArr = json.arrayValue
      var retArr: [Repo] = []
      for repo in repoArr {
        retArr.append(Repo(name: repo["name"].stringValue, numStars: repo["stargazers_count"].stringValue, numForks: repo["forks_count"].stringValue))
      }
      completion(.success(retArr))
    }
  }
  
}

//class someVM {
//
//    var credentials: Credentials {
//        didSet {
//            self.update?()
//        }
//    }
//
//    var update: (() -> ())?
//
//    init(creds: Credentials) {
//        self.credentials = creds
//
//    }
//
//    func login () {
//        AFManager.shared.login(userName: "", password: "") { result in
//            switch result {
//            case .success(let creds):
//                self.credentials = creds ?? <#default value#>
//            case .failure(let error):
//                print("")
//            }
//        }
//    }
//
//}

