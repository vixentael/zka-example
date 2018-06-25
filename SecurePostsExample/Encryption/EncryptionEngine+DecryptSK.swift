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
    let myPrivateKeyData = try getMyPrivateKeyData()
    
    // 2. get other user public key
    guard let userPublicKeyData = dataFromString(string: userPublicKey) else {
      print("Error occurred while getting other party public key")
      throw EncryptionError.cantDecodeOtherUserPublicKey
    }
    
    // 3. create Asym decrypter using own private key and other user' public key
    guard let decrypter = TSMessage.init(inEncryptModeWithPrivateKey: myPrivateKeyData,
                                         peerPublicKey: userPublicKeyData) else {
                                          print("Error occurred while creating TSMessage Decryptor")
                                          throw EncryptionError.cantCreateSecureMessage
    }
    
    // 4. encode EncryptedSK from string to Data
    guard let encryptedSKData = dataFromString(string: encryptedSecretKey) else {
      print("Failed to decrypt somebody's SK: error occurred while decoding base64 encrypted SK")
      throw EncryptionError.cantDecodeEncryptedPostBody
    }
    
    // 5. decrypt own secret key for another user
    var decryptedSecretKeyData: Data = Data()
    do {
      decryptedSecretKeyData = try decrypter.unwrapData(encryptedSKData)
    } catch let error as NSError {
      print("Failed to decrypt somebody's SK: error occurred while decrypting: \(error)")
      throw EncryptionError.cantEncryptOwnSecretKey
    }
    
    // 6. encode decrypted
    guard let decryptedSKString = String(data: decryptedSecretKeyData, encoding: .utf8) else {
      print("Failed to decrypt somebody's SK: error occurred while decoding decrypted SK")
      throw EncryptionError.cantEncodeDecryptedPostBody
    }
    return decryptedSKString
  }
}

