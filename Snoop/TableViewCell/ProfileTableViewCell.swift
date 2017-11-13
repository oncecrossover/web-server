//
//  ProfileTableViewCell.swift
//  Snoop
//
//  Created by Bowen Zhang on 4/19/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  var expertise:[ExpertiseModel] = []
  var profileViewController: ProfileViewController?
  let cellId = "expertiseCell"

  let profilePhoto: UIImageView = {
    let view = CircleImageView()
    view.contentMode = .scaleAspectFill
    return view
  }()

  var avatarUrl: String?
  let nameLabel: UILabel = {
    let nameLabel = UILabel()
    nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
    nameLabel.textColor = UIColor(white: 0, alpha: 0.7)
    return nameLabel
  }()

  let aboutLabel: UILabel = {
    let aboutLabel = UILabel()
    aboutLabel.font = UIFont.systemFont(ofSize: 14)
    aboutLabel.textColor = UIColor(white: 0, alpha: 0.8)
    aboutLabel.numberOfLines = 2
    return aboutLabel
  }()

  let titleLabel: UILabel = {
    let titleLabel = UILabel()
    titleLabel.font = UIFont.systemFont(ofSize: 14)
    titleLabel.textColor = UIColor.secondaryTextColor()
    return titleLabel
  }()

  let followers: PairLabelView = {
    let view = PairLabelView()
    view.label.text = "followers"
    view.setAmount(fromInt: 0)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  let following: PairLabelView = {
    let view = PairLabelView()
    view.label.text = "following"
    view.setAmount(fromInt: 0)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  lazy var applyButton : UIButton = {
    let applyButton = CustomButton()
    applyButton.setTitle("Apply to Take Questions", for: UIControlState())
    applyButton.setTitle("Awaiting Approval", for: .disabled)
    applyButton.layer.cornerRadius = 4
    applyButton.clipsToBounds = true
    return applyButton
  }()

  lazy var expertiseCollection: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 6
    layout.minimumLineSpacing = 6
    let expertiseCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
    expertiseCollection.register(ExpertiseCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)
    expertiseCollection.delegate = self
    expertiseCollection.dataSource = self
    expertiseCollection.backgroundColor = UIColor.white
    expertiseCollection.allowsSelection = false
    return expertiseCollection
  }()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    backgroundColor = UIColor.white
    selectionStyle = .none
    addSubview(profilePhoto)
    addSubview(nameLabel)
    addSubview(titleLabel)
    addSubview(aboutLabel)
    addSubview(followers)
    addSubview(following)

    addConstraintsWithFormat("H:|-14-[v0(60)]-56-[v1(60)]-14-[v2(60)]", views: profilePhoto, followers, following)
    followers.topAnchor.constraint(equalTo: profilePhoto.topAnchor).isActive = true
    following.topAnchor.constraint(equalTo: followers.topAnchor).isActive = true

    addConstraintsWithFormat("H:|-14-[v0(60)]", views: profilePhoto)
    addConstraintsWithFormat("H:|-14-[v0]-14-|", views: nameLabel)
    addConstraintsWithFormat("H:|-14-[v0]-14-|", views: titleLabel)
    addConstraintsWithFormat("H:|-14-[v0]-14-|", views: aboutLabel)
    addConstraintsWithFormat("V:|-9-[v0(60)]-2-[v1(21)]-0-[v2(17)]-9-[v3(51)]", views: profilePhoto, nameLabel, titleLabel, aboutLabel)
    profilePhoto.awakeFromNib()
  }

  func handleApplyButton(status: String) {
    if (status == "APPROVED") {
      addSubview(expertiseCollection)
      addConstraintsWithFormat("H:|-14-[v0]-14-|", views: expertiseCollection)
      expertiseCollection.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 20).isActive = true
      expertiseCollection.heightAnchor.constraint(equalToConstant: 45).isActive = true
      self.expertise = []
      let uid = UserDefaults.standard.string(forKey: "uid")
      Category().getExpertise(uid!) { jsonArray in
        for element in jsonArray as! [[String:AnyObject]] {
          let mappingId = element["id"] as! String
          let catId = element["catId"] as! String
          let name = element["catName"] as! String
          self.expertise.append(ExpertiseModel(_id: mappingId, _catId: catId, _name: name))
        }

        self.profileViewController?.expertise = self.expertise
        DispatchQueue.main.async {
          self.expertiseCollection.reloadData()
        }
      }
    }
    else {
      addSubview(applyButton)
      addConstraintsWithFormat("H:|-14-[v0]-14-|", views: applyButton)
      applyButton.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 20).isActive = true
      applyButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
      if (status == "NA" || status.isEmpty) {
        applyButton.isEnabled = true
      }
      else {
        applyButton.isEnabled = false
      }
    }
  }

  // UICollection delegate, datasource, and flowlayout
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.expertise.count + 1
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! ExpertiseCollectionViewCell
    myCell.icon.font = UIFont.systemFont(ofSize: 12)
    if (indexPath.row == 0) {
      myCell.icon.text = "Ask me about:"
      myCell.icon.textColor = UIColor.secondaryTextColor()
      myCell.icon.layer.borderWidth = 0
    }
    else {
      myCell.icon.text = expertise[indexPath.row - 1].name
      myCell.icon.layer.borderWidth = 1
      myCell.isSelected = true
    }

    myCell.clipsToBounds = true
    return myCell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    var name = "Ask me about:" as NSString
    if (indexPath.row > 0) {
      let category = expertise[indexPath.row - 1]
      name = category.name as NSString
    }

    let estimatedSize = name.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)])
    return CGSize(width: estimatedSize.width + 8, height: 18)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
