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
  var uid: Int?

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
    label.font = UIFont.systemFont(ofSize: 16)
    label.text = "Choose all your interests"
    label.textColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1.0)
    label.textAlignment = .center
    return label
  }()

  lazy var interests: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 20
    layout.minimumInteritemSpacing = 20
    let interests = UICollectionView(frame: .zero, collectionViewLayout: layout)
    interests.register(InterestCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)
    interests.backgroundColor = UIColor.clear
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
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()

  lazy var doneButton: UIButton = {
    let button = CustomButton()
    button.backgroundColor = UIColor.defaultColor()
    button.setTitle("Done", for: UIControlState())
    button.setTitle("Done", for: .disabled)
    button.setTitleColor(UIColor.white, for: UIControlState())
    button.setTitleColor(UIColor.white, for: .disabled)

    button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    return button
  }()

  lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
    indicator.hidesWhenStopped = true
    indicator.translatesAutoresizingMaskIntoConstraints = false
    return indicator
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white

    loadData()

    view.addSubview(message)
    view.addSubview(interests)
    view.addSubview(underline)
    view.addSubview(note)
    view.addSubview(doneButton)
    view.addSubview(activityIndicator)
    activityIndicator.center = view.center
    doneButton.isEnabled = false

    view.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: message)
    view.addConstraintsWithFormat("H:|[v0]|", views: underline)
    view.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: note)
    view.addConstraintsWithFormat("V:|-80-[v0(20)]-20-[v1]-20-[v2(1)]-10-[v3(20)]-8-[v4(36)]-58-|", views: message, interests, underline, note, doneButton)
    interests.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    interests.widthAnchor.constraint(equalToConstant: 286).isActive = true

    doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    doneButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
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

          DispatchQueue.main.async {
            self.interests.reloadData()
            self.activityIndicator.stopAnimating()
            self.populateSelectedCells()
          }
        }
      }
      else {
        DispatchQueue.main.async {
          self.interests.reloadData()
          self.activityIndicator.stopAnimating()
        }
      }
    }
  }

  func populateSelectedCells() {
    for (index, item) in allCategories.enumerated() {
      for interest in selectedCategories {
        if (item.id == interest.catId) {
          interests.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
        }
      }
    }
  }

  func populateCategoriesToUpdate() -> [[String: AnyObject]] {
    var categoriesToUpdate:[[String: AnyObject]] = []
    for category in newSelectedCategories {
      var interest: [String: AnyObject] = [:]
      if let _ = category.id {
        interest["id"] = category.id as AnyObject?
      }

      interest["catId"] = category.catId as AnyObject?
      interest["isInterest"] = "Yes" as AnyObject?
      categoriesToUpdate.append(interest)
    }

    for category in deselectedCategories {
      var interest: [String: AnyObject] = [:]
      if let _ = category.id {
        interest["id"] = category.id as AnyObject?
      }

      interest["catId"] = category.catId as AnyObject?
      interest["isInterest"] = "No" as AnyObject?
      categoriesToUpdate.append(interest)
    }

    return categoriesToUpdate
  }
}
// IB related actions
extension InterestPickerViewController {

  func doneButtonTapped() {
    let categoriesToUpdate:[[String: AnyObject]] = populateCategoriesToUpdate()

//    if (email == nil) {
//      email = UserDefaults.standard.string(forKey: "email")
//    }

    let uid = UserDefaults.standard.integer(forKey: "uid")
    category.updateInterests(uid, interests: categoriesToUpdate) { result in
      if (result.isEmpty) {
        DispatchQueue.main.async {
          if (self.isProfile) {
            _ = self.navigationController?.popViewController(animated: true)
          }
          else {
            let vc = TutorialViewController()
            vc.uid = self.uid!
            self.navigationController?.pushViewController(vc, animated: true)
          }
        }
      }
      else {
        DispatchQueue.main.async {
          self.utility.displayAlertMessage("There is an error saving your interests", title: "Alert", sender: self)
        }
      }
    }
  }

  func checkButton() {
    if (selectedCategories.count > 0 || newSelectedCategories.count > 0 || deselectedCategories.count > 0) {
      doneButton.isEnabled = true
    }
    else {
      doneButton.isEnabled = false
    }
  }
}
extension InterestPickerViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 82, height: 82)
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return allCategories.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! InterestCollectionViewCell
    let category = allCategories[indexPath.row]
    let image = UIImage(named: category.name)
    myCell.icon.image = image?.withRenderingMode(.alwaysTemplate)
    let interest = InterestModel(_catId: category.id, _name: category.name)
    if (selectedCategories.contains(interest)) {
      myCell.icon.tintColor = UIColor.defaultColor()
    }
    else {
      myCell.icon.tintColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
    }

    return myCell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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

  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
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

