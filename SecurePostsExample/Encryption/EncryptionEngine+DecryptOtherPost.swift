//
//  EncryptionEngine+DecryptOtherPost.swift
//  SecurePostsExample
//
//  Created by Anastasiia on 6/15/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import Foundation

struct DecryptionOtherPostKeyPair {
  var encryptedSharedKey: EncryptedData
  var publicKey: Key
}


// MARK:- Decrypt somebody's post
extension EncryptionEngine {
  
  func hasKeysToDecryptSomebodyPost(user: String) -> DecryptionOtherPostKeyPair? {
    if let pk = self.publicKeys[user], let sk = self.encryptedSharedSKeys[user] {
      return DecryptionOtherPostKeyPair(encryptedSharedKey: sk, publicKey: pk)
    }
    return nil
  }
  
  func decryptSomebodyPost(encryptedPost: EncryptedData, author: String) throws -> String {
    // 1. make sure we can decrypt user's SK
    guard let kp = hasKeysToDecryptSomebodyPost(user: author) else {
      throw EncryptionError.cantDecryptOtherPostNoKeys
    }
    
    // 2. decrypt SK
    let userSecretKey = Key(string:
        try decryptSecretKeyFromUser(
            encryptedSecretKey: kp.encryptedSharedKey,
            userPublicKey: kp.publicKey)
        )!
    
    // 3. decrypt post
    return try decryptAnyPost(encryptedPost:encryptedPost, secretKey:userSecretKey)
  }
  
  func decryptAnyPost(encryptedPost: EncryptedData, secretKey: Key) throws -> String {
    // 1. create decryptor with own secret key
    guard let cellSeal = TSCellSeal(key: secretKey.data) else {
        print("Failed to decrypt post: error occurred while initializing object cellSeal")
        throw EncryptionError.cantCreateSecureCell
    }

    // 2. decrypt encryptedPost
    var decryptedMessage: Data = Data()
    do {
      decryptedMessage = try cellSeal.unwrapData(encryptedPost.data,
                                                 context: nil)
    } catch let error as NSError {
      print("Failed to decrypt post: error occurred while decrypting: \(error)")
      throw EncryptionError.cantDecryptPostBody
    }
    
    // 3. encode decrypted post from Data to String
    guard let decryptedBody = String(data: decryptedMessage, encoding: .utf8) else {
      print("Failed to decrypt post: error occurred while encoding decrypted post body")
      throw EncryptionError.cantEncodeDecryptedPostBody
    }
    return decryptedBody
  }
  
}
