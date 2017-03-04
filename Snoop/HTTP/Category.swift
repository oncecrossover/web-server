//
//  Category.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/24/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation

class Category {
  private var generics = Generics()
  private var CATEGORYURI: String
  private var CATMAPPINGURI: String

  init() {
    CATEGORYURI = self.generics.HTTPHOST + "categories"
    CATMAPPINGURI = self.generics.HTTPHOST + "catmappings"
  }

  func updateInterests(uid: String, interests: [[String: AnyObject]], completion: (String) -> ()) {
    let url = NSURL(string: CATMAPPINGURI + "/" + uid)!
    generics.updateObjects(url, jsonData: interests) { result in
      completion(result)
    }
  }

  func getCategories(completion: (NSArray) -> ()) {
    let urlString = CATEGORYURI + "?name='%25%25'"
    let url = NSURL(string: urlString)!
    generics.getFilteredObjects(url) { result in
      completion(result)
    }
  }

  func getExpertise(completion: (NSArray) -> ()) {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    let url = NSURL(string: CATMAPPINGURI + "?uid='" + uid + "'&isExpertise='Yes'")!
    generics.getFilteredObjects(url) { result in
      completion(result)
    }
  }

  func getInterest(completion: (NSArray) -> ()) {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    let url = NSURL(string: CATMAPPINGURI + "?uid='" + uid + "'&isInterest='Yes'")!
    generics.getFilteredObjects(url) { result in
      completion(result)
    }
  }
}
