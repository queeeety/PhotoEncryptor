import SwiftUI

struct ContentView: View {
    @State private var image: UIImage?
    @State private var showingImagePicker = false
    @State private var encrImage: ImageEncryptor = .init(nil)
    @State private var encodingStatus: EncodingStatus = .notStarted
    
    var body: some View {
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
        }
        .padding()
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $image)
        }
        .onChange(of: image) {
            processImage()
        }
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
            
            if encodingStatus == .process {
                ProgressView()
                    .tint(.white)
            } else {
                Image(systemName: iconForStatus)
                    .bold()
                    .foregroundStyle(.white)
                    .opacity(iconForStatus.isEmpty ? 0 : 1)
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
            encrImage = ImageEncryptor(image)
            
            await Task.yield()
            
            withAnimation {
                if encrImage.data == nil {
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

enum EncodingStatus {
    case success
    case process
    case error
    case notStarted
}

#Preview {
    ContentView()
}
