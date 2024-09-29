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
    
    
    func getKey(_ keyName: String) -> SymmetricKey {
        if let data = keychain.searchData(keyName) {
             return SymmetricKey(data: data)
        } else {
            // Create and save Key
            let key = SymmetricKey(size: .bits256)
            let keyData = key.withUnsafeBytes { Data(Array($0)) }
            keychain.saveData(keyData, blockName: keyName)
            return key
        }
    }
}

struct KeychainProvider{
    
    private let keychain: Keychain
    init(serviceName: String = "com.example.myapp"){
        self.keychain = Keychain(service: serviceName)
    }
    
    func searchData (_ blockName: String) -> Data?{
        return try? keychain.getData(blockName)
    }
    
    func saveData (_ data: Data, blockName: String) {
        try? keychain.set(data, key: blockName)
    }
}
