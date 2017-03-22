//
//  Payment.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/23/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation

class Payment {

  fileprivate var PAYMENTURI: String
  fileprivate var BALANCEURI: String
  fileprivate var generics = Generics()

  init(){
    PAYMENTURI = generics.HTTPHOST + "pcentries"
    BALANCEURI = generics.HTTPHOST + "balances/"
  }

  func createPayment(_ token: String!, completion: @escaping (String) ->()) {
    let uid = UserDefaults.standard.string(forKey: "email")

    let jsonData = ["uid" : uid as AnyObject, "token" : token as AnyObject]
    generics.createObject(PAYMENTURI, jsonData: jsonData) { result in
      completion(result)
    }
  }

  func getPayments(_ filterString: String!, completion: @escaping (NSArray) -> ()) {
    let url = URL(string: PAYMENTURI + "?filter=" + filterString)
    generics.getFilteredObjects(url!) { result in
      completion(result)
    }
  }

  func getBalance(_ uid: String!, completion: @escaping (NSDictionary) -> ()) {
    let url = URL(string: BALANCEURI + uid)!
    generics.getObjectById(url) { result in
      completion(result)
    }
  }

  func deletePayment(_ id: Int, completion: @escaping (String) -> ()) {
    let url = URL(string: PAYMENTURI + "/" + "\(id)")
    let request = NSMutableURLRequest(url: url!)
    request.httpMethod = "DELETE"
    let session = generics.getURLSession()
    let task = session.dataTask(with: request as URLRequest) {
      data, response, error in
      if (error != nil)
      {
        print("error=\(error)")
        return
      }

      completion("")

    }
    task.resume()
  }
}
