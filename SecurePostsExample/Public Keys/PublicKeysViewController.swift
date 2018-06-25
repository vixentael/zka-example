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
import FirebaseAuth
import FirebaseUI

@objc(PublicKeysViewController)
class PublicKeysViewController: UIViewController, UITableViewDelegate {
  
  // [START define_database_reference]
  var ref: DatabaseReference!
  // [END define_database_reference]
  
  var encryptionEngine = EncryptionEngine.sharedInstance
  var dataSource: FUITableViewDataSource?
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // [START create_database_reference]
    ref = Database.database().reference()
    // [END create_database_reference]
    
    let identifier = "post"
    let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: identifier)
    
    dataSource = FUITableViewDataSource(query: getQuery()) { (tableView, indexPath, snap) -> UITableViewCell in
      let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! PostTableViewCell
      
      guard let publicKey = PublicKey(snapshot: snap) else { return cell }
      cell.authorImage.image = UIImage(named: "ic_account_circle")
      cell.authorLabel.text = publicKey.author
      cell.postBody.text = publicKey.body
      
      cell.starButton.isHidden = true
      cell.numStarsLabel.isHidden = true
      cell.postTitle.isHidden = true
      
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
    guard let publicKeyModel = PublicKey(snapshot: dataSource.snapshot(at: indexPath.row)) else { return }
    
    let publicKey = publicKeyModel.body
    let author = publicKeyModel.author
    
    let pasteBoard = UIPasteboard.general
    pasteBoard.string = publicKey
    
    self.showMessagePrompt("Public key is saved, and copied to clipboard")
    
    self.encryptionEngine.rememberPublicKey(user: author, publicKey: Key(base64String: publicKey)!)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 150
  }
  
  func getUid() -> String {
    return (Auth.auth().currentUser?.uid)!
  }
  
  func getQuery() -> DatabaseQuery {
    let sharedKeysQuery = (ref?.child("public-keys")
      .queryOrdered(byChild: "timestamp") // not working
      .queryLimited(toFirst: 10))!
    return sharedKeysQuery
  }
  
  //  override func viewWillDisappear(_ animated: Bool) {
  //    super.viewWillDisappear(animated)
  //    getQuery().removeAllObservers()
  //  }
}
