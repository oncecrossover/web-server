
import Foundation

class User
{  
  private var USERURI: String
  private var PROFILEURI: String
  private var SIGNINURI: String
  private var APPLYURI: String
  private var generics = Generics()
  
  init(){
    USERURI = generics.HTTPHOST + "users/"
    PROFILEURI = generics.HTTPHOST + "profiles/"
    SIGNINURI = generics.HTTPHOST + "signin"
    APPLYURI = generics.HTTPHOST + "takeq"
  }
  
  func createUser(userEmail: String, userPassword: String, fullName: String!, completion: (String) -> ()) {
    let jsonData = ["uid": userEmail, "pwd": userPassword, "fullName" : fullName]
    generics.createObject(USERURI, jsonData: jsonData) { result in
      completion(result)
    }
  }
  
  func signinUser(email: String, password: String, completion: (String) -> ()) {
    let myUrl = NSURL(string: self.SIGNINURI)!;
    let request = NSMutableURLRequest(URL: myUrl)
    request.HTTPMethod = "POST"
    let jsonData = ["uid" : email, "pwd": password]

    do {
      request.HTTPBody =  try NSJSONSerialization.dataWithJSONObject(jsonData, options: [])
    }
    catch {
      print("error=\(error)")
      completion("an error occurs when creating object: \(error)")
    }
    let session = generics.getURLSession()
    let task = session.dataTaskWithRequest(request) {
      data, response, error in
      if error != nil {
        print ("error: \(error)")
        return
      }

      let httpResponse = response as! NSHTTPURLResponse
      if (httpResponse.statusCode == 400) {
        completion("Password does not match with email account \(email)")
        return
      }

      do {
        if let _ = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
          completion("")
        }
      } catch let error as NSError {
        print(error.localizedDescription)
      }

    }
    task.resume()
  }

  func getUser(email: String, completion: (NSDictionary) -> ()) {
    let myUrl = NSURL(string: USERURI + email)
    generics.getObjectById(myUrl!) {
      completion($0)
    }
  }

  func updateProfile(uid: String, name: String, title: String, about: String, rate: Double, completion: (String) -> ()) {
    let myUrl = NSURL(string: PROFILEURI + uid)
    let jsonData = ["fullName": name, "title" : title, "aboutMe": about, "rate" : rate]
    generics.updateObject(myUrl!, jsonData: jsonData as! [String : AnyObject]) { result in
      completion(result)
    }
  }

  func updateProfilePhoto(uid: String, imageData: NSData!, completion: (String) -> ()) {
    let myUrl = NSURL(string: PROFILEURI + uid)
    let jsonData = ["avatarImage" : imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))]
    generics.updateObject(myUrl!, jsonData: jsonData) { result in
      completion(result)
    }
  }

  func updateDeviceToken(uid: String, token: String, completion: (String) -> ()) {
    let myUrl = NSURL(string: PROFILEURI + uid)
    let jsonData = ["deviceToken" : token]
    generics.updateObject(myUrl!, jsonData: jsonData) { result in
      completion(result)
    }
  }

  func applyToTakeQuestion(uid: String, completion: (String) ->()) {
    let data = ["uid": uid, "takeQuestion": "APPLIED"]
    generics.createObject(APPLYURI, jsonData: data){ result in
      completion(result)
    }
  }

  func getProfile(uid: String, completion: (String, String, String, String?, Double, String) -> ()){
    let myUrl = NSURL(string: PROFILEURI + uid);
    generics.getObjectById(myUrl!) { convertedJsonIntoDict in
      var fullName = ""
      var title = ""
      var aboutMe = ""
      var avatarUrl: String?
      var rate = 0.0
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

      if ((convertedJsonIntoDict["rate"] as? Double) != nil) {
        rate = (convertedJsonIntoDict["rate"] as? Double)!
      }

      if ((convertedJsonIntoDict["takeQuestion"] as? String) != nil) {
        status = (convertedJsonIntoDict["takeQuestion"] as? String)!
      }

      completion(fullName, title, aboutMe, avatarUrl, rate, status)
    }
  }

  func getDiscover(filterString: String, completion: (NSArray) -> ()) {
    let url = NSURL(string: generics.HTTPHOST + "profiles?" + filterString)
    generics.getFilteredObjects(url!) { result in
      completion(result)
    }
  }

}
