//
//  ScanView.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 3/15/25.
//

import SwiftUI

struct ScanView: View {
    @ObservedObject var viewModel: ScanViewModel  // Provided by MainView
    @ObservedObject var inventoryVM: InventoryViewModel
    @EnvironmentObject var appState: AppState
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    Button {
                        viewModel.pickCamera()
                    } label: {
                        VStack {
                            Image(systemName: "camera.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                            Text("Camera").font(.headline)
                        }
                        .padding()
                        .frame(width: 150, height: 150)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                    }
                    .padding(.bottom, 90)
                    
                    Button {
                        viewModel.pickGallery()
                    } label: {
                        VStack {
                            Image(systemName: "photo.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                            Text("Gallery").font(.headline)
                        }
                        .padding()
                        .frame(width: 150, height: 150)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                    }
                }
                // Show the system's picker if needed
                .sheet(isPresented: $viewModel.showImagePicker) {
                    if let sourceType = viewModel.sourceType {
                        ImagePicker(sourceType: sourceType, selectedImage: $viewModel.selectedImage)
                            .ignoresSafeArea()
                    }
                }
                // When user selects an image, automatically process it and navigate
                .onChange(of: viewModel.selectedImage) { newImage in
                    if let image = newImage {
                        // 1) Process the image
                        viewModel.processImage(image)
                        // 2) Show the result screen
                        viewModel.isShowingResult = true
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            
            // If isShowingResult is true, push the ResultView
            .navigationDestination(isPresented: $viewModel.isShowingResult) {
                ResultView(
                    items: $viewModel.recognizedItems,
                    isLoading: viewModel.isLoading,
                    openAIResponse: viewModel.openAIResponse,
                    onGoBack: { viewModel.reset() },
                    inventoryVM: inventoryVM
                )
            }

        }
    }
}

// ImagePicker remains the same
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // no updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

