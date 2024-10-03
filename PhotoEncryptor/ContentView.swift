import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                displayImage()
                Button {
                    viewModel.showingImagePicker = true
                } label: {
                    buttonContent()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.blue)
                )

                if viewModel.image != nil {
                    NavigationLink(
                        destination: SingleImageView(
                            viewModel: SingleImageViewModel(encrData: viewModel.encrImage))
                    ) { navigationButton() }
                    .transition(.move(edge: .top))
                }
            }
            .padding()
            .sheet(isPresented: $viewModel.showingImagePicker) {
                ImagePicker(selectedImage: $viewModel.image)
            }
        }
    }

    @ViewBuilder
    private func navigationButton() -> some View {
        HStack {
            Text("Check the decrypted image")
                .foregroundStyle(.white)
                .bold()
                .transition(.opacity)
            Image(systemName: "arrow.right")
                .bold()
                .foregroundStyle(.white)
                .transition(.move(edge: .leading))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.blue)
        )

    }

    @ViewBuilder
    private func displayImage() -> some View {
        if let showImg = viewModel.image {
            Image(uiImage: showImg)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(10)
        } else {
            Text("No image uploaded")
        }
    }

    @ViewBuilder
    private func buttonContent() -> some View {
        HStack {
            Text(viewModel.buttonText)
                .foregroundStyle(.white)
                .bold()
                .transition(.opacity)
            
            if viewModel.encodingStatus == .process {
                ProgressView()
                    .tint(.white)
            } else {
                Image(systemName: viewModel.iconForStatus)
                    .bold()
                    .foregroundStyle(.white)
                    .opacity(viewModel.iconForStatus == "empty" ? 0 : 1)
                    .transition(.move(edge: .leading))
            }
        }
    }




}

@MainActor
class ContentViewModel: ObservableObject {
    @Published var image: UIImage? {
        didSet {
            processImage()
        }
    }
    @Published var showingImagePicker = false
    @Published var encrImage: Data?
    @Published var encryptor: ImageEncryptor = .init()
    @Published var encodingStatus: ProcessStatus = .notStarted
    
    func processImage() {
        Task {
            encodingStatus = .process
            encrImage = encryptor.imageEncoder(image)

            await Task.yield()

            DispatchQueue.main.async {
                withAnimation {
                    if self.encrImage == nil {
                        self.encodingStatus = .error
                    } else {
                        self.encodingStatus = .success
                    }
                }
            }

            try? await Task.sleep(nanoseconds: 2_000_000_000)

            DispatchQueue.main.async {
                withAnimation {
                    self.encodingStatus = .notStarted
                }
            }
        }
    }
    
    var buttonText: String {
        switch encodingStatus {
        case .notStarted:
            return "Upload Image"
        case .process:
            return "Processing..."
        case .success:
            return "Image encoded successfully"
        case .error:
            return "Error while encoding image"
        }
    }

    var iconForStatus: String {
        switch encodingStatus {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        default:
            return "empty"
        }
    }
    
    
}

enum ProcessStatus {
    case success
    case process
    case error
    case notStarted
}

#Preview {
    ContentView(viewModel: ContentViewModel())
}
