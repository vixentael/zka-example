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
  
  func encryptOwnPost(postBody: String) throws -> EncryptedData {
    return try encryptAnyPost(postBody: postBody, secretKey: mySecretKey())
  }
  
  func encryptAnyPost(postBody: String, secretKey: Key) throws -> EncryptedData {
    // TODO: implement encryption
    return EncryptedData(data: postBody.data(using: .utf8)!)
    
    // 1. create encryptor SecureCell with own secret key
    
    // 2. encrypt data
  }
  
  func decryptOwnPost(encryptedPost: EncryptedData) throws -> String {
    return try decryptAnyPost(encryptedPost: encryptedPost, secretKey: mySecretKey())
  }
}
