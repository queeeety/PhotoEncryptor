//
//  KeyChain.swift
//  PhotoEncryptor
//
//  Created by Тимофій Безверхий on 09.09.2024.
//

import Foundation
import Security
import CryptoKit
import SwiftUI
import KeychainAccess


struct KeyProvider {
    
    private let keychain: KeychainProvider
    
    init(){
        self.keychain = KeychainProvider()
    }
    
    
     func getKey() -> SymmetricKey {
         if let data = keychain.searchData() {
             return SymmetricKey(data: data)
        } else {
            // Create and save Key
            let key = SymmetricKey(size: .bits256)
            let keyData = key.withUnsafeBytes { Data(Array($0)) }
            keychain.saveData(keyData)
            return key
        }
    }
}

struct KeychainProvider{
    
    private let keychain: Keychain
    private let blockName: String
    init(){
        self.keychain = Keychain(service: "com.example.myapp")
        self.blockName = "encryptionKey"
    }
    
    func searchData () -> Data?{
        if let keyData = try? keychain.getData(blockName) {
            return keyData
        } else {
            return nil
        }
    }
    
    func saveData (_ data: Data) {
        try? keychain.set(data, key: blockName)
    }
}
