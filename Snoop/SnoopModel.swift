//
//  SnoopModel.swift
//  Snoop
//
//  Created by Bowen Zhang on 9/3/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
class SnoopModel: QuandaModel {
  var isPlaying = false
  init(_name: String!, _title: String!, _avatarImage: NSData!, _id: Int!, _question: String!, _status: String!, _isPlaying: Bool!) {
    super.init(_name: _name, _title: _title, _avatarImage: _avatarImage, _id: _id, _question: _question, _status: _status)
    isPlaying = _isPlaying
  }

  override init(_name: String!, _title: String!, _avatarImage: NSData!, _id: Int!, _question: String!, _status: String!) {
    super.init(_name: _name, _title: _title, _avatarImage: _avatarImage, _id: _id, _question: _question, _status: _status)
    isPlaying = false
  }
}
