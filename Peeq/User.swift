
import Foundation

class User
{
  
  private var URI: String
  
  init(){
    URI = "http://localhost:8080/users/"
  }
  
  func createUser(userEmail: String, userPassword: String, completion: (String) -> ()) {
    let myUrl = NSURL(string: URI);
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
      
      // You can print out response object
      print("response = \(response)")
      
      // Print out response body
      let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
      print("responseString = \(responseString)")
      completion("")
      
    }
    task.resume()
  }
  
  func getUser(email: String, password: String, completion: (String) -> ()){
    let myUrl = NSURL(string: URI + email);
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
      
      // Print out response string
      let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
      print("responseString = \(responseString)")
      
      
      // Convert server json response to NSDictionary
      do {
        if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
          
          // Print out dictionary
          print(convertedJsonIntoDict)
          
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

}
