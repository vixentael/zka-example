//
//  EncryptionEngine+DecryptOtherPost.swift
//  SecurePostsExample
//
//  Created by Anastasiia on 6/15/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import Foundation

struct DecryptionOtherPostKeyPair {
  var encryptedSharedKey: String
  var publicKey: String
}


// MARK:- Decrypt somebody's post
extension EncryptionEngine {
  
  func hasKeysToDecryptSomebodyPost(user: String) -> DecryptionOtherPostKeyPair? {
    if let pk = self.publicKeys[user], let sk = self.encryptedSharedSKeys[user] {
      return DecryptionOtherPostKeyPair(encryptedSharedKey: sk, publicKey: pk)
    }
    return nil
  }
  
  func decryptSomebodyPost(encryptedPost: String, author: String) throws -> String {
    // 1. make sure we can decrypt user's SK
    guard let kp = hasKeysToDecryptSomebodyPost(user: author) else {
      throw EncryptionError.cantDecryptOtherPostNoKeys
    }
    
    // 2. decrypt SK
    let userSecretKey = try decryptSecretKeyFromUser(encryptedSecretKey: kp.encryptedSharedKey, userPublicKey: kp.publicKey)
    
    // 3. decrypt post
    return try decryptAnyPost(encryptedPost:encryptedPost, secretKey:userSecretKey)
  }
  
  func decryptAnyPost(encryptedPost: String, secretKey: String) throws -> String {
    let secretKeyData = dataFromString(string: secretKey)
    
    // 1. create decryptor with own secret key
    guard let data = secretKeyData, let cellSeal = TSCellSeal(key: data) else {
      print("Failed to decrypt post: error occurred while initializing object cellSeal")
      throw EncryptionError.cantCreateSecureCell
    }
    
    // 2. decode
    guard let encryptedPostData = dataFromString(string: encryptedPost) else {
      print("Failed to decrypt post: error occurred while decoding base64 encrypted post body")
      throw EncryptionError.cantDecodeEncryptedPostBody
    }
    
    // 3. decrypt
    var decryptedMessage: Data = Data()
    do {
      decryptedMessage = try cellSeal.unwrapData(encryptedPostData,
                                                 context: nil)
    } catch let error as NSError {
      print("Failed to decrypt post: error occurred while decrypting: \(error)")
      throw EncryptionError.cantDecryptPostBody
    }
    
    // 4. decode decrypted
    guard let decryptedBody = String(data: decryptedMessage, encoding: .utf8) else {
      print("Failed to decrypt post: error occurred while encoding decrypted post body")
      throw EncryptionError.cantEncodeDecryptedPostBody
    }
    return decryptedBody
  }
  
}
