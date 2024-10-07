//
//  SingleImageView.swift
//  PhotoEncryptor
//
//  Created by Тимофій Безверхий on 10.09.2024.
//

import SwiftUI

struct SingleImageView: View {
    @ObservedObject var viewModel: SingleImageViewModel
    
    var body: some View {
        switch viewModel.status {
        case .success:
            PhotoView()
        case .process:
            ProgressView()
                .onAppear{
                    viewModel.didAppear = true
                }
        case .error:
            ErrorView()
        case .notStarted:
            EmptyView()

        }
    }
    
    @ViewBuilder
    private func PhotoView() -> some View{
        Image(uiImage: viewModel.image!)
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
}


class SingleImageViewModel: ObservableObject{
    @Published var encrData: Data?
    @Published var image: UIImage?
    @Published var status: ProcessStatus = .process
    @Published var didAppear: Bool = false {
        didSet {
            if didAppear && image == nil{
                viewDidAppear()
            }
        }
    }
    let imageEncryptor: ImageEncryptor = .init()
    
    init(encrData: Data?){
        self.encrData = encrData
    }

    func viewDidAppear(){
        status = .process
        Task{
            let decrImage = await imageEncryptor.imageDecoder(encrData)
            await Task.yield()
            if decrImage != nil {
                self.image = decrImage!
                self.status = .success
            }
            else {
                self.status = .error
            }
        }
    }
}
    


#Preview {
    SingleImageView(viewModel: SingleImageViewModel(encrData: nil))
}
