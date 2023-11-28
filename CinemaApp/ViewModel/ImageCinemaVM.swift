//
//  ImageCinemaVM.swift
//  CinemaApp
//
//  Created by Eugene Demenko on 12.11.2023.
//

import Foundation
import Combine
import SwiftUI

class ImageCache {
    static var cache: [URL: UIImage] = [:]
    
    static func clearCache() {
        cache.removeAll()
    }
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
                .subscribe(on: DispatchQueue.global(qos: .background)) // Perform initial image processing on a background queue
                .compactMap { UIImage(data: $0) }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in },
                      receiveValue: { [weak self] loadedImage in
                    ImageCache.cache[url] = loadedImage
                    DispatchQueue.main.async {
                                            self?.image = loadedImage
                                        }
                })
        }
    }
    
    func getPosterURL(posterPath: String?) -> URL? {
        guard let posterPath = posterPath else {
            return nil
        }
        
        let baseURL = "https://image.tmdb.org/t/p/"
        let imageSize = "original"
        
        let fullURLString = baseURL + imageSize + posterPath
        
        if let fullURL = URL(string: fullURLString) {
            return fullURL
        } else {
            return nil
        }
    }
}
