//
//  Generics.swift
//  Peeq
//
//  Created by Bowen Zhang on 8/8/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
class Generics: NSObject, NSURLSessionDelegate {
  var HTTPHOST = "https://localhost:8443/"
  override init() {
  }

  func getURLSession() -> NSURLSession {
    let configuration =
      NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: configuration,
                               delegate: self,
                               delegateQueue: NSOperationQueue.mainQueue())
    return session
  }

  func URLSession(session: NSURLSession,  didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
    let serverTrust = challenge.protectionSpace.serverTrust
    let certificate = SecTrustGetCertificateAtIndex(serverTrust!, 0)

    // Set SSL policies for domain name check
    let policies = NSMutableArray();
    policies.addObject(SecPolicyCreateSSL(true, (challenge.protectionSpace.host)))
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
    let remoteCertificateData:NSData = SecCertificateCopyData(certificate!)
    let pathToCert = NSBundle.mainBundle().pathForResource("snoop-server", ofType: "der")
    let localCertificate:NSData = NSData(contentsOfFile: pathToCert!)!

    if (remoteCertificateData.isEqualToData(localCertificate)) {
        let credential:NSURLCredential = NSURLCredential(forTrust: serverTrust!)
        completionHandler(.UseCredential, credential)
    } else {
        completionHandler(.CancelAuthenticationChallenge, nil)
    }
  }

  func createObject(URI: String, jsonData: [String:AnyObject], completion: (String) -> ()) {
    let myUrl = NSURL(string: URI);
    let request = NSMutableURLRequest(URL:myUrl!);
    request.HTTPMethod = "POST";

    do {
      request.HTTPBody =  try NSJSONSerialization.dataWithJSONObject(jsonData, options: [])
    }
    catch {
      print("error=\(error)")
      completion("an error occurs when creating object: \(error)")
    }
    let session = self.getURLSession()
    let task = session.dataTaskWithRequest(request) {
      data, response, error in
      if (error != nil)
      {
        completion("\(error)")
        return
      }

      let httpResponse = response as! NSHTTPURLResponse
      if (httpResponse.statusCode == 400) {
        let responseData = String(data: data!, encoding: NSUTF8StringEncoding)!
        completion(responseData)
      }
      else {
        completion("")
      }

    }
    task.resume()
  }

  func updateObject(myUrl: NSURL, jsonData: [String:AnyObject], completion: (String) -> ()) {
    let request = NSMutableURLRequest(URL:myUrl);
    request.HTTPMethod = "PUT";

    do {
      request.HTTPBody =  try NSJSONSerialization.dataWithJSONObject(jsonData, options: [])
    }
    catch {
      print("error=\(error)")
      completion("an error occurs when updating object: \(error)")
    }
    let session = self.getURLSession()
    let task = session.dataTaskWithRequest(request) {
      data, response, error in
      if (error != nil)
      {
        completion("\(error)")
        return
      }

      let httpResponse = response as! NSHTTPURLResponse
      if (httpResponse.statusCode == 400) {
        let responseData = String(data: data!, encoding: NSUTF8StringEncoding)!
        completion(responseData)
      }
      else {
        completion("")
      }

    }
    task.resume()
  }

  func getFilteredObjects(myUrl: NSURL, completion: (NSArray) -> ()) {
    let request = NSMutableURLRequest(URL: myUrl)
    request.HTTPMethod = "GET"
    let session = self.getURLSession()
    let task = session.dataTaskWithRequest(request){
      data, response, error in
      if error != nil {
        print ("error: \(error)")
        return
      }

      do {
        if let jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSArray {
          completion(jsonArray)
        }
      } catch let error as NSError {
        print(error.localizedDescription)
      }
    }
    task.resume()
  }

  func getObjectById(myUrl: NSURL, completion: (NSDictionary) -> ()) {
    let request = NSMutableURLRequest(URL: myUrl)
    request.HTTPMethod = "GET"
    let session = self.getURLSession()
    let task = session.dataTaskWithRequest(request) {
      data, response, error in
      if error != nil {
        print ("error: \(error)")
        return
      }

      let httpResponse = response as! NSHTTPURLResponse
      if (httpResponse.statusCode == 404) {
        completion(NSDictionary())
      }

      do {
        if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
          completion(convertedJsonIntoDict)
        }
      } catch let error as NSError {
        print(error.localizedDescription)
      }

    }
    task.resume()
  }

}
