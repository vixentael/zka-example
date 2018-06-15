//
//  EncryptionEngine.swift
//  SecurePostsExample
//
//  Created by Anastasiia on 6/15/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import Foundation

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
  
}

class EncryptionEngine {
  
  static let sharedInstance = EncryptionEngine()
  private init() {} //This prevents others from using the default '()' initializer for this class.
  
  var publicKeys: [String: String] = [:]
  var myKeyPair: KeyPair?
  
  func mySecretKey() -> String {
    return "my-super-secret-key"
  }
}

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
    let mySecretKeyData = dataFromString(string: mySecretKey())
    
    // 1. create decryptor with own secret key
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
  

//
//  func decryptSecretKey(encryptedKey: String, authorPublicKey: String) -> String {
//
//  }
//
//  func decryptPost(encryptedPost: String, encryptedSecretKey: String) -> String {
//
//  }
  
}
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


// MARK: - Encrypt My Secret Key
extension EncryptionEngine {
  
  func encryptSecretKeyForUser(userPublicKey: String) throws -> String {
    // 0. my own secret key
    let mySecretKey = self.mySecretKey()
    
    // 1. get my private key
    let myPrivateKey = try getMyPrivateKeyData()

    // 2. get other user public key
    guard let otherUserPublicKey = dataFromString(string: userPublicKey) else {
      print("Error occurred while getting other party public key")
      throw EncryptionError.cantDecodeOtherUserPublicKey
    }
    
    // 3. create Asym encryptor using own private key and other user' public key
    guard let encrypter = TSMessage.init(inEncryptModeWithPrivateKey: myPrivateKey,
                                         peerPublicKey: otherUserPublicKey) else {
      print("Error occurred while creating TSMessage Encryptor")
      throw EncryptionError.cantCreateSecureMessage
    }
  
    // 4. encrypt own secret key for another user
    var encryptedSecretKey: Data = Data()
    do {
      encryptedSecretKey = try encrypter.wrap(mySecretKey.data(using: .utf8))
    } catch let error as NSError {
      print("Failed to encrypt own SK: error occurred while encrypting: \(error)")
      throw EncryptionError.cantEncryptOwnSecretKey
    }
    
    // 5. encode encrypted
    guard let escapedBase64URLEncodedSK = escapedBase64StringFrom(data: encryptedSecretKey) else {
      print("Failed to encrypt SK: Error occured while encoding encrypted SK to base64")
      throw EncryptionError.cantEncodeEncryptedPostBody
    }
    return escapedBase64URLEncodedSK
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
