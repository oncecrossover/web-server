
import Foundation

class User
{  
  fileprivate var USERURI: String
  fileprivate var PROFILEURI: String
  fileprivate var SIGNINURI: String
  fileprivate var APPLYURI: String
  fileprivate var PCURI: String
  fileprivate var generics = Generics()
  
  init(){
    USERURI = generics.HTTPHOST + "users"
    PROFILEURI = generics.HTTPHOST + "profiles/"
    SIGNINURI = generics.HTTPHOST + "signin"
    APPLYURI = generics.HTTPHOST + "takeq"
    PCURI = generics.HTTPHOST + "pcaccounts/"
  }

  func createUser(_ userEmail: String, username: String, userPassword: String,
                  fullName: String, source: String, completion: @escaping (NSDictionary) -> ()) {
    var jsonData: [String : AnyObject] = ["uname": username as AnyObject, "pwd": userPassword as AnyObject, "fullName" : fullName as AnyObject, "source" : source as AnyObject]

    if (!userEmail.isEmpty) {
      jsonData["primaryEmail"] = userEmail as AnyObject
    }

    let myUrl = URL(string: USERURI);
    let request = NSMutableURLRequest(url:myUrl!);
    request.httpMethod = "POST";

    do {
      request.httpBody =  try JSONSerialization.data(withJSONObject: jsonData, options: [])
    }
    catch {
      print("error=\(error)")
      let error = NSMutableDictionary()
      error["error"] = "An error occurs. Please try later"
      completion(error)
      return
    }

    let session = generics.getURLSession()
    let task = session.dataTask(with: request as URLRequest) {
      data, response, error in
      if (error != nil)
      {
        let error = NSMutableDictionary()
        error["error"] = "An error occurs. Please try later"
        completion(error)
        return
      }

      let httpResponse = response as! HTTPURLResponse
      if (httpResponse.statusCode == 400 || httpResponse.statusCode == 500) {
        let responseData = NSMutableDictionary()
        responseData["error"] = "A user exists with the username or email provided"
        completion(responseData)
      }
      else {
        do {
          if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
            completion(convertedJsonIntoDict)
          }
        } catch let error as NSError {
          print(error.localizedDescription)
        }
      }

    }
    task.resume()
  }

  func signinUser(_ email: String, password: String, completion: @escaping (NSDictionary) -> ()) {
    let myUrl = URL(string: self.SIGNINURI)!;
    let request = NSMutableURLRequest(url: myUrl)
    request.httpMethod = "POST"
    let jsonData = ["uname" : email, "pwd": password]

    do {
      request.httpBody =  try JSONSerialization.data(withJSONObject: jsonData, options: [])
    }
    catch {
      print("error=\(error)")
      let error = NSMutableDictionary()
      error["error"] = "An error occurs. Please try later"
      completion(error)
      return
    }

    let session = generics.getURLSession()
    let task = session.dataTask(with: request as URLRequest) {
      data, response, error in
      if error != nil {
        print ("error: \(String(describing: error))")
        return
      }

      let httpResponse = response as! HTTPURLResponse
      if (httpResponse.statusCode == 400) {
        let result = NSMutableDictionary()
        result["error"] = "Password does not match with email account \(email)"
        completion(result)
        return
      }

      do {
        if let result = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
          completion(result)
        }
      } catch let error as NSError {
        print(error.localizedDescription)
      }

    }
    task.resume()
  }

  func getUserById(_ uid: String, completion: @escaping (NSDictionary) -> ()) {
    let myUrl = URL(string: USERURI + "/\(uid)")
    generics.getObjectById(myUrl!) {
      completion($0)
    }
  }

  func getUserByUname(_ uname: String, completion: @escaping (NSArray) -> ()) {
    let myUrl = URL(string: USERURI + "?uname='\(uname)'")
    generics.getFilteredObjects(myUrl!) {
      completion($0)
    }
  }

  func updateProfile(_ uid: String, name: String, title: String, about: String, rate: Double, completion: @escaping (String) -> ()) {
    let myUrl = URL(string: PROFILEURI + "\(uid)")
    let jsonData = ["fullName": name as AnyObject, "title" : title as AnyObject, "aboutMe": about as AnyObject, "rate" : rate as AnyObject]
    generics.updateObject(myUrl!, jsonData: jsonData) {
      completion($0)
    }
  }

  func updateProfilePhoto(_ uid: String, imageData: Data!, completion: @escaping (String) -> ()) {
    let myUrl = URL(string: PROFILEURI + "\(uid)")
    let jsonData = ["avatarImage" : imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) as AnyObject]
    generics.updateObject(myUrl!, jsonData: jsonData) {
      completion($0)
    }
  }

  func updateDeviceToken(_ uid: String, token: String, completion: @escaping (String) -> ()) {
    let myUrl = URL(string: PROFILEURI + "\(uid)")
    let jsonData = ["deviceToken" : token as AnyObject]
    generics.updateObject(myUrl!, jsonData: jsonData) {
      completion($0)
    }
  }

  func applyToTakeQuestion(_ uid: String, completion: @escaping (String) ->()) {
    let data = ["uid": uid as AnyObject, "takeQuestion": "APPLIED" as AnyObject]
    generics.createObject(APPLYURI, jsonData: data){
      completion($0)
    }
  }

  func getProfile(_ uid: String, completion: @escaping (String, String, String, String?, Int, String) -> ()){
    let myUrl = URL(string: PROFILEURI + "\(uid)");
    generics.getObjectById(myUrl!) { convertedJsonIntoDict in
      var fullName = ""
      var title = ""
      var aboutMe = ""
      var avatarUrl: String?
      var rate = 0
      var status = "NA"

      // Get value by key
      if ((convertedJsonIntoDict["fullName"] as? String) != nil) {
        fullName = (convertedJsonIntoDict["fullName"] as? String)!
      }

      if ((convertedJsonIntoDict["title"] as? String) != nil) {
        title = (convertedJsonIntoDict["title"] as? String)!
      }

      if ((convertedJsonIntoDict["aboutMe"] as? String) != nil) {
        aboutMe = (convertedJsonIntoDict["aboutMe"] as? String)!
      }

      if ((convertedJsonIntoDict["avatarUrl"] as? String) != nil) {
        avatarUrl = (convertedJsonIntoDict["avatarUrl"] as? String)!
      }

      if ((convertedJsonIntoDict["rate"] as? Int) != nil) {
        rate = (convertedJsonIntoDict["rate"] as? Int)!
      }

      if ((convertedJsonIntoDict["takeQuestion"] as? String) != nil) {
        status = (convertedJsonIntoDict["takeQuestion"] as? String)!
      }

      completion(fullName, title, aboutMe, avatarUrl, rate, status)
    }
  }

  func getDiscover(_ filterString: String, completion: @escaping (NSArray) -> ()) {
    let url = URL(string: generics.HTTPHOST + "profiles?" + filterString)
    generics.getFilteredObjects(url!) {
      completion($0)
    }
  }

  func updatePaypal(_ uid: String, paypalEmail: String, completion: @escaping (String) -> ()) {
    let url = URL(string: PCURI + "\(uid)")
    let jsonData = ["payTo" : paypalEmail as AnyObject]
    generics.updateObject(url!, jsonData: jsonData) {
      completion($0)
    }
  }

  func getPaypal(_ uid: String, completion: @escaping (NSDictionary) ->()) {
    let url = URL(string: PCURI + "\(uid)")
    generics.getObjectById(url!) {
      completion($0)
    }
  }
}
