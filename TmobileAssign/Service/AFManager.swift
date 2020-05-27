//
//  AFManager.swift
//  TmobileAssign
//
//  Created by John Wittnebel on 5/26/20.
//  Copyright © 2020 John Wittnebel. All rights reserved.
//

import Alamofire
import SwiftyJSON

enum GithubErrors: Error {
  case badURL
  case badCredentials
  case dataLimitReached
  case badData
  case noConnection
  case other(Error)
}

enum URLStrings {
  static let login = "https://api.github.com/"
  static let detailBase = "https://api.github.com/users/"
  static let basicBase = "https://api.github.com/search/users?q="
  static let repoBase = "https://api.github.com/users/"
}

final class AFManager {
  
  static var shared = AFManager()
  private var credentials: Credentials?
  private var basicHeaders: HTTPHeaders {
    guard let credentials = credentials else {
      return [.authorization(username: "", password: "")]
    }
    return [.authorization(username: credentials.username, password: credentials.password)]
  }
  private let cache = NSCache<NSString, UIImage>()
  
  private init() { }
  
  private func request(_ url: URLConvertible,
                       _ responseHandler: @escaping (AFDataResponse<Any>) -> Void,
                       _ errorCompletion: @escaping (GithubErrors) -> Void) {
    AF.request(url, headers: basicHeaders).responseJSON { response in
      if let error = response.error {
        if (error.localizedDescription == "The Internet connection appears to be offline.") {
          errorCompletion(.noConnection)
        } else {
          errorCompletion(.other(error))
        }
        return
      }
      responseHandler(response)
    }
  }
  
  func login(userName: String, password: String, completion: @escaping (_ result: Result<Credentials?, GithubErrors>) -> ()) {
    credentials = Credentials(username: userName, password: password)
    request(URLStrings.login, { response in
      let json: JSON = JSON(response.data as Any)
        if (json["message"].stringValue == "Bad credentials") {
          self.credentials = nil
          completion(.failure(.badCredentials))
        } else {
          completion(.success(nil))
        }
      }) {
        self.credentials = nil
        completion(.failure($0))
      }
    }
  
  func getUserInfo(name: String, completion: @escaping (_ result: Result<MoreInfo, GithubErrors>) -> ()) {
    let urlString: String = URLStrings.detailBase + name
    request(urlString, { response in
      let json: JSON = JSON(response.data as Any)
      if (json["message"].stringValue != "") {
        completion(.failure(.dataLimitReached))
        return
      }
      let userMoreInfo = MoreInfo(followers: json["followers"].stringValue, following: json["following"].stringValue, numRepos: json["public_repos"].stringValue, joinDate: json["created_at"].stringValue, email: json["email"].stringValue, bio: json["bio"].stringValue, location: json["location"].stringValue)
      completion(.success(userMoreInfo))
      
    }) {
      completion(.failure($0))
    }
  }
  
  func basicInfoPull(searchQuery: String, completion: @escaping (_ result: Result<[UserData], GithubErrors>) -> ()) {
    let urlString: String = URLStrings.basicBase + searchQuery
    
    request(urlString, { response in
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
    }) {
      completion(.failure($0))
    }
  }
  
  func getImage(imageURL: String, key: String? = nil, completion: @escaping (_ result: Result<UIImage, GithubErrors>) -> ()) {
    AF.request(imageURL, headers: basicHeaders).responseData { response in
      if let error = response.error {
        if (error.localizedDescription == "The Internet connection appears to be offline.") {
          completion(.failure(.noConnection))
        } else {
          completion(.failure(.other(error)))
        }
        return
      }
      guard let imageData = response.data else {
        completion(.failure(.badData))
        return
      }
      guard let image = UIImage(data: imageData) else {
        completion(.failure(.badData))
        return
      }
      if let key = key as NSString? {
        self.cache.setObject(image, forKey: key)
      }
      completion(.success(image))
    }
  }
  
  func getRepos(name: String, completion: @escaping (_ result: Result<[Repo], GithubErrors>) -> ()) {
    let urlString = URLStrings.repoBase + name + "/repos"
    request(urlString, { response in
      let json: JSON = JSON(response.data as Any)
      let repoArr = json.arrayValue
      var retArr: [Repo] = []
      for repo in repoArr {
        retArr.append(Repo(name: repo["name"].stringValue, numStars: repo["stargazers_count"].stringValue, numForks: repo["forks_count"].stringValue))
      }
      completion(.success(retArr))
    }) {
      completion(.failure($0))
    }
  }
  
}
