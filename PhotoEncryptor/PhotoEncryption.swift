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
    let data: Data?
    let encrKey: String
    init(_ image: UIImage?, encrKey: String = "encryptionKey") {
        self.keychain = KeyProvider()
        self.encrKey = encrKey
        if let image = image,
           let imageData = image.pngData(),
           let sealedBox = try? AES.GCM.seal(imageData, using: self.keychain.getKey(encrKey)){
            self.data = sealedBox.combined
        }
        else {
            self.data = nil
        }
    }
    
    func imageDecoder() async -> UIImage? {
        if self.data != nil {
            do {
                let sealedBox = try AES.GCM.SealedBox(combined: self.data!)
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
