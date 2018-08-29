//
//  EncryptionEngine+EncryptSK.swift
//  SecurePostsExample
//
//  Created by Anastasiia on 6/15/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import Foundation

// MARK: - Encrypt My Secret Key
extension EncryptionEngine {
  
  func encryptSecretKeyForUser(userPublicKey: Key) throws -> EncryptedData {
    // TODO: implement encryption
    return EncryptedData(data: userPublicKey.data)
    
    // 1. get my private key
    
    // 2. create Asym encryptor using own private key and other user' public key

    
    // 3. encrypt own secret key for another user
  }
}

