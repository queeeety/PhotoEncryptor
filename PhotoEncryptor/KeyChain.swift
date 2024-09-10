//
//  KeyChain.swift
//  PhotoEncryptor
//
//  Created by Тимофій Безверхий on 09.09.2024.
//

import Foundation
import CryptoKit
import SwiftUI
import KeychainAccess


struct KeyProvider {
    
    private let keychain: KeychainProvider
    
    init(serviceName: String = "com.example.myapp"){
        self.keychain = KeychainProvider(serviceName: serviceName)
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
    init(serviceName: String = "com.example.myapp",
         blockName: String = "encryptionKey"){
        self.keychain = Keychain(service: serviceName)
        self.blockName = blockName
    }
    
    func searchData () -> Data?{
        return try? keychain.getData(blockName)
    }
    
    func saveData (_ data: Data) {
        try? keychain.set(data, key: blockName)
    }
}
