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
  
  func encryptOwnPost(body: String) throws -> EncryptedData {
    
    // 1. create encryptor SecureCell with own secret key
    guard let cellSeal = TSCellSeal(key: mySecretKey().data) else {
      print("Failed to encrypt post: error occurred while initializing object cellSeal")
      throw EncryptionError.cantCreateSecureCell
    }
    
    // 2. encrypt data
    let encryptedMessage: Data
    do {
      encryptedMessage = try cellSeal.wrap(body.data(using: .utf8)!,
                                           context: nil)
    } catch let error as NSError {
      print("Failed to encrypt post: error occurred while encrypting body \(error)")
      throw EncryptionError.cantEncryptPostBody
    }

    return EncryptedData(data: encryptedMessage)
  }
  
  func decryptOwnPost(encryptedPost: EncryptedData) throws -> String {
    return try decryptAnyPost(encryptedPost: encryptedPost, secretKey: mySecretKey())
  }
}
