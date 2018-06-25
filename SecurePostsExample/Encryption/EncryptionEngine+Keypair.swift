//
//  EncryptionEngine+Keypair.swift
//  SecurePostsExample
//
//  Created by Anastasiia on 6/15/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import Foundation

struct EncryptedData {
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init?(base64String string: String) {
        guard let stringWithoutPercent = string.removingPercentEncoding else { return nil }
        
        guard let data = Data(base64Encoded: stringWithoutPercent,
                              options: .ignoreUnknownCharacters) else { return nil }
        
        self.data = data
    }
    
    var base64String: String {
      return data
        .base64EncodedString(options: .endLineWithLineFeed)
        .addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!
    }
}


// MARK: - KeyPair
extension EncryptionEngine {
  
  func generateMyKeyPair() throws -> KeyPair {
    guard let keyGeneratorEC: TSKeyGen = TSKeyGen(algorithm: .EC) else {
      print("Error occurred while initializing object keyGeneratorEC")
      throw EncryptionError.cantCreateKeyGenerator
    }
    
    let privKey = Key(data: keyGeneratorEC.privateKey as Data)
    let pubKey = Key(data: keyGeneratorEC.publicKey as Data)
    
    return KeyPair(privateKey: privKey, publicKey: pubKey)
  }
  
  func getMyPublicKey() throws -> Key {
    if self.myKeyPair == nil {
      self.myKeyPair = try generateMyKeyPair()
    }
    
    guard let keypair = self.myKeyPair else {
      print("Error occurred while getting own public key")
      throw EncryptionError.cantGenerateKeyPair
    }
    
    return keypair.publicKey
  }
  
  func getMyPrivateKey() throws -> Key {
    if self.myKeyPair == nil {
      self.myKeyPair = try generateMyKeyPair()
    }
    
    guard let keypair = self.myKeyPair else {
      print("Error occurred while getting own private key")
      throw EncryptionError.cantGenerateKeyPair
    }
    return keypair.privateKey
  }
}
