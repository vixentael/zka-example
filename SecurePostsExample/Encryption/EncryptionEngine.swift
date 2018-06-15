//
//  EncryptionEngine.swift
//  SecurePostsExample
//
//  Created by Anastasiia on 6/15/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import Foundation
import FirebaseAuth

struct KeyPair {
  var privateKey: String
  var publicKey: String
}

enum EncryptionError: Error {
  case cantCreateSecureCell
  
  case cantEncryptPostBody
  case cantDecryptPostBody
  case cantEncodeEncryptedPostBody
  case cantDecodeEncryptedPostBody
  case cantEncodeDecryptedPostBody
  
  
  case cantCreateKeyGenerator
  case cantGenerateKeyPair
  case cantEncodeKeyPair
  case cantDecodePrivateKey
  case cantDecodeOtherUserPublicKey
  
  case cantCreateSecureMessage
  case cantEncryptOwnSecretKey
  
  case cantDecryptOtherPostNoKeys
  case cantDecryptSharedSecretKey
}

class EncryptionEngine {
  
  static let sharedInstance = EncryptionEngine()
  private init() {} //This prevents others from using the default '()' initializer for this class.
  
  
  // TODO: NO state reservation at all, put to keychain :)
  // TODO: DON'T store keys in memory, hide in keychain/storage
  
  var publicKeys: [String: String] = [:]
  var encryptedSharedSKeys: [String: String] = [:]
  
  var myKeyPair: KeyPair?
  var secretKey: String?
  
  // not a very good secret key generation
  func mySecretKey() -> String {
    if let sk = self.secretKey {
      return sk
    }
    
    var composedSecretKey = NSUUID().uuidString
    if let uid = Auth.auth().currentUser?.uid {
      composedSecretKey = "\(composedSecretKey)\(uid)"
    }
    
    self.secretKey = composedSecretKey
    return composedSecretKey
  }
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
