//
//  ImageLib.swift
//  scan_test
//
//  Created by Shaashvat Mittal on 3/15/25.
//

import Foundation
import SwiftUI
import UIKit  // for UIImagePickerController

// helps user to pick an image
struct ImageLib: UIViewControllerRepresentable {
    @Binding var image: UIImage?  // container for selected img
    @Environment(\.presentationMode) var presentationMode   // closing the picker
    
    var sourceType: UIImagePickerController.SourceType  // camera or gallery
    
    // this is to handle user actions like select and cancel
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImageLib
        
        init(parent: ImageLib) {
            self.parent = parent
        }
        
        // this is when user selects an image
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage    // save the selected image
            }
            parent.presentationMode.wrappedValue.dismiss()      // closing the picker
        }
        
        // when user hits cancel just  dismiss the picker
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    // connecting the coordinator
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    // image picker
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // all good here
    }
    
}


