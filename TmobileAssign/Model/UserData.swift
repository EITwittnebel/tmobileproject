//
//  UserData.swift
//  TmobileAssign
//
//  Created by John Wittnebel on 5/23/20.
//  Copyright © 2020 John Wittnebel. All rights reserved.
//

import Foundation

class UserData {
  var basicData: BasicInfo?
  var moreData: MoreInfo?
  var repos: [Repo]
  
  init(basicData: BasicInfo?, moreData: MoreInfo?, repos: [Repo]) {
    self.basicData = basicData
    self.moreData = moreData
    self.repos = repos
  }
}
