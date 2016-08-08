
import Foundation

class User
{
  
  private var USERURI: String
  private var PROFILEURI: String
  private var generics = Generics()
  
  init(){
    USERURI = "http://localhost:8080/users/"
    PROFILEURI = "http://localhost:8080/profiles/"
  }
  
  func createUser(userEmail: String, userPassword: String, completion: (String) -> ()) {
    let jsonData = ["uid": userEmail, "pwd": userPassword]
    generics.createObject(USERURI, jsonData: jsonData) { result in
      completion(result)
    }
  }
  
  func getUser(email: String, password: String, completion: (String) -> ()){
    let myUrl = NSURL(string: USERURI + email);
    let request = NSMutableURLRequest(URL:myUrl!);
    request.HTTPMethod = "GET";
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
      data, response, error in
      
      // Check for error
      if error != nil
      {
        print("error=\(error)")
        return
      }

      // Convert server json response to NSDictionary
      do {
        if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {

          // Get value by key
          if let storedEmail = convertedJsonIntoDict["uid"] as? String {
            if let storedPassword = convertedJsonIntoDict["pwd"] as? String {
              if (storedPassword != password){
                completion("Password does not match with email account \(storedEmail)")
              }
              else {
                completion("")
              }
            }
          }
          else {
            completion("Email account: \(email) does not exist")
          }
          
        }
      } catch let error as NSError {
        print(error.localizedDescription)
      }
    }
    
    task.resume()
  }

  func updateProfile(uid: String, name: String, title: String, about: String, rate: Double, completion: (String) -> ()) {
    let myUrl = NSURL(string: PROFILEURI + uid);
    let jsonData = ["fullName": name, "title" : title, "aboutMe": about, "rate" : rate]
    generics.updateObject(myUrl!, jsonData: jsonData as! [String : AnyObject]) { result in
      completion(result)
    }
  }

  func updateProfilePhoto(uid: String, imageData: NSData!, completion: (String) -> ()) {
    let myUrl = NSURL(string: PROFILEURI + uid);
    let jsonData = ["avatarImage" : imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))]
    generics.updateObject(myUrl!, jsonData: jsonData) { result in
      completion(result)
    }
  }

  func getProfile(uid: String, completion: (String, String, String, NSData, Double) -> ()){
    let myUrl = NSURL(string: PROFILEURI + uid);
    let request = NSMutableURLRequest(URL:myUrl!);
    request.HTTPMethod = "GET";
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
      data, response, error in

      // Check for error
      if error != nil
      {
        print("error=\(error)")
        return
      }


      // Convert server json response to NSDictionary
      do {
        if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {

          var fullName = ""
          var title = ""
          var aboutMe = ""
          var avatarImage: NSData = NSData()
          var rate = 0.0

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

          if ((convertedJsonIntoDict["avatarImage"] as? String) != nil) {
            avatarImage = NSData(base64EncodedString: (convertedJsonIntoDict["avatarImage"] as? String)!, options: NSDataBase64DecodingOptions(rawValue: 0))!
          }

          if ((convertedJsonIntoDict["rate"] as? Double) != nil) {
            rate = (convertedJsonIntoDict["rate"] as? Double)!
          }

          completion(fullName, title, aboutMe, avatarImage, rate)

        }
      } catch let error as NSError {
        print(error.localizedDescription)
      }
    }

    task.resume()
  }

  func getDiscover(uid: String, filterString: String, completion: (NSArray) -> ()) {
    let url = NSURL(string: "http://127.0.0.1:8080/profiles?filter=" + filterString)
    generics.getFilteredObjects(url!) { result in
      completion(result)
    }
  }

}
