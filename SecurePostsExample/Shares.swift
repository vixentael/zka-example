//
//  Shares.swift
//  SecurePostsExample
//
//  Created by Anastasiia on 6/14/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class Shares: NSObject {
    var uid: String
    var author: String
    var body: String
    
    init(uid: String, author: String, body: String) {
        self.uid = uid
        self.author = author
        self.body = body
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String:Any] else { return nil }
        guard let uid  = dict["uid"] as? String  else { return nil }
        guard let author = dict["author"]  as? String else { return nil }
        guard let body = dict["body"]  as? String else { return nil }
        
        self.uid = uid
        self.author = author
        self.body = body
    }
    
    convenience override init() {
        self.init(uid: "", author: "", body:  "")
    }
}
