//
//  DiscoverViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 6/29/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate {

  @IBOutlet weak var discoverTableView: UITableView!
  var celebrityCollection = [String]()
  var names = ["Angel Di Maria", "Sergio Aguero", "Luis Suarez", "Alexis Sanchez", "Javier Hernandez"]
  var titles = ["wingman", "forward", "striker", "playmaker", "playmaker"]
  var abouts = [String] (count: 5, repeatedValue: "I am a renowned international footballer")
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    loadImages()
  }

  func loadImages() {
    let scriptUrl = "http://swiftdeveloperblog.com/dynamic-list-of-images/?count=5"
    let url = NSURL(string: scriptUrl)
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
          for imageItem in jsonArray as! [[String:String]] {
            self.celebrityCollection.append(imageItem["thumb"]!)
          }

          dispatch_async(dispatch_get_main_queue()) {
            self.discoverTableView.reloadData()
          }
        }
      } catch let error as NSError {
        print(error.localizedDescription)
      }
    }
    task.resume()
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return celebrityCollection.count
  }

  func tappedOnImage(sender:UITapGestureRecognizer){
//    //using sender, we can get the point in respect to the table view
//    let tapLocation = sender.locationInView(self.discoverTableView)
//
//    //using the tapLocation, we retrieve the corresponding indexPath
//    let indexPath = self.discoverTableView.indexPathForRowAtPoint(tapLocation)!
//
//    //we could even get the cell from the index, too
//    let cell = self.discoverTableView.cellForRowAtIndexPath(indexPath) as! DiscoverTableViewCell

    self.performSegueWithIdentifier("segueFromDiscoverToAsk", sender: sender)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "segueFromDiscoverToAsk") {
      let dvc = segue.destinationViewController as! AskViewController

      //using sender, we can get the point in respect to the table view
      let tapLocation = sender!.locationInView(self.discoverTableView)

      //using the tapLocation, we retrieve the corresponding indexPath
      let indexPath = self.discoverTableView.indexPathForRowAtPoint(tapLocation)!

//      let indexPath = self.discoverTableView.indexPathForSelectedRow!

      dvc.uid = "\(indexPath.row)"
      print("\(indexPath.row)")
    }
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCellWithIdentifier("discoverCell",
      forIndexPath: indexPath) as! DiscoverTableViewCell
    let imageString = celebrityCollection[indexPath.row]
    let imageUrl = NSURL(string: imageString)
    let imageData = NSData(contentsOfURL: imageUrl!)
    if (imageData != nil) {
      myCell.discoverImageView.image = UIImage(data: imageData!)
      myCell.discoverImageView.layer.cornerRadius = myCell.discoverImageView.frame.size.width / 2
      myCell.discoverImageView.clipsToBounds = true
      myCell.discoverImageView.layer.borderColor = UIColor.blackColor().CGColor
      myCell.discoverImageView.layer.borderWidth = 1
    }

    myCell.discoverImageView.userInteractionEnabled = true
    let tappedOnImage = UITapGestureRecognizer(target: self, action: "tappedOnImage:")
    myCell.discoverImageView.addGestureRecognizer(tappedOnImage)

    myCell.name.text = names[indexPath.row]
    myCell.title.text = titles[indexPath.row]
    myCell.about.text = abouts[indexPath.row]

    myCell.about.numberOfLines = 0
    myCell.about.lineBreakMode = NSLineBreakMode.ByWordWrapping
    myCell.about.sizeToFit()
    myCell.about.font = myCell.about.font.fontWithSize(12)

    myCell.name.numberOfLines = 1
    myCell.name.font = UIFont.boldSystemFontOfSize(18)
    myCell.name.lineBreakMode = NSLineBreakMode.ByCharWrapping
    myCell.name.sizeToFit()

    myCell.title.font = myCell.title.font.fontWithSize(15)

    return myCell
  }

}
