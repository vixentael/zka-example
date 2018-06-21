//
//  EncryptionEngine+DecryptSK.swift
//  SecurePostsExample
//
//  Created by Anastasiia on 6/15/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import Foundation

// MARK: - Decrypt Somebody's Secret Key
extension EncryptionEngine {
  
  func decryptSecretKeyFromUser(encryptedSecretKey: String, userPublicKey: String) throws -> String {
    
    // 1. get my private key
    
    // 2. get other user public key

    // 3. create Asym decrypter using own private key and other user' public key

    // 4. encode EncryptedSK from string to Data
    
    // 5. decrypt own secret key for another user
    
    // this line is fake, change it to real
    let decryptedSecretKey = dataFromString(string: encryptedSecretKey)!

    // 6. encode decrypted
    guard let decryptedSKString = String(data: decryptedSecretKey, encoding: .utf8) else {
      print("Failed to decrypt somebody's SK: error occurred while decoding decrypted SK")
      throw EncryptionError.cantEncodeDecryptedPostBody
    }
    return decryptedSKString
  }
}

