//
//  EditProfileView.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/26/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class EditProfileView: UIScrollView {
  lazy var profilePhoto: UIImageView = {
    let photo = UIImageView()
    photo.layer.cornerRadius = 33
    photo.clipsToBounds = true
    photo.contentMode = .scaleAspectFill
    return photo
  }()

  lazy var changeButton: UIButton = {
    let button = UIButton()
    button.setBackgroundImage(UIImage(named: "change"), for: UIControlState())
    return button
  }()

  lazy var firstName: FieldGroup = {
    let firstName = FieldGroup()
    firstName.title.text = "First Name"
    firstName.limit.text = "20"
    return firstName
  }()

  lazy var lastName: FieldGroup = {
    let lastName = FieldGroup()
    lastName.title.text = "Last Name"
    lastName.limit.text = "20"
    return lastName
  }()

  lazy var title: FieldGroup = {
    let title = FieldGroup()
    title.title.text = "Title"
    title.limit.text = "30"
    return title
  }()

  lazy var about: ViewGroup = {
    let about = ViewGroup()
    about.title.text = "Description"
    about.limit.text = "80"
    return about
  }()

  lazy var rate : RateFieldGroup = {
    let rate = RateFieldGroup()
    rate.title.text = "Answer a question for $"
    rate.value.keyboardType = .numberPad
    rate.value.inputAccessoryView = rate.keyboardToolbarView

    return rate
  }()

  lazy var expertise: CollectionGroup = {
    let expertise = CollectionGroup()
    return expertise
  }()

  func fillValues(_ avatarUrl: String?, firstName: String, lastName: String, title: String, about: String){
    if let _  = avatarUrl {
      self.profilePhoto.sd_setImage(with: URL(string: avatarUrl!))
    }
    else {
      self.profilePhoto.image = UIImage(named: "default")
    }

    self.firstName.value.text = firstName
    self.lastName.value.text = lastName
    self.title.value.text = title
    if (about.isEmpty) {
      self.about.value.text = "Add a short description of your expertise and your interests"
      self.about.value.textColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1.0)
    }
    else {
      self.about.value.text = about
      self.about.value.textColor = UIColor.black
    }
  }

  func fillRate(_ rate: Int) {
    self.rate.value.text = String(rate)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.endEditing(true)
  }

  init(frame: CGRect, includeExpertise: Bool, selectedExpertise: [ExpertiseModel]) {
    super.init(frame: frame)

    addSubview(profilePhoto)
    addSubview(changeButton)
    addSubview(firstName)
    addSubview(lastName)
    addSubview(title)
    addSubview(about)
    let width = frame.width - 30

    // Setup Horizontal Constraints
    addConstraintsWithFormat("H:|-15-[v0(66)]-6-[v1(60)]", views: profilePhoto, changeButton)
    addConstraintsWithFormat("H:|-15-[v0(\(width))]-15-|", views: firstName)
    addConstraintsWithFormat("H:|-15-[v0(\(width))]-15-|", views: lastName)
    addConstraintsWithFormat("H:|-15-[v0(\(width))]-15-|", views: title)
    addConstraintsWithFormat("H:|-15-[v0(\(width))]-15-|", views: about)

    if (includeExpertise) {
      addSubview(rate)
      addSubview(expertise)

      // Setup constraints
      addConstraintsWithFormat("H:|-15-[v0(\(width))]-15-|", views: rate)
      addConstraintsWithFormat("H:|-15-[v0(\(width))]-15-|", views: expertise)
      addConstraintsWithFormat("V:|-12-[v0(66)]-28-[v1(50)]-4-[v2(50)]-4-[v3(50)]-4-[v4(120)]-4-[v5(50)]-4-[v6(84)]-4-|", views: profilePhoto, firstName, lastName, title, about, rate, expertise)
      let category = Category()
      category.getCategories() { jsonArray in
        for category in jsonArray as! [[String: AnyObject]] {
          let id = category["id"] as! Int
          let name = category["name"] as! String
          let url = category["resourceUrl"] as! String
          self.expertise.allCategories.append(CategoryModel(_id: id, _name: name, _url: url))
        }

        DispatchQueue.main.async {
          self.expertise.oldSelectedCategories = selectedExpertise
          self.expertise.expertiseCollection.reloadData()
          self.expertise.populateSelectedCells()
        }

      }
    }
    else {
      addConstraintsWithFormat("V:|-12-[v0(66)]-28-[v1(50)]-4-[v2(50)]-4-[v3(50)]-4-[v4(120)]-150-|", views: profilePhoto, firstName, lastName, title, about)
    }
    changeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
    changeButton.centerYAnchor.constraint(equalTo: profilePhoto.centerYAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class FieldGroup: UIView {
  let title: UILabel = {
    let title = UILabel()
    title.textColor = UIColor(red: 163/255, green: 163/255, blue: 163/255, alpha: 1.0)
    title.font = UIFont.systemFont(ofSize: 12)
    return title
  }()

  let value: UITextField = {
    let value = InteractiveUITextField()
    value.awakeFromNib()
    value.borderStyle = .none
    value.textColor = UIColor.black
    value.font = UIFont.systemFont(ofSize: 16)
    return value
  }()

  let underline: UIView = {
    let line = UIView()
    line.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.8)
    return line
  }()

  let limit: UILabel = {
    let limit = UILabel()
    limit.font = UIFont.systemFont(ofSize: 14)
    limit.textAlignment = .center
    limit.textColor = UIColor.defaultColor()
    limit.isHidden = true
    return limit
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.frame = frame
    backgroundColor = UIColor.clear

    addSubview(title)
    addSubview(value)
    addSubview(underline)
    addSubview(limit)

    // Setup constraints
    addConstraintsWithFormat("H:|[v0]|", views: title)
    addConstraintsWithFormat("H:|[v0]-4-[v1(30)]|", views: value, limit)
    addConstraintsWithFormat("H:|[v0]|", views: underline)
    addConstraintsWithFormat("V:|[v0(17)]-0-[v1(22)]-8-[v2(1)]", views: title, value, underline)
    addConstraintsWithFormat("V:|[v0(17)]-2-[v1(20)]", views: title, limit)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class RateFieldGroup : FieldGroup {
  let keyboardToolbarView : UIToolbar = {
    /* add done button */
    let view = UIToolbar.init()
    view.sizeToFit()
    /* make done button right most */
    let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
                                     target: nil,
                                     action: nil)
    let doneButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done,
                                          target: self,
                                          action: #selector(valueNumberPadDoneTapped))
    doneButton.tintColor = UIColor.black;
    view.items = [flexButton, doneButton]
    return view
  }()

  func valueNumberPadDoneTapped(sender: AnyObject) {
    super.value.endEditing(true)
  }
}

class ViewGroup: UIView {
  let title: UILabel = {
    let title = UILabel()
    title.textColor = UIColor(red: 163/255, green: 163/255, blue: 163/255, alpha: 1.0)
    title.font = UIFont.systemFont(ofSize: 12)
    return title
  }()

  let value: UITextView = {
    let value = UITextView()
    value.textColor = UIColor.black
    value.font = UIFont.systemFont(ofSize: 16)
    return value
  }()

  let underline: UIView = {
    let line = UIView()
    line.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.8)
    return line
  }()

  let limit: UILabel = {
    let limit = UILabel()
    limit.font = UIFont.systemFont(ofSize: 14)
    limit.textAlignment = .center
    limit.textColor = UIColor.defaultColor()
    limit.isHidden = true
    return limit
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.frame = frame
    backgroundColor = UIColor.clear

    addSubview(title)
    addSubview(value)
    addSubview(underline)
    addSubview(limit)

    // Setup constraints
    addConstraintsWithFormat("H:|[v0]|", views: title)
    addConstraintsWithFormat("H:|[v0]-4-[v1(30)]|", views: value, limit)
    addConstraintsWithFormat("H:|[v0]|", views: underline)
    addConstraintsWithFormat("V:|[v0(17)]-0-[v1(120)]-8-[v2(1)]", views: title, value, underline)
    addConstraintsWithFormat("V:[v0(20)]-2-[v1(1)]|", views: limit, underline)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class CollectionGroup: UIView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
  var allCategories: [CategoryModel] = []
  var oldSelectedCategories: [ExpertiseModel] = []
  var newSelectedCategories: Set<ExpertiseModel> = []
  var deselectedCategories: Set<ExpertiseModel> = []

  let title: UILabel = {
    let title = UILabel()
    title.textColor = UIColor(red: 163/255, green: 163/255, blue: 163/255, alpha: 1.0)
    title.font = UIFont.systemFont(ofSize: 12)
    title.text = "Ask Me About"
    return title
  }()

  let cellId = "expertiseCell"

  lazy var expertiseCollection: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 6
    layout.minimumInteritemSpacing = 6
    let expertise = UICollectionView(frame: .zero, collectionViewLayout: layout)
    expertise.register(ExpertiseCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)
    expertise.dataSource = self
    expertise.delegate = self
    expertise.backgroundColor = UIColor.clear
    expertise.allowsMultipleSelection = true
    return expertise
  }()

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let category = allCategories[indexPath.row]
    let name = category.name as NSString
    let estimatedSize = name.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)])
    return CGSize(width: estimatedSize.width + 8, height: 27)
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return allCategories.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! ExpertiseCollectionViewCell
    let category = allCategories[indexPath.row]
    myCell.icon.text = category.name
    return myCell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let category = allCategories[indexPath.row]
    let expertise = ExpertiseModel(_catId: category.id, _name: category.name)
    if (deselectedCategories.contains(expertise)) {
      deselectedCategories.remove(expertise)
    }
    else {
      newSelectedCategories.insert(expertise)
    }

  }

  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    let category = allCategories[indexPath.row]
    let expertise = ExpertiseModel(_catId: category.id, _name: category.name)
    if (newSelectedCategories.contains(expertise)) {
      newSelectedCategories.remove(expertise)
    }
    else {
      deselectedCategories.insert(expertise)
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
      interest["isExpertise"] = "Yes" as AnyObject?
      categoriesToUpdate.append(interest)
    }

    for category in deselectedCategories {
      var interest: [String: AnyObject] = [:]
      if let _ = category.id {
        interest["id"] = category.id as AnyObject?
      }

      interest["catId"] = category.catId as AnyObject?
      interest["isExpertise"] = "No" as AnyObject?
      categoriesToUpdate.append(interest)
    }

    return categoriesToUpdate
  }

  func populateSelectedCells() {
    for (index, item) in allCategories.enumerated() {
      for expertise in oldSelectedCategories {
        if (item.id == expertise.catId) {
          expertiseCollection.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
        }
      }
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.clear
    addSubview(title)
    addSubview(expertiseCollection)

    // Setup constraints
    addConstraintsWithFormat("H:|[v0]|", views: title)
    addConstraintsWithFormat("H:|[v0]|", views: expertiseCollection)
    addConstraintsWithFormat("V:|[v0(17)]-6-[v1(60)]", views: title, expertiseCollection)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
