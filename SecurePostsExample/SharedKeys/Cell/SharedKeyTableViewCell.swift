//
//  SharedKeyTableViewCell.swift
//  SecurePostsExample
//
//  Created by Anastasiia on 6/15/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseUI


@objc(SharedKeyTableViewCell)
class SharedKeyTableViewCell: UITableViewCell {
  
  @IBOutlet weak var authorImage: UIImageView!
  @IBOutlet weak var authorLabel: UILabel!
  @IBOutlet weak var recipientLabel: UILabel!
  @IBOutlet weak var postBody: UITextView!

}
