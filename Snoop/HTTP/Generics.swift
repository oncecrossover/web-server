//
//  Generics.swift
//  Peeq
//
//  Created by Bowen Zhang on 8/8/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
import Security
class Generics: NSObject, URLSessionDelegate {
  var HTTPHOST = Bundle.main.object(forInfoDictionaryKey: "HTTPHOST") as! String
  override init() {
  }

  func getURLSession(_ urlDelegate: Generics) -> Foundation.URLSession {
    let configuration =
      URLSessionConfiguration.default
    let session = Foundation.URLSession(configuration: configuration,
                               delegate: urlDelegate,
                               delegateQueue: OperationQueue.main)
    return session
  }

  func getURLSession() -> Foundation.URLSession {
    return getURLSession(self)
  }

  func urlSession(_ session: URLSession,  didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
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
    else if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate) {
      let identityAndTrust:IdentityAndTrust = self.extractIdentity();

      let urlCredential:URLCredential = URLCredential(
        identity: identityAndTrust.identityRef,
        certificates: identityAndTrust.certArray as? [AnyObject],
        persistence: URLCredential.Persistence.forSession);

      completionHandler(URLSession.AuthChallengeDisposition.useCredential, urlCredential);
    }
  }

  struct IdentityAndTrust {

    var identityRef:SecIdentity
    var trust:SecTrust
    var certArray:AnyObject
  }

  func extractIdentity() -> IdentityAndTrust {
    var identityAndTrust:IdentityAndTrust!
    var securityError:OSStatus = errSecSuccess

    let path = Bundle.main.path(forResource: "snoop-client", ofType: "p12")
    let PKCS12Data = NSData(contentsOf: URL(fileURLWithPath: path!))!
    let key : NSString = kSecImportExportPassphrase as NSString
    let options : NSDictionary = [key : "changeme"]
    //create variable for holding security information
    //var privateKeyRef: SecKeyRef? = nil

    var items : CFArray?

    securityError = SecPKCS12Import(PKCS12Data, options, &items)

    if securityError == errSecSuccess {
      let certItems:CFArray = items as CFArray!;
      let certItemsArray:Array = certItems as Array
      let dict:AnyObject? = certItemsArray.first;
      if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> {

        // grab the identity
        let identityPointer:AnyObject? = certEntry["identity"];
        let secIdentityRef:SecIdentity = identityPointer as! SecIdentity!;
        // grab the trust
        let trustPointer:AnyObject? = certEntry["trust"];
        let trustRef:SecTrust = trustPointer as! SecTrust;
        // grab the cert
        let chainPointer:AnyObject? = certEntry["chain"];
        identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef, trust: trustRef, certArray:  chainPointer!);
      }
    }
    return identityAndTrust;
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
        completion("\(String(describing: error))")
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
    session.finishTasksAndInvalidate()
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
        completion("\(String(describing: error))")
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
    session.finishTasksAndInvalidate()
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
        completion("\(String(describing: error))")
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
    session.finishTasksAndInvalidate()
  }

  func getFilteredObjects(_ myUrl: URL, completion: @escaping (NSArray) -> ()) {
    let request = NSMutableURLRequest(url: myUrl)
    request.httpMethod = "GET"
    let session = self.getURLSession()
    let task = session.dataTask(with: request as URLRequest) {
      data, response, error in
      if error != nil {
        print ("error: \(String(describing: error))")
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
    session.finishTasksAndInvalidate()
  }

  func getObjectById(_ myUrl: URL, completion: @escaping (NSDictionary) -> ()) {
    let request = NSMutableURLRequest(url: myUrl)
    request.httpMethod = "GET"
    let session = self.getURLSession(self)
    let task = session.dataTask(with: request as URLRequest) {
      data, response, error in
      if error != nil {
        print ("error: \(String(describing: error))")
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
    session.finishTasksAndInvalidate()
  }
}
