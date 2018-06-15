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

@objc(SharedKeysViewController)
class SharedKeysViewController: UIViewController, UITableViewDelegate {
  
  // [START define_database_reference]
  var ref: DatabaseReference!
  // [END define_database_reference]
  
  var dataSource: FUITableViewDataSource?
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // [START create_database_reference]
    ref = Database.database().reference()
    // [END create_database_reference]
    
    let identifier = "sharedKey"
    let nib = UINib(nibName: "SharedKeyTableViewCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: identifier)
    
    dataSource = FUITableViewDataSource(query: getQuery()) { (tableView, indexPath, snap) -> UITableViewCell in
      let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SharedKeyTableViewCell
      
      guard let sharedKey = SharedKey(snapshot: snap) else { return cell }
      cell.authorImage.image = UIImage(named: "ic_account_circle")
      cell.authorLabel.text = sharedKey.author
      cell.recipientLabel.text = sharedKey.recipient
      cell.postBody.text = sharedKey.encryptedSecret
      return cell
    }
    
    dataSource?.bind(to: tableView)
    tableView.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let dataSource = dataSource else { return }
    guard let sharedKey = SharedKey(snapshot: dataSource.snapshot(at: indexPath.row)) else { return }
    
    let encryptedKey = sharedKey.encryptedSecret
    let author = sharedKey.author
    let recipient = sharedKey.recipient
    
    // TODO: use this encrypted key to decrypt message by author
    
    let pasteBoard = UIPasteboard.general
    pasteBoard.string = encryptedKey
    
    self.showMessagePrompt("Encrypted SK is copied to clipboard")
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 150
  }
  
  func getUid() -> String {
    return (Auth.auth().currentUser?.uid)!
  }
  
  func getQuery() -> DatabaseQuery {
    let sharedKeysQuery = (ref?.child("shared-keys").queryLimited(toFirst: 10))!
    return sharedKeysQuery
  }
  
  //  override func viewWillDisappear(_ animated: Bool) {
  //    super.viewWillDisappear(animated)
  //    getQuery().removeAllObservers()
  //  }
}
