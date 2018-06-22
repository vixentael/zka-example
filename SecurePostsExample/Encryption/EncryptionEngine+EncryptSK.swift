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
    // 1. get my private key
    let myPrivateKey = try getMyPrivateKey()
    
    // 3. create Asym encryptor using own private key and other user' public key
    guard let encrypter = TSMessage.init(inEncryptModeWithPrivateKey: myPrivateKey.data,
                                         peerPublicKey: userPublicKey.data) else {
                                          print("Error occurred while creating TSMessage Encryptor")
                                          throw EncryptionError.cantCreateSecureMessage
    }
    
    
    // 4. encrypt own secret key for another user
    do {
        return EncryptedData(data: try encrypter.wrap(mySecretKey().data))
    } catch let error as NSError {
      print("Failed to encrypt own SK: error occurred while encrypting: \(error)")
      throw EncryptionError.cantEncryptOwnSecretKey
    }
  }
}

