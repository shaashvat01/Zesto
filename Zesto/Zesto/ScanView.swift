//
//  ScanView.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 3/15/25.
//

import Foundation
import SwiftUI

struct ScanView: View {
    
    @State private var showImagePicker = false
    @State private var sourceType : UIImagePickerController.SourceType = .camera
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        VStack
        {
            TopBar()
            
            VStack
            {
                Button(action: {
                    if UIImagePickerController.isSourceTypeAvailable(.camera)
                    {
                        sourceType = .camera
                        showImagePicker = true
                    }
                    else
                    {
                        print("Camera not available")
                    }
                }){
                    VStack
                    {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                        
                        Text("Camera")
                            .font(.headline)
                    }
                    .padding()
                    .frame(width: 150, height: 150)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                }
                .padding(.bottom, 90)
                
                Button(action: {
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
                    {
                        sourceType = .photoLibrary
                        showImagePicker = true
                    }
                    else
                    {
                        print("Can't access photo library")
                    }
                }){
                    VStack
                    {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                        
                        Text("Gallery")
                            .font(.headline)
                    }
                    .padding()
                    .frame(width: 150, height: 150)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                }
            }
            .sheet(isPresented: $showImagePicker)
            {
                ImagePicker(sourceType: sourceType, selectedImage: $selectedImage)
                    .ignoresSafeArea()
            }
            
            BottomBar()
        }
    }
}


struct ImagePicker: UIViewControllerRepresentable
{
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // all good here
    }

    func makeCoordinator() -> Coordinator
    {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate
    {
        let parent: ImagePicker

        init(_ parent: ImagePicker)
        {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:                           [UIImagePickerController.InfoKey : Any])
        {
            if let image = info[.originalImage] as? UIImage
            {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
        {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScanView()
        }
    }
}


