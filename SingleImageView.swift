//
//  SingleImageView.swift
//  PhotoEncryptor
//
//  Created by Тимофій Безверхий on 10.09.2024.
//

import SwiftUI

struct SingleImageView: View {
    @Binding var encrData: Data?
    @State private var image: UIImage?
    @State var status: ProcessStatus = .process
    let imageEncryptor: ImageEncryptor = .init()

    var body: some View {
        switch status {
        case .success:
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        case .process:
            ProgressView()
                .onAppear{
                    Task{
                        image = await imageEncryptor.imageDecoder(encrData)
                        withAnimation{
                            status = image == nil ? .error : .success
                        }
                    }
                }
        case .error:
            VStack(spacing: 20){
                Image(systemName: "xmark")
                    .scaleEffect(3)
                    .foregroundStyle(.red)
                Text("Oops, something went wrong with encoding. Please, try again")
                    .font(.title)
            }
        case .notStarted:
            EmptyView()
        }
    }
}

#Preview {
    SingleImageView(encrData: .constant(nil))
}
