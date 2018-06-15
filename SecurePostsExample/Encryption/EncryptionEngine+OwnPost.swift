//
//  EncryptionEngine(Post).swift
//  SecurePostsExample
//
//  Created by Anastasiia on 6/15/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import Foundation


// MARK: - Encrypt/Decrypt Own Posts
extension EncryptionEngine {
  
  func encryptOwnPost(body: String) throws -> String {
    let mySecretKeyData = dataFromString(string: mySecretKey())
    
    // 1. create encryptor with own secret key
    guard let data = mySecretKeyData, let cellSeal = TSCellSeal(key: data) else {
      print("Failed to encrypt post: error occurred while initializing object cellSeal")
      throw EncryptionError.cantCreateSecureCell
    }
    
    // 2. encrypt
    var encryptedMessage: Data = Data()
    do {
      encryptedMessage = try cellSeal.wrap(body.data(using: .utf8)!,
                                           context: nil)
    } catch let error as NSError {
      print("Failed to encrypt post: error occurred while encrypting body \(error)")
      throw EncryptionError.cantEncryptPostBody
    }
    
    // 3. encode encrypted
    guard let escapedBase64URLEncodedMessage = escapedBase64StringFrom(data: encryptedMessage) else {
      print("Failed to encrypt post: Error occured while encoding encrypted message to base64")
      throw EncryptionError.cantEncodeEncryptedPostBody
    }
    return escapedBase64URLEncodedMessage
  }
  
  func decryptOwnPost(encryptedPost: String) throws -> String {
    return try decryptAnyPost(encryptedPost: encryptedPost, secretKey: mySecretKey())
  }
}
