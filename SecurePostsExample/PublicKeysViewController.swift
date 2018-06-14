//
//  PublicKeysViewController.swift
//  SecurePostsExample
//
//  Created by Anastasiia on 6/14/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

@objc(PublicKeysViewController)
class PublicKeysViewController: PostListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.navigationItem.title = "Public Keys"
    }
    
    override func getQuery() -> DatabaseQuery {
        return (ref?.child("user-posts").child(getUid()))!
    }
}
