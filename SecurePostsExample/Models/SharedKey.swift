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

class SharedKey: NSObject {
    var uid: String
    var author: String
    var recipient: String
    var encryptedSecret: String
    
    init(uid: String, author: String, recipient: String, encryptedSecret: String) {
        self.uid = uid
        self.author = author
        self.recipient = recipient
        self.encryptedSecret = encryptedSecret
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String:Any] else { return nil }
        guard let uid  = dict["uid"] as? String  else { return nil }
        guard let author = dict["author"]  as? String else { return nil }
        guard let recipient = dict["recipient"]  as? String else { return nil }
        guard let encryptedSecret = dict["encryptedSecret"]  as? String else { return nil }
        
        self.uid = uid
        self.author = author
        self.recipient = recipient
        self.encryptedSecret = encryptedSecret
    }
    
    convenience override init() {
        self.init(uid: "", author: "", recipient:  "", encryptedSecret:  "")
    }
}
