
import Foundation

class User
{
  
  private var USERURI: String
  private var PROFILEURI: String
  
  init(){
    USERURI = "http://localhost:8080/users/"
    PROFILEURI = "http://localhost:8080/profiles/"
  }
  
  func createUser(userEmail: String, userPassword: String, completion: (String) -> ()) {
    let myUrl = NSURL(string: USERURI);
    let request = NSMutableURLRequest(URL:myUrl!);
    request.HTTPMethod = "POST";
    let jsonData = ["uid": userEmail, "pwd": userPassword]
    
    do {
      request.HTTPBody =  try NSJSONSerialization.dataWithJSONObject(jsonData, options: [])
    }
    catch {
      print("error=\(error)")
      completion("an error occurs when creating user: \(error)")
    }
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
      data, response, error in
      if (error != nil)
      {
        print("error=\(error)")
        return
      }

      
      // Print out response body
      let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
      print("responseString = \(responseString)")
      completion("")
      
    }
    task.resume()
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
    let request = NSMutableURLRequest(URL:myUrl!);
    request.HTTPMethod = "PUT";
    let jsonData = ["fullName": name, "title" : title, "aboutMe": about, "rate" : rate]

    do {
      request.HTTPBody =  try NSJSONSerialization.dataWithJSONObject(jsonData, options: [])
    }
    catch {
      print("error=\(error)")
      completion("an error occurs when updating user profile: \(error)")
    }
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
      data, response, error in
      if (error != nil)
      {
        print("error=\(error)")
        return
      }

      // Print out response body
      let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
      print("responseString = \(responseString)")
      completion("")

    }
    task.resume()
  }

  func updateProfilePhoto(uid: String, imageData: NSData!, completion: (String) -> ()) {
    let myUrl = NSURL(string: PROFILEURI + uid);
    let request = NSMutableURLRequest(URL:myUrl!);
    request.HTTPMethod = "PUT";
    let jsonData = ["avatarImage" : imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))]
    do {
      request.HTTPBody =  try NSJSONSerialization.dataWithJSONObject(jsonData, options: [])
    }
    catch {
      print("error=\(error)")
      completion("an error occurs when updating user profile: \(error)")
    }
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
      data, response, error in
      if (error != nil)
      {
        print("error=\(error)")
        return
      }

      // Print out response body
      let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
      print("responseString = \(responseString)")
      completion("")

    }
    task.resume()
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
    let request = NSMutableURLRequest(URL: url!)
    request.HTTPMethod = "GET"
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
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

}
