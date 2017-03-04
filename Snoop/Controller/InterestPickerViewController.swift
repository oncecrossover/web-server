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
  var email: String?

  var allCategories: [CategoryModel] = []
  var selectedCategories: Set<InterestModel> = []
  var newSelectedCategories: Set<InterestModel> = []
  var deselectedCategories: Set<InterestModel> = []

  var isProfile = false
  var isProfileUpdated = false

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
    view.addConstraintsWithFormat("V:|-80-[v0(20)]-20-[v1]-20-[v2(1)]-10-[v3(20)]-8-[v4(36)]-58-|", views: message, interests, underline, note, doneButton)
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
        self.allCategories.append(CategoryModel(_id: id, _name: name))
      }
      if (self.isProfile) {
        self.category.getInterest() { jsonArray in
          for element in jsonArray as! [[String:AnyObject]] {
            let mappingId = element["id"] as! Int
            let catId = element["catId"] as! Int
            let name = element["catName"] as! String
            self.selectedCategories.insert(InterestModel(_id: mappingId, _catId: catId, _name: name))
          }

          dispatch_async(dispatch_get_main_queue()) {
            self.interests.reloadData()
            self.activityIndicator.stopAnimating()
            self.populateSelectedCells()
          }
        }
      }
      else {
        dispatch_async(dispatch_get_main_queue()) {
          self.interests.reloadData()
          self.activityIndicator.stopAnimating()
        }
      }
    }
  }

  func populateSelectedCells() {
    for (index, item) in allCategories.enumerate() {
      for interest in selectedCategories {
        if (item.id == interest.catId) {
          interests.selectItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: false, scrollPosition: .None)
        }
      }
    }
  }

  func populateCategoriesToUpdate() -> [[String: AnyObject]] {
    var categoriesToUpdate:[[String: AnyObject]] = []
    for category in newSelectedCategories {
      var interest: [String: AnyObject] = [:]
      if let _ = category.id {
        interest["id"] = category.id
      }

      interest["catId"] = category.catId
      interest["isInterest"] = "Yes"
      categoriesToUpdate.append(interest)
    }

    for category in deselectedCategories {
      var interest: [String: AnyObject] = [:]
      if let _ = category.id {
        interest["id"] = category.id
      }

      interest["catId"] = category.catId
      interest["isInterest"] = "No"
      categoriesToUpdate.append(interest)
    }

    return categoriesToUpdate
  }
}
// IB related actions
extension InterestPickerViewController {

  func doneButtonTapped() {
    let categoriesToUpdate:[[String: AnyObject]] = populateCategoriesToUpdate()

    if (email == nil) {
      email = NSUserDefaults.standardUserDefaults().stringForKey("email")
    }

    category.updateInterests(email!, interests: categoriesToUpdate) { result in
      if (result.isEmpty) {
        dispatch_async(dispatch_get_main_queue()) {
          if (self.isProfile) {
            self.navigationController?.popViewControllerAnimated(true)
          }
          else {
            let vc = TutorialViewController()
            vc.email = self.email
            self.navigationController?.pushViewController(vc, animated: true)
          }
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
    if (selectedCategories.count > 0 || newSelectedCategories.count > 0 || deselectedCategories.count > 0) {
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
    let category = allCategories[indexPath.row]
    let image = UIImage(named: category.name)
    myCell.icon.image = image?.imageWithRenderingMode(.AlwaysTemplate)
    let interest = InterestModel(_catId: category.id, _name: category.name)
    if (selectedCategories.contains(interest)) {
      myCell.icon.tintColor = UIColor.defaultColor()
    }
    else {
      myCell.icon.tintColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
    }

    return myCell
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let category = allCategories[indexPath.row]
    let interest = InterestModel(_catId: category.id, _name: category.name)
    if (deselectedCategories.contains(interest)) {
      deselectedCategories.remove(interest)
    }
    else {
      newSelectedCategories.insert(interest)
    }
    checkButton()
  }

  func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    let category = allCategories[indexPath.row]
    let interest = InterestModel(_catId: category.id, _name: category.name)
    if (newSelectedCategories.contains(interest)) {
      newSelectedCategories.remove(interest)
    }
    else {
      deselectedCategories.insert(interest)
    }
    checkButton()
  }
}

