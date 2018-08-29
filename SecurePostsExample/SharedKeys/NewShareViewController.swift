//
//  Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseUI

@objc(NewShareViewController)
class NewShareViewController: UIViewController, UITextFieldDelegate {

  var ref: DatabaseReference!
  var encryptionEngine = EncryptionEngine.sharedInstance
  
  @IBOutlet weak var recipientPublicKeyTextView: UITextView!
  @IBOutlet weak var recipientTextField: UITextField!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tabBarController?.navigationItem.title = "Add Shared Key"

    // [START create_database_reference]
    self.ref = Database.database().reference()
    // [END create_database_reference]

    let doneBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
    doneBar.isTranslucent = false
    doneBar.barTintColor = UIColor.purple
    doneBar.autoresizingMask = .flexibleWidth
    let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let done = UIBarButtonItem(title: "Share my SecretKey", style: .plain, target: self, action: #selector(didTapPost))
    done.tintColor = UIColor.yellow
    doneBar.items  = [flex, done, flex]
    doneBar.sizeToFit()
    
    recipientPublicKeyTextView.inputAccessoryView = doneBar
    recipientTextField.inputAccessoryView = doneBar
  }

  @IBAction func didTapPost(_ sender: AnyObject) {
    // [START single_value_read]
    let userID = Auth.auth().currentUser?.uid
    ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
      // Get user value
      let value = snapshot.value as? NSDictionary
      let username = value?["username"] as? String ?? ""
      let user = AppUser(username: username)

      let recipientUserName = self.recipientTextField.text
      let recipientPublicKey = self.recipientPublicKeyTextView.text
      
      // ENCRYPT OWN SK FOR RECIPIENT
      var encryptedSKToSend = "Error in encrypting SK for user name \(String(describing: recipientUserName)), probably Public Key is not Base64"
      if let recipientPublicKey = recipientPublicKey,
        let pk = Key(base64String: recipientPublicKey),
        let encryptedSK = try? self.encryptionEngine.encryptSecretKeyForUser(userPublicKey: pk) {
        encryptedSKToSend = encryptedSK.base64String
      }
      
      // [START_EXCLUDE]
      // Write new share
      self.writeNewShare(withUserID: userID!, author: user.username,
                         recipient: recipientUserName,
                         body: encryptedSKToSend)
      // Finish this Activity, back to the stream
      _ = self.navigationController?.popViewController(animated: true)
      // [END_EXCLUDE]
      }) { (error) in
        print(error.localizedDescription)
    }
    // [END single_value_read]
  }

  func writeNewShare(withUserID userID: String, author: String, recipient: String?, body: String) {
    // Create new post at /user-posts/$userid/$postid and at
    // /posts/$postid simultaneously
    // [START write_fan_out]
    let key = ref.child("shared-keys").childByAutoId().key
    let share = ["uid": userID,
                "author": author,
                "recipient": recipient,
                "encryptedSecret": body]
    let childUpdates = ["/shared-keys/\(key)": share,
                        "/user-shared-keys/\(userID)/\(key)/": share]
    ref.updateChildValues(childUpdates)
    // [END write_fan_out]
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}
