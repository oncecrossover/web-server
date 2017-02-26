//
//  InterestPickerViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/20/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class InterestPickerViewController: UIViewController {

  let cellId = "interestCell"
  var email: String!

  var allCategories: [(Int, String)] = []
  var selectedCategories: [(Int, String)] = []

  let maximumNumberOfInterests = 2
  var selectedInterest: Set<String> = []
  let category = Category()
  lazy var utility = UIUtility()

  let message: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFontOfSize(16)
    label.text = "Choose all your interests"
    label.textColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1.0)
    label.textAlignment = .Center
    return label
  }()

  lazy var interests: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 20
    layout.minimumInteritemSpacing = 20
    let interests = UICollectionView(frame: .zero, collectionViewLayout: layout)
    interests.registerClass(InterestCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)
    interests.backgroundColor = UIColor.clearColor()
    interests.allowsMultipleSelection = true
    interests.dataSource = self
    interests.delegate = self
    return interests
  }()

  let underline: UIView = {
    let line = UIView()
    line.backgroundColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1.0)
    return line
  }()

  let note: UILabel = {
    let label = UILabel()
    label.text = "Snoop will customize content for you"
    label.textColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1.0)
    label.textAlignment = .Center
    label.font = UIFont.systemFontOfSize(14)
    return label
  }()

  lazy var doneButton: UIButton = {
    let button = CustomButton()
    button.backgroundColor = UIColor.defaultColor()
    button.setTitle("Done", forState: .Normal)
    button.setTitle("Done", forState: .Disabled)
    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    button.setTitleColor(UIColor.whiteColor(), forState: .Disabled)

    button.addTarget(self, action: #selector(doneButtonTapped), forControlEvents: .TouchUpInside)
    return button
  }()

  lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    indicator.hidesWhenStopped = true
    indicator.translatesAutoresizingMaskIntoConstraints = false
    return indicator
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()

    loadData()

    view.addSubview(message)
    view.addSubview(interests)
    view.addSubview(underline)
    view.addSubview(note)
    view.addSubview(doneButton)
    view.addSubview(activityIndicator)
    activityIndicator.center = view.center
    doneButton.enabled = false

    view.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: message)
    view.addConstraintsWithFormat("H:|[v0]|", views: underline)
    view.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: note)
    view.addConstraintsWithFormat("V:|-80-[v0(20)]-20-[v1]-20-[v2(1)]-10-[v3(20)]-8-[v4(36)]-8-|", views: message, interests, underline, note, doneButton)
    interests.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    interests.widthAnchor.constraintEqualToConstant(286).active = true

    doneButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    doneButton.widthAnchor.constraintEqualToConstant(100).active = true
    doneButton.layer.cornerRadius = 18
    doneButton.clipsToBounds = true
  }

  func loadData() {
    activityIndicator.startAnimating()
    category.getCategories() { jsonArray in
      for category in jsonArray as! [[String: AnyObject]] {
        let id = category["id"] as! Int
        let name = category["name"] as! String
        self.allCategories.append((id, name))
      }
      dispatch_async(dispatch_get_main_queue()) {
        self.interests.reloadData()
        self.activityIndicator.stopAnimating()
      }
    }
  }

}
// IB related actions
extension InterestPickerViewController {

  func doneButtonTapped() {
    var categoriesToUpdate:[[String: AnyObject]] = []
    for category in selectedCategories {
      var interest: [String: AnyObject] = [:]
      interest["catId"] = category.0
      interest["isInterest"] = "Yes"
      categoriesToUpdate.append(interest)
    }

    category.updateInterests(email, interests: categoriesToUpdate) { result in
      if (result.isEmpty) {
        dispatch_async(dispatch_get_main_queue()) {
          let vc = TutorialViewController()
          vc.email = self.email
          self.navigationController?.pushViewController(vc, animated: true)
        }
      }
      else {
        dispatch_async(dispatch_get_main_queue()) {
          self.utility.displayAlertMessage("Where is an error saving your interests", title: "Alert", sender: self)
        }
      }
    }
  }

  func checkButton() {
    if (selectedInterest.count > 0) {
      doneButton.enabled = true
    }
    else {
      doneButton.enabled = false
    }
  }
}
extension InterestPickerViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSizeMake(82, 82)
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return allCategories.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let myCell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellId, forIndexPath: indexPath) as! InterestCollectionViewCell
    let image = UIImage(named: allCategories[indexPath.row].1)
    myCell.icon.image = image?.imageWithRenderingMode(.AlwaysTemplate)
    if (selectedInterest.contains(allCategories[indexPath.row].1)) {
      myCell.icon.tintColor = UIColor.defaultColor()
    }
    else {
      myCell.icon.tintColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
    }

    return myCell
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let interest = allCategories[indexPath.row]
    selectedInterest.insert(interest.1)
    selectedCategories.append(interest)

    checkButton()
  }

  func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    let interest = allCategories[indexPath.row]
    if (selectedInterest.contains(interest.1)) {
      selectedInterest.remove(interest.1)
      selectedCategories.append(interest)
    }
    checkButton()
  }
}
