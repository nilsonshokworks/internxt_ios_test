//
//  ContentView.swift
//  Testing
//
//  Created by Nilson on 19/10/23.
//

import SwiftUI
import Photos

struct ContentView: View {
    
    @ObservedObject var observer = PhotoLibraryObserver()
    
    @State private var assets: [PHAsset] = []
    @State private var message = ""
    
    var body: some View {
        VStack {
            if !assets.isEmpty {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 5) {
                        ForEach(assets, id: \.self) { asset in
                            if asset.mediaType == .image {
                                ZStack {
                                    Image(uiImage: fetchImageThumbnail(asset: asset))
                                        .resizable()
                                        .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.width / 5)
                                        .aspectRatio(contentMode: .fill)
                                }
                            } else if asset.mediaType == .video {
                                ZStack {
                                    Image(uiImage: fetchImageThumbnail(asset: asset))
                                        .resizable()
                                        .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.width / 5)
                                        .aspectRatio(contentMode: .fill)
                                    Text("Video").foregroundColor(.white)
                                }
                                .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.width / 5)
                            }
                        }
                    }
                }
            } else {
                Text(message)
            }
        }
        .onAppear {
            PHPhotoLibrary.shared().register(observer)
            askForPermission()
        }
        .onDisappear {
            PHPhotoLibrary.shared().unregisterChangeObserver(observer)
        }
        .onChange(of: observer.libraryDidChange) { newValue in
            if newValue {
                askForPermission()
            }
        }
    }
    
    private func askForPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .limited, .authorized:
                fetchAssets()
            default:
                message = "No permission granted."
            }
        }
    }
    
    private func fetchAssets() {
        let fetchOptions = PHFetchOptions()
        let allAssets = PHAsset.fetchAssets(with: fetchOptions)
        assets.removeAll()
        allAssets.enumerateObjects { (asset, _, _) in
            DispatchQueue.main.async {
                withAnimation {
                    self.assets.append(asset)
                    if self.assets.count == 0 {
                        message = "No assets found."
                    }
                }
            }
        }
    }
    
    private func fetchImageThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        
        var thumbnail = UIImage()
        manager.requestImage(for: asset, targetSize: CGSize(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.width / 5), contentMode: .aspectFill, options: options) { (result, _) in
            if let image = result {
                thumbnail = image
            }
        }
        return thumbnail
    }
}

#Preview {
    ContentView()
}
