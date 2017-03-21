//
//  Generics.swift
//  Peeq
//
//  Created by Bowen Zhang on 8/8/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
class Generics: NSObject, URLSessionDelegate {
  var HTTPHOST = "http://www.snoopqa.com:8080/"
  override init() {
  }

  func getURLSession() -> Foundation.URLSession {
    let configuration =
      URLSessionConfiguration.default
    let session = Foundation.URLSession(configuration: configuration,
                               delegate: self,
                               delegateQueue: OperationQueue.main)
    return session
  }

  func urlSession(_ session: URLSession,  didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    let serverTrust = challenge.protectionSpace.serverTrust
    let certificate = SecTrustGetCertificateAtIndex(serverTrust!, 0)

    // Set SSL policies for domain name check
    let policies = NSMutableArray();
    policies.add(SecPolicyCreateSSL(true, (challenge.protectionSpace.host as CFString?)))
    SecTrustSetPolicies(serverTrust!, policies);

    // Evaluate server certificate
    /*var result = SecTrustResultType.Invalid
    SecTrustEvaluate(serverTrust!, &result)
    let isServerTrusted:Bool = (result == SecTrustResultType.Unspecified || result == SecTrustResultType.Proceed)
    if (result == SecTrustResultType.RecoverableTrustFailure) {
      let exception = SecTrustCopyExceptions(serverTrust!)
      SecTrustSetPolicies(serverTrust!, exception)
      SecTrustEvaluate(serverTrust!, &result)
    }
    print("result is \(result)")**/

    // Get local and remote cert data
    let remoteCertificateData:Data = SecCertificateCopyData(certificate!) as Data
    let pathToCert = Bundle.main.path(forResource: "snoop-server", ofType: "der")
    let localCertificate:Data = try! Data(contentsOf: URL(fileURLWithPath: pathToCert!))

    if (remoteCertificateData == localCertificate) {
        let credential:URLCredential = URLCredential(trust: serverTrust!)
        completionHandler(.useCredential, credential)
    } else {
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
  }

  func createObject(_ URI: String, jsonData: [String:AnyObject], completion: @escaping (String) -> ()) {
    let myUrl = URL(string: URI);
    let request = NSMutableURLRequest(url:myUrl!);
    request.httpMethod = "POST";

    do {
      request.httpBody =  try JSONSerialization.data(withJSONObject: jsonData, options: [])
    }
    catch {
      print("error=\(error)")
      completion("an error occurs when creating object: \(error)")
    }
    let session = self.getURLSession()
    let task = session.dataTask(with: request as URLRequest) {
      data, response, error in
      if (error != nil)
      {
        completion("\(error)")
        return
      }

      let httpResponse = response as! HTTPURLResponse
      if (httpResponse.statusCode == 400) {
        let responseData = String(data: data!, encoding: String.Encoding.utf8)!
        completion(responseData)
      }
      else {
        completion("")
      }

    }
    task.resume()
  }

  func updateObject(_ myUrl: URL, jsonData: [String:AnyObject], completion: @escaping (String) -> ()) {
    let request = NSMutableURLRequest(url:myUrl)
    request.httpMethod = "PUT"

    do {
      request.httpBody =  try JSONSerialization.data(withJSONObject: jsonData, options: [])
    }
    catch {
      print("error=\(error)")
      completion("an error occurs when updating object: \(error)")
    }
    let session = self.getURLSession()
    let task = session.dataTask(with: request as URLRequest) {
      data, response, error in
      if (error != nil)
      {
        completion("\(error)")
        return
      }

      let httpResponse = response as! HTTPURLResponse
      if (httpResponse.statusCode == 400) {
        let responseData = String(data: data!, encoding: String.Encoding.utf8)!
        completion(responseData)
      }
      else {
        completion("")
      }

    }
    task.resume()
  }

  func updateObjects(_ myUrl: URL, jsonData: [[String: AnyObject]], completion: @escaping (String) -> ()) {
    let request = NSMutableURLRequest(url: myUrl)
    request.httpMethod = "PUT"

    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: jsonData, options: [])
    }
    catch {
      print("error=\(error)")
      completion("an error occurs when updating objects: \(error)")
    }

    let session = self.getURLSession()
    let task = session.dataTask(with: request as URLRequest) {
      data, response, error in
      if (error != nil) {
        completion("\(error)")
        return
      }

      let httpResponse = response as! HTTPURLResponse
      if (httpResponse.statusCode == 400) {
        let responseData = String(data: data!, encoding: String.Encoding.utf8)!
        completion(responseData)
      }
      else {
        completion("")
      }
    }
    task.resume()
  }

  func getFilteredObjects(_ myUrl: URL, completion: @escaping (NSArray) -> ()) {
    let request = NSMutableURLRequest(url: myUrl)
    request.httpMethod = "GET"
    let session = self.getURLSession()
    let task = session.dataTask(with: request as URLRequest) {
      data, response, error in
      if error != nil {
        print ("error: \(error)")
        return
      }

      do {
        if let jsonArray = try JSONSerialization.jsonObject(with: data!, options: []) as? NSArray {
          completion(jsonArray)
        }
      } catch let error as NSError {
        print(error.localizedDescription)
      }
    }
    task.resume()
  }

  func getObjectById(_ myUrl: URL, completion: @escaping (NSDictionary) -> ()) {
    let request = NSMutableURLRequest(url: myUrl)
    request.httpMethod = "GET"
    let session = self.getURLSession()
    let task = session.dataTask(with: request as URLRequest) {
      data, response, error in
      if error != nil {
        print ("error: \(error)")
        return
      }

      let httpResponse = response as! HTTPURLResponse
      if (httpResponse.statusCode == 404) {
        completion(NSDictionary())
      }

      do {
        if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
          completion(convertedJsonIntoDict)
        }
      } catch let error as NSError {
        print(error.localizedDescription)
      }

    }
    task.resume()
  }
}
