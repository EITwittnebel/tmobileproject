//
//  Data2.swift
//  TmobileAssign
//
//  Created by John Wittnebel on 5/23/20.
//  Copyright © 2020 John Wittnebel. All rights reserved.
//

import Foundation

struct MoreInfo {
  var followers: String
  var following: String
  var numRepos: String
  var joinDate: String
  var email: String
  var bio: String
  var location: String
  
  init(followers: String, following: String, numRepos: String, joinDate: String, email: String, bio: String, location: String) {
    if (followers == "") {
      self.followers = "???"
    } else {
      self.followers = followers
    }
    
    if (following == "") {
      self.following = "???"
    } else {
      self.following = following
    }
    
    if (numRepos == "") {
      self.numRepos = "???"
    } else {
      self.numRepos = numRepos
    }
    
    if (joinDate == "") {
      self.joinDate = "Not Available"
    } else {
      self.joinDate = joinDate
    }
    
    if (email == "") {
      self.email = "Not Available"
    } else {
      self.email = email
    }
    
    if (bio == "") {
      self.bio = "No Bio Written"
    } else {
      self.bio = bio
    }
    
    if (location == "") {
      self.location = "Not Available"
    } else {
      self.location = location
    }
  }
}
