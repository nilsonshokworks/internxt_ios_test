//
//  PhotoLibraryObserver.swift
//  Testing
//
//  Created by Nilson on 19/10/23.
//

import SwiftUI
import Photos

class PhotoLibraryObserver: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    @Published var libraryDidChange = false
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.libraryDidChange = true
        }
    }
}
