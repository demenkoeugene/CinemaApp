//
//  ContentView.swift
//  CinemaApp
//
//  Created by Eugene Demenko on 10.11.2023.
//

import SwiftUI
import Combine


class ImageCache {
    static var cache: [URL: UIImage] = [:]
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?
    
    func loadImage(from url: URL) {
        if let cachedImage = ImageCache.cache[url] {
            image = cachedImage
        } else {
            cancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map(\.data)
                .compactMap { UIImage(data: $0) }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in },
                      receiveValue: { [weak self] in
                    ImageCache.cache[url] = $0
                    self?.image = $0
                })
        }
    }
}

struct AsyncImageWithCombine: View {
    let url: URL
    @ObservedObject private var imageLoader = ImageLoader()
    
    var body: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 350, height: 200)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 150)
                        .offset(y: 40)
                    )
                    .cornerRadius(10)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .onAppear(perform: loadImage)
            }
        }
    }
    
    private func loadImage() {
        imageLoader.loadImage(from: url)
    }
}

struct ContentView: View {
    @StateObject var vm = CinemaVM()
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(vm.cinemaItem) { cinema in
                    CinemaView(vm: vm, cinemaItem: cinema)
                }
            }
            .navigationTitle("Now Playing")
        }
    }
}

struct CinemaView: View {
    var vm: CinemaVM
    var cinemaItem: CinemaModel
    
    var body: some View {
        ZStack {
            if let posterURL = vm.getPosterURL(posterPath: cinemaItem.posterPath) {
                AsyncImageWithCombine(url: posterURL)
            } else {
                Text("No poster available")
            }
            VStack(alignment: .leading){
                Text("\(cinemaItem.popularity)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(20)
                
                HStack(alignment: .center) {
                    Text(cinemaItem.title)
                        .font(.system(size: 24))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(10)
                    Spacer()
                    Text(cinemaItem.releaseDate)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(10)
                }
                .padding(20)
            }
            .offset(y: 50)
        }
    }
}

#Preview {
    ContentView()
}
