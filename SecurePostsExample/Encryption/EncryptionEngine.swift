//
//  EncryptionEngine.swift
//  SecurePostsExample
//
//  Created by Anastasiia on 6/15/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

struct Key {
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init?(string: String) {
        guard let data = string.data(using: .utf8) else { return nil }
        self.data = data
    }
    
    init?(base64String string: String) {
        guard let stringWithoutPercent = string.removingPercentEncoding else { return nil }
        
        guard let data = Data(base64Encoded: stringWithoutPercent,
                              options: .ignoreUnknownCharacters) else { return nil }
        
        self.data = data
    }
    
    var base64String: String {
        return data.base64EncodedString()
    }
}


import Foundation
import FirebaseAuth

struct KeyPair {
  var privateKey: Key
  var publicKey: Key
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
  
  var publicKeys: [String: Key] = [:]
  var encryptedSharedSKeys: [String: EncryptedData] = [:]
  
  var myKeyPair: KeyPair?
  
  // not a very good secret key generation
  func mySecretKey() -> Key {
    return Key(string: "my-secret-key")!
  }
}
