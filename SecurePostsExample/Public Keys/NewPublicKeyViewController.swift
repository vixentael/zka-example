//
//  NewPublicKeyViewController.swift
//  SecurePostsExample
//
//  Created by Anastasiia on 6/14/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseUI

@objc(NewPublicKeyViewController)
class NewPublicKeyViewController: UIViewController, UITextFieldDelegate {
    
    var ref: DatabaseReference!
    @IBOutlet weak var bodyTextView: UITextView!
  
    var encryptionEngine = EncryptionEngine.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.navigationItem.title = "Add Public Key"
        
        // [START create_database_reference]
        self.ref = Database.database().reference()
        // [END create_database_reference]
      
        let doneBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        doneBar.isTranslucent = false
        doneBar.barTintColor = UIColor.purple
        doneBar.autoresizingMask = .flexibleWidth
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(didTapPost))
        done.tintColor = UIColor.yellow
        doneBar.items  = [flex, done, flex]
        doneBar.sizeToFit()
        bodyTextView.inputAccessoryView = doneBar
      
        // POST MY OWN PUBLIC KEY
        var bodyText = ""
        if let myPubKey = try? encryptionEngine.getMyPublicKey() {
          bodyText = myPubKey.base64String
        }
        
        bodyTextView.text = bodyText
        bodyTextView.isEditable = false
    }
    
    @IBAction func didTapPost(_ sender: AnyObject) {
        // [START single_value_read]
        let userID = Auth.auth().currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? ""
            let user = AppUser(username: username)
            
            // [START_EXCLUDE]
            // Write new PK
            self.writeNewPublicKey(withUserID: userID!, username: user.username, body: self.bodyTextView.text)
            // Finish this Activity, back to the stream
            _ = self.navigationController?.popViewController(animated: true)
            // [END_EXCLUDE]
        }) { (error) in
            print(error.localizedDescription)
        }
        // [END single_value_read]
    }
    
    func writeNewPublicKey(withUserID userID: String, username: String, body: String) {
        // Create new post at /user-posts/$userid/$postid and at
        // /posts/$postid simultaneously
        // [START write_fan_out]
        let key = ref.child("public-keys").childByAutoId().key
        let publicKey = ["uid": userID,
                     "author": username,
                     "body": body] as [String : Any]
        let childUpdates = ["/public-keys/\(key)": publicKey,
                            "/user-public-keys/\(userID)/\(key)/": publicKey]
        ref.updateChildValues(childUpdates)
        // [END write_fan_out]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
