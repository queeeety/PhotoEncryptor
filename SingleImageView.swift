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
            PhotoView()
        case .process:
            ProgressView()
                .onAppear{
                    imageEncoding()
                }
        case .error:
            ErrorView()
        case .notStarted:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func PhotoView() -> some View{
        Image(uiImage: image!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    @ViewBuilder
    private func ErrorView() -> some View{
        VStack(spacing: 20){
            Image(systemName: "xmark")
                .scaleEffect(3)
                .foregroundStyle(.red)
            Text("Oops, something went wrong with encoding. Please, try again")
                .font(.title)
        }
    }
    
    private func imageEncoding() {
        Task{
            let decrImage = await imageEncryptor.imageDecoder(encrData)
            if decrImage != nil {
                withAnimation{
                    status = .success
                    image = decrImage!
                }
            }
            else {
                withAnimation{
                    status = .error
                }
            }
        }
    }
}

#Preview {
    SingleImageView(encrData: .constant(nil))
}
