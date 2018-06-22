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
    
    // 1. get my private key
    let myPrivateKey = try getMyPrivateKey()

    // 3. create Asym decrypter using own private key and other user' public key
    guard let decrypter = TSMessage.init(inEncryptModeWithPrivateKey: myPrivateKey.data,
                                         peerPublicKey: userPublicKey.data) else {
                                          print("Error occurred while creating TSMessage Decryptor")
                                          throw EncryptionError.cantCreateSecureMessage
    }

    // 5. decrypt own secret key for another user
    let decryptedSecretKey: Data
    do {
      decryptedSecretKey = try decrypter.unwrapData(encryptedSecretKey.data)
    } catch let error as NSError {
      print("Failed to decrypt somebody's SK: error occurred while decrypting: \(error)")
      throw EncryptionError.cantEncryptOwnSecretKey
    }
    
    // 6. encode decrypted
    guard let decryptedSKString = String(data: decryptedSecretKey, encoding: .utf8) else {
      print("Failed to decrypt somebody's SK: error occurred while decoding decrypted SK")
      throw EncryptionError.cantEncodeDecryptedPostBody
    }
    return decryptedSKString
  }
}

