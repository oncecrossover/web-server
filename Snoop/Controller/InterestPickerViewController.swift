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
  var uid: String?

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
    layout.minimumLineSpacing = 10
    layout.minimumInteritemSpacing = 10
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
    label.text = "vInsider will customize content for you"
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

    self.tabBarController?.tabBar.isHidden = true
    loadData()

    view.addSubview(message)
    view.addSubview(interests)
    view.addSubview(underline)
    view.addSubview(note)
    view.addSubview(doneButton)
    view.addSubview(activityIndicator)
    activityIndicator.center = view.center

    view.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: message)
    view.addConstraintsWithFormat("H:|[v0]|", views: underline)
    view.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: note)
    view.addConstraintsWithFormat("V:|-80-[v0(20)]-10-[v1]-10-[v2(1)]-10-[v3(20)]-8-[v4(36)]-20-|", views: message, interests, underline, note, doneButton)
    view.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: interests)

    doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    doneButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
    doneButton.layer.cornerRadius = 18
    doneButton.clipsToBounds = true
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if (!self.isProfile) {
      let application = UIApplication.shared
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      appDelegate.registerForPushNotifications(application)
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.tabBarController?.tabBar.isHidden = false
  }

  func loadData() {
    activityIndicator.startAnimating()
    category.getCategories() { jsonArray in
      for category in jsonArray as! [[String: AnyObject]] {
        let id = category["id"] as! String
        let name = category["name"] as! String
        let url = category["resourceUrl"] as! String
        self.allCategories.append(CategoryModel(_id: id, _name: name, _url: url))
      }
      if (self.isProfile) {
        self.category.getInterest() { jsonArray in
          for element in jsonArray as! [[String:AnyObject]] {
            let mappingId = element["id"] as! String
            let catId = element["catId"] as! String
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

    var uid = UserDefaults.standard.string(forKey: "uid")
    uid = uid ?? self.uid!

    category.updateInterests(uid!, interests: categoriesToUpdate) { result in
      if (result.isEmpty) {
        DispatchQueue.main.async {
          if (self.isProfile) {
            _ = self.navigationController?.popViewController(animated: true)
          }
          else {
            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            UserDefaults.standard.synchronize()
            self.dismiss(animated: true, completion: nil)
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
}
extension InterestPickerViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (collectionView.frame.width - 30)/3
    return CGSize(width: width, height: width + 25)
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return allCategories.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! InterestCollectionViewCell
    let category = allCategories[indexPath.row]
    myCell.icon.sd_setImage(with: URL(string: category.url)!)
    myCell.name.text = category.name

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
  }
}

