//
//  ProfileView.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/12/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class ProfileView: UIView {
  let profileImage: UIImageView = {
    let view = CircleImageView()
    view.contentMode = .scaleAspectFill
    return view
  }()

  let name: UILabel = {
    let name = UILabel()
    name.font = UIFont.boldSystemFont(ofSize: 18)
    name.textColor = UIColor(white: 0, alpha: 0.7)
    return name
  }()

  let title: UILabel = {
    let title = UILabel()
    title.textColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 0.75)
    title.font = UIFont.systemFont(ofSize: 14)
    return title
  }()

  let about: UILabel = {
    let about = UILabel()
    about.numberOfLines = 3
    about.font = UIFont.systemFont(ofSize: 14)
    about.textColor = UIColor(white: 0, alpha: 0.8)
    return about
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

  let cellId = "expertiseCell"
  var expertise:[ExpertiseModel] = []

  init(frame: CGRect, uid: String) {
    super.init(frame: frame)
    self.frame = frame
    backgroundColor = UIColor.white
    addSubview(profileImage)
    addSubview(name)
    addSubview(title)
    addSubview(about)
    addSubview(expertiseCollection)

    addConstraintsWithFormat("H:|-14-[v0(60)]", views: profileImage)
    addConstraintsWithFormat("H:|-14-[v0]-14-|", views: name)
    addConstraintsWithFormat("H:|-14-[v0]-14-|", views: title)
    addConstraintsWithFormat("H:|-14-[v0]-14-|", views: about)
    addConstraintsWithFormat("H:|-14-[v0]-14-|", views: expertiseCollection)

    addConstraintsWithFormat("V:|-8-[v0(60)]-2-[v1(21)]-0-[v2(17)]-9-[v3(51)]-7-[v4]-8-|", views: profileImage, name, title, about, expertiseCollection)
    profileImage.awakeFromNib()

    Category().getExpertise(uid) { jsonArray in
      for element in jsonArray as! [[String:AnyObject]] {
        let mappingId = element["id"] as! String
        let catId = element["catId"] as! String
        let name = element["catName"] as! String
        self.expertise.append(ExpertiseModel(_id: mappingId, _catId: catId, _name: name))
      }

      DispatchQueue.main.async {
        self.expertiseCollection.reloadData()
      }
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.endEditing(true)
  }
}

extension ProfileView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
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
}












