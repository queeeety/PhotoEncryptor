import SwiftUI

struct ContentView: View {
    @State private var image: UIImage?
    @State private var showingImagePicker = false
    @State private var encrImage: Data?
    @State private var encryptor: ImageEncryptor = .init()
    @State private var encodingStatus: ProcessStatus = .notStarted
    
    
    var body: some View {
        NavigationStack {
            VStack {
                displayImage()

                Button {
                    showingImagePicker = true
                } label: {
                    buttonContent()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.blue)
                )

                if image != nil {
                    NavigationLink(
                        destination: SingleImageView(
                            encrData: $encrImage)
                    ) { navigationButton() }
                    .transition(.move(edge: .top))
                }
            }
            .padding()
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $image)
            }
            .onChange(of: image) {
                processImage()
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
        if let showImg = image {
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
            Text(buttonText)
                .foregroundStyle(.white)
                .bold()
                .transition(.opacity)

            if encodingStatus == .process {
                ProgressView()
                    .tint(.white)
            } else {
                Image(systemName: iconForStatus)
                    .bold()
                    .foregroundStyle(.white)
                    .opacity(iconForStatus.isEmpty ? 0 : 1)
                    .transition(.move(edge: .leading))
            }
        }
    }

    private var buttonText: String {
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

    private var iconForStatus: String {
        switch encodingStatus {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        default:
            return ""
        }
    }

    private func processImage() {
        Task {
            encodingStatus = .process
            encrImage = encryptor.imageEncoder(image)

            await Task.yield()

            withAnimation {
                if encrImage == nil {
                    encodingStatus = .error
                } else {
                    encodingStatus = .success
                }
            }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation {
                encodingStatus = .notStarted
            }
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
    ContentView()
}
