import SwiftUI
import UIKit
import Photos

struct PhotosView: View {
    @StateObject private var photoService = PhotoService()
    
    var body: some View {
        VStack(spacing: 0) {
            if !photoService.photoGroups.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 24) {
                        ForEach(photoService.photoGroups) { group in
                            PhotoGroupView(
                                photoGroup: group
                            )
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 200)
                }
            } else if photoService.isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("Загрузка фотографий...")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = photoService.error {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text("Ошибка загрузки")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(error)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Повторить") {
                        photoService.refreshPhotos()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
        .onAppear {
            if photoService.photoGroups.isEmpty && !photoService.isLoading {
                photoService.fetchCharityPhotos()
            }
        }
    }
}

struct PhotoGroupView: View {
    let photoGroup: PhotoGroup
    
    @State private var currentPage: Int = 0
    
    private var cardWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    private var cardHeight: CGFloat {
        cardWidth * 3/4
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Group name at the top
            Text(photoGroup.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            
            // Photos carousel
            TabView(selection: $currentPage) {
                ForEach(Array(photoGroup.photos.enumerated()), id: \.element.id) { index, photo in
                    PhotoCard(
                        photo: photo,
                        index: index
                    )
                    .frame(width: cardWidth, height: cardHeight)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: cardHeight)
            
            // Page indicator dots
            if photoGroup.photos.count > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<photoGroup.photos.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.4))
                            .frame(width: index == currentPage ? 6 : 5, height: index == currentPage ? 6 : 5)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Group description at the bottom
            Text(photoGroup.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 16)
        }
    }
}

/// Loads an asset image off the main thread to avoid freezing when many images are shown.
struct AsyncAssetImage: View {
    let name: String
    @State private var loadedImage: UIImage?
    
    var body: some View {
        Group {
            if let img = loadedImage {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 0))
            } else {
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)))
                    .aspectRatio(4/3, contentMode: .fit)
            }
        }
        .onAppear {
            guard loadedImage == nil else { return }
            Task.detached(priority: .userInitiated) {
                let img = UIImage(named: name)
                await MainActor.run {
                    loadedImage = img
                }
            }
        }
    }
}

struct PhotoCard: View {
    let photo: Photo
    let index: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(4/3, contentMode: .fit)
            
            if let imageName = photo.imageName {
                AsyncAssetImage(name: imageName)
            } else if let imageURL = photo.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: 0))
                    case .failure:
                        Image(systemName: "photo.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.7))
                    @unknown default:
                        Image(systemName: "photo.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            } else {
                Image(systemName: "photo.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

#Preview {
    PhotosView()
}
