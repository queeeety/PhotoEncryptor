//
//  PhotoEncryption.swift
//  PhotoEncryptor
//
//  Created by Тимофій Безверхий on 09.09.2024.
//

import Foundation
import SwiftUI
import CryptoKit

struct ImageEncryptor {
    
    private let keychain: KeyProvider
    let encrKey: String
    init(key encrKey: String = "encryptionKey") {
        self.keychain = KeyProvider()
        self.encrKey = encrKey
       
    }
    func imageEncoder(_ image: UIImage?) -> Data? {
        if let image = image,
           let imageData = image.pngData(),
           let sealedBox = try? AES.GCM.seal(imageData, using: self.keychain.getKey(encrKey)){
            return sealedBox.combined
        }
        else {
            return nil
        }
    }
    
    func imageDecoder(_ data: Data?) async -> UIImage? {
        if let data = data {
            do {
                let sealedBox = try AES.GCM.SealedBox(combined: data)
                let decryptedData = try AES.GCM.open(sealedBox, using: self.keychain.getKey(encrKey))
                let image = UIImage(data: decryptedData)
                return image
            }
            catch {
                print("Decoding error happened")
                return nil
            }
        }
        return nil
    }
}
