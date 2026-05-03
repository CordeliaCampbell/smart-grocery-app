import PhotosUI
import SwiftUI

struct UploadView: View {
    @State private var vm = UploadViewModel()
    @State private var photoItem: PhotosPickerItem?
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                imagePreview
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .background(Color(.systemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                pickerButtons
                analyzeButton
                errorLabel
            }
            .padding(.top)
            .navigationTitle("Scan Items")
            .sheet(isPresented: $vm.showConfirmation) {
                ConfirmItemsView(detected: vm.detectedItems) {
                    vm.reset()
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPickerView { image in
                    vm.selectedImage = image
                    showCamera = false
                }
                .ignoresSafeArea()
            }
            .onChange(of: photoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        vm.selectedImage = image
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var imagePreview: some View {
        if let image = vm.selectedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            VStack(spacing: 12) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Pick or take a photo")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var pickerButtons: some View {
        HStack(spacing: 16) {
            PhotosPicker(selection: $photoItem, matching: .images) {
                Label("Photo Library", systemImage: "photo")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                showCamera = true
            } label: {
                Label("Camera", systemImage: "camera")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal)
    }

    private var analyzeButton: some View {
        Button {
            Task { await vm.analyze() }
        } label: {
            Group {
                if vm.isAnalyzing {
                    ProgressView()
                } else {
                    Label("Analyze Image", systemImage: "sparkles")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(vm.selectedImage == nil || vm.isAnalyzing)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var errorLabel: some View {
        if let msg = vm.errorMessage {
            Text(msg)
                .font(.caption)
                .foregroundStyle(.red)
                .padding(.horizontal)
        }
    }
}

// MARK: - Camera picker wrapper

struct CameraPickerView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onCapture: onCapture) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ vc: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onCapture: (UIImage) -> Void
        init(onCapture: @escaping (UIImage) -> Void) { self.onCapture = onCapture }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let img = info[.originalImage] as? UIImage { onCapture(img) }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    UploadView()
}
