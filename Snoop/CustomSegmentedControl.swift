//
//  CustomSegmentedControl.swift
//  Snoop
//
//  Created by Bowen Zhang on 1/12/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit
protocol SegmentedControlDelegate {
  func loadIndex(index: Int)
}

class CustomSegmentedControl: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  let cellId = "controlCell"
  let controls = ["Questions", "Answers", "Snoops"]
  var delegate: SegmentedControlDelegate! = nil

  lazy var controlBar: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.scrollDirection = .Horizontal
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = UIColor.whiteColor()
    return collectionView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.frame = frame
    self.addSubview(controlBar)
    controlBar.registerClass(controlCell.self, forCellWithReuseIdentifier: self.cellId)
    controlBar.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
    controlBar.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
    controlBar.topAnchor.constraintEqualToAnchor(topAnchor).active = true
    controlBar.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true

    let selectedIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    controlBar.selectItemAtIndexPath(selectedIndexPath, animated: false, scrollPosition: .None)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 3
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellId, forIndexPath: indexPath) as! controlCell
    cell.controlName.text = controls[indexPath.row]
    return cell
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSizeMake(self.frame.width/3, self.frame.height)
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let index = indexPath.row
    delegate.loadIndex(index)
  }
}

class controlCell: UICollectionViewCell {
  let controlName: UILabel = {
    let control = UILabel()
    control.textColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
    control.textAlignment = .Center
    control.font = UIFont.systemFontOfSize(14)
    control.translatesAutoresizingMaskIntoConstraints = false
    return control
  }()

  let underline: UIView = {
    let line = UIView()
    line.backgroundColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
    line.translatesAutoresizingMaskIntoConstraints = false
    return line
  }()

  override var selected: Bool {
    didSet{
      controlName.textColor = selected ? UIColor.defaultColor() : UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
      underline.backgroundColor = selected ? UIColor.defaultColor() : UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.addSubview(controlName)
    self.addSubview(underline)

    // set contraints
    controlName.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    controlName.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
    controlName.widthAnchor.constraintEqualToAnchor(widthAnchor).active = true
    controlName.heightAnchor.constraintEqualToConstant(30).active = true

    underline.widthAnchor.constraintEqualToAnchor(widthAnchor).active = true
    underline.heightAnchor.constraintEqualToConstant(1).active = true
    underline.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
    underline.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
