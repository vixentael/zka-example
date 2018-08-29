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
  
  func decryptSecretKeyFromUser(encryptedSecretKey: EncryptedData, userPublicKey: Key) throws -> String {
    // TODO: implement decryption
    
    return encryptedSecretKey.base64String
    
    // 1. get my private key
    

    // 2. create Asym decrypter using own private key and other user' public key


    // 3. decrypt own secret key for another user

    
    // 4. encode decrypted

  }
}

