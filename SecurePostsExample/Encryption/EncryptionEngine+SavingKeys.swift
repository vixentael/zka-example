//
//  EncryptionEngine(SavingKeys).swift
//  SecurePostsExample
//
//  Created by Anastasiia on 6/15/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import Foundation

// MARK: - SavingKeys
extension EncryptionEngine {
  
  func rememberPublicKey(user: String, publicKey: String) {
    self.publicKeys[user] = publicKey
  }
  
  func rememberSharedKey(user: String, sharedKey: String) {
    self.encryptedSharedSKeys[user] = sharedKey
  }
  
}
