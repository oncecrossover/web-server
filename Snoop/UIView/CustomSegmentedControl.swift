//
//  CustomSegmentedControl.swift
//  Snoop
//
//  Created by Bowen Zhang on 1/12/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit
protocol SegmentedControlDelegate {
  func loadIndex(_ index: Int)
  func loadIndexWithRefresh(_ index: Int)
}

class CustomSegmentedControl: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  let cellId = "controlCell"
  let controls = ["Questions", "Answers", "Snoops"]
  var delegate: SegmentedControlDelegate! = nil

  lazy var controlBar: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.scrollDirection = .horizontal
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = UIColor.white
    return collectionView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.frame = frame
    self.addSubview(controlBar)
    controlBar.register(controlCell.self, forCellWithReuseIdentifier: self.cellId)
    controlBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    controlBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    controlBar.topAnchor.constraint(equalTo: topAnchor).isActive = true
    controlBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    NotificationCenter.default.addObserver(self, selector: #selector(reloadQuestions), name: NSNotification.Name(rawValue: "reloadQuestions"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(reloadAnswers), name: NSNotification.Name(rawValue: "reloadAnswers"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(reloadSnoops), name: NSNotification.Name(rawValue: "reloadSnoops"), object: nil)

    let selectedIndexPath = IndexPath(item: 0, section: 0)
    controlBar.selectItem(at: selectedIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
    let cell = controlBar.cellForItem(at: selectedIndexPath)
    cell?.isSelected = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func reloadQuestions() {
    delegate.loadIndexWithRefresh(0)
  }

  func reloadAnswers() {
    delegate.loadIndexWithRefresh(1)
  }

  func reloadSnoops() {
    delegate.loadIndexWithRefresh(2)
  }

  deinit {
    NotificationCenter.default.removeObserver(self) // app might crash without removing observer
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 3
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! controlCell
    cell.controlName.text = controls[indexPath.row]
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: self.frame.width/3, height: self.frame.height)
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let index = indexPath.row
    delegate.loadIndex(index)
  }
}

class controlCell: UICollectionViewCell {
  let controlName: UILabel = {
    let control = UILabel()
    control.textColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
    control.textAlignment = .center
    control.font = UIFont.systemFont(ofSize: 14)
    control.translatesAutoresizingMaskIntoConstraints = false
    return control
  }()

  let underline: UIView = {
    let line = UIView()
    line.backgroundColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
    line.translatesAutoresizingMaskIntoConstraints = false
    return line
  }()

  override var isSelected: Bool {
    didSet{
      controlName.textColor = isSelected ? UIColor.defaultColor() : UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
      underline.backgroundColor = isSelected ? UIColor.defaultColor() : UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.addSubview(controlName)
    self.addSubview(underline)

    // set contraints
    controlName.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    controlName.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    controlName.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    controlName.heightAnchor.constraint(equalToConstant: 30).isActive = true

    underline.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    underline.heightAnchor.constraint(equalToConstant: 1).isActive = true
    underline.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    underline.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
