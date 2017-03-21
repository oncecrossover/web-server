//
//  Category.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/24/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation

class Category {
  fileprivate var generics = Generics()
  fileprivate var CATEGORYURI: String
  fileprivate var CATMAPPINGURI: String

  init() {
    CATEGORYURI = self.generics.HTTPHOST + "categories"
    CATMAPPINGURI = self.generics.HTTPHOST + "catmappings"
  }

  func updateInterests(_ uid: String, interests: [[String: AnyObject]], completion: @escaping (String) -> ()) {
    let url = URL(string: CATMAPPINGURI + "/" + uid)!
    generics.updateObjects(url, jsonData: interests) { result in
      completion(result)
    }
  }

  func getCategories(_ completion: @escaping (NSArray) -> ()) {
    let urlString = CATEGORYURI + "?name='%25%25'"
    let url = URL(string: urlString)!
    generics.getFilteredObjects(url) { result in
      completion(result)
    }
  }

  func getExpertise(_ uid: String, completion: @escaping (NSArray) -> ()) {
    let url = URL(string: CATMAPPINGURI + "?uid='" + uid + "'&isExpertise='Yes'")!
    generics.getFilteredObjects(url) { result in
      completion(result)
    }
  }

  func getInterest(_ completion: @escaping (NSArray) -> ()) {
    let uid = UserDefaults.standard.string(forKey: "email")!
    let url = URL(string: CATMAPPINGURI + "?uid='" + uid + "'&isInterest='Yes'")!
    generics.getFilteredObjects(url) { result in
      completion(result)
    }
  }
}
