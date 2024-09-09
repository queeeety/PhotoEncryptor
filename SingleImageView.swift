//
//  SingleImageView.swift
//  PhotoEncryptor
//
//  Created by Тимофій Безверхий on 10.09.2024.
//

import SwiftUI

struct SingleImageView: View {
    @Binding var encryptorObject: ImageEncryptor
    @State private var image: UIImage?
    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            
        } else {
            ProgressView()
                .onAppear{
                    Task{
                        image = await encryptorObject.imageDecoder()
                    }
                }
        }
    }
}

#Preview {
    SingleImageView(encryptorObject: .constant(ImageEncryptor(nil)))
}
