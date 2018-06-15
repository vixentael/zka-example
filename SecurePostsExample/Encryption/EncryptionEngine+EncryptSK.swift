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
    // 0. my own secret key
    let mySecretKey = self.mySecretKey()
    
    // 1. get my private key
    let myPrivateKey = try getMyPrivateKeyData()
    
    // 2. get other user public key
    guard let otherUserPublicKey = dataFromString(string: userPublicKey) else {
      print("Error occurred while getting other party public key")
      throw EncryptionError.cantDecodeOtherUserPublicKey
    }
    
    // 3. create Asym encryptor using own private key and other user' public key
    guard let encrypter = TSMessage.init(inEncryptModeWithPrivateKey: myPrivateKey,
                                         peerPublicKey: otherUserPublicKey) else {
                                          print("Error occurred while creating TSMessage Encryptor")
                                          throw EncryptionError.cantCreateSecureMessage
    }
    
    // 4. encrypt own secret key for another user
    var encryptedSecretKey: Data = Data()
    do {
      encryptedSecretKey = try encrypter.wrap(mySecretKey.data(using: .utf8))
    } catch let error as NSError {
      print("Failed to encrypt own SK: error occurred while encrypting: \(error)")
      throw EncryptionError.cantEncryptOwnSecretKey
    }
    
    // 5. encode encrypted
    guard let escapedBase64URLEncodedSK = escapedBase64StringFrom(data: encryptedSecretKey) else {
      print("Failed to encrypt SK: Error occured while encoding encrypted SK to base64")
      throw EncryptionError.cantEncodeEncryptedPostBody
    }
    return escapedBase64URLEncodedSK
  }
}

