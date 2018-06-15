//
//  EncryptionEngine+Keypair.swift
//  SecurePostsExample
//
//  Created by Anastasiia on 6/15/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import Foundation


// MARK: - KeyPair
extension EncryptionEngine {
  
  func generateMyKeyPair() throws -> KeyPair {
    guard let keyGeneratorEC: TSKeyGen = TSKeyGen(algorithm: .EC) else {
      print("Error occurred while initializing object keyGeneratorEC")
      throw EncryptionError.cantCreateKeyGenerator
    }
    
    guard let privKey = escapedBase64StringFrom(data: keyGeneratorEC.privateKey as Data),
      let pubKey = escapedBase64StringFrom(data: keyGeneratorEC.publicKey as Data) else {
        print("Error occurred while escaping own keypair")
        throw EncryptionError.cantEncodeKeyPair
    }
    
    return KeyPair(privateKey: privKey, publicKey: pubKey)
  }
  
  func getMyPublicKey() throws -> String {
    // 1. get my private key
    if self.myKeyPair == nil {
      self.myKeyPair = try generateMyKeyPair()
    }
    
    guard let keypair = self.myKeyPair else {
      print("Error occurred while getting own public key")
      throw EncryptionError.cantGenerateKeyPair
    }
    
    return keypair.publicKey
  }
  
  func getMyPrivateKey() throws -> String {
    // 1. get my private key
    if self.myKeyPair == nil {
      self.myKeyPair = try generateMyKeyPair()
    }
    
    guard let keypair = self.myKeyPair else {
      print("Error occurred while getting own private key")
      throw EncryptionError.cantGenerateKeyPair
    }
    return keypair.privateKey
  }
  
  func getMyPrivateKeyData() throws -> Data {
    guard let myPrivateKeyData = try dataFromString(string: getMyPrivateKey()) else {
      print("Error occurred while getting own private key data")
      throw EncryptionError.cantDecodePrivateKey
    }
    return myPrivateKeyData
    }
}
