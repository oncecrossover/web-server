//
//  UserFollow.swift
//  Snoop
//
//  Created by Bingo Zhou on 11/13/17.
//  Copyright © 2017 Vinsider Inc. All rights reserved.
//

import Foundation

class UserFollow {
  fileprivate var generics = Generics()
  fileprivate var FOLLOW_URI: String

  init() {
    FOLLOW_URI = self.generics.HTTPHOST + "follows"
  }

  func createUserFollow(_ uid: String, followeeId: String, followed: String, completion: @escaping (String) ->()) {
    let jsonData : [String: AnyObject] = ["uid" : uid as AnyObject, "followeeId": followeeId as AnyObject, "followed": followed as AnyObject]
    generics.createObject(FOLLOW_URI, jsonData: jsonData) {
      completion($0)
    }
  }

  func getUserFollows(_ filterString: String, completion: @escaping (NSArray) -> ()) {
    let myUrl: URL! = URL(string: FOLLOW_URI + "?" + filterString)
    generics.getFilteredObjects(myUrl) {
      completion($0)
    }
  }

  private func getFollowCount(_ filterString: String, completion: @escaping (Int) -> ()) {
    getUserFollows(filterString) {
      jsonArray in

      var result = 0
      for _ in jsonArray as! [[String:AnyObject]] {
        result += 1
      }
      completion(result)
    }
  }

  func getUserFollowingByUid(_ uid: String, completion: @escaping (Int) -> ()) {
    let filterString = "uid=\(uid)&followed='TRUE'"
    getFollowCount(filterString) {
      result in
      completion(result)
    }
  }

  func getUserFollowersByUid(_ uid: String, completion: @escaping (Int) -> ()) {
    let filterString = "followeeId=\(uid)&followed='TRUE'"
    getFollowCount(filterString) {
      result in
      completion(result)
    }
  }
}
