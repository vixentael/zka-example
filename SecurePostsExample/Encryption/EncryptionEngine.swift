//
//  EncryptionEngine.swift
//  SecurePostsExample
//
//  Created by Anastasiia on 6/15/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import Foundation

enum EncryptionError: Error {
  case cantCreateSecureCell
  case cantEncryptPostBody
  case cantDecryptPostBody
  case cantEncodeEncryptedPostBody
  case cantDecodeEncryptedPostBody
  case cantEncodeDecryptedPostBody
}

class EncryptionEngine {
  
  var publicKeys: [String: String] = [:]
  
  func mySecretKey() -> String {
    return "my-super-secret-key"
  }
}

// MARK: - Encrypt/Decrypt Own Posts

extension EncryptionEngine {
  func encryptOwnPost(body: String) throws -> String {
    let mySecretKeyData = dataFromString(string: mySecretKey())
    
    // 1. create encryptor
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
    let mySecretKeyData = dataFromString(string: mySecretKey())
    
    // 1. create decryptor
    guard let data = mySecretKeyData, let cellSeal = TSCellSeal(key: data) else {
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
  
//  func encryptSecretKeyForUser(username: String) -> String {
//
//  }
//
//  func decryptSecretKey(encryptedKey: String, authorPublicKey: String) -> String {
//
//  }
//
//  func decryptPost(encryptedPost: String, encryptedSecretKey: String) -> String {
//
//  }
  
}

// MARK: - Utils
extension EncryptionEngine {
  
  func dataFromString(string: String?) -> Data? {
    guard let string = string, let stringWithoutPercent = string.removingPercentEncoding else { return nil }
    return Data(base64Encoded: stringWithoutPercent, options: .ignoreUnknownCharacters)
  }
  
  func escapedBase64StringFrom(data: Data?) -> String? {
    guard let data = data else { return nil }
    return data
      .base64EncodedString(options: .endLineWithLineFeed)
      .addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
  }
}
