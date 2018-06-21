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
  
  func encryptSecretKeyForUser(userPublicKey: String) throws -> String {
    // TODO: implement encryption of my secret key
    
    // 0. my own secret key
    
    // 1. get my private key
    
    // 2. get other user public key
    
    // 3. create Asym encryptor using own private key and other user' public key

    // 4. encrypt own secret key for another user
    
    // this line is fake, change it to real
    let encryptedSecretKey: Data = dataFromString(string: userPublicKey)!
    
    // 5. encode encrypted
    
    guard let escapedBase64URLEncodedSK = escapedBase64StringFrom(data: encryptedSecretKey) else {
      print("Failed to encrypt SK: Error occured while encoding encrypted SK to base64")
      throw EncryptionError.cantEncodeEncryptedPostBody
    }
    return escapedBase64URLEncodedSK
  }
}

