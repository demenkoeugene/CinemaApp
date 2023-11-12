//
//  AsyncImageView.swift
//  CinemaApp
//
//  Created by Eugene Demenko on 12.11.2023.
//

import SwiftUI

enum AsyncImageContent {
    case custom1
    case custom2
}

struct AsyncImageView: View {
    let url: URL
    @ObservedObject private var imageLoader = ImageLoader()
    let content: AsyncImageContent
    
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .modifier(SharedImageModifier(content: content, width: width, height: height))
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


struct SharedImageModifier: ViewModifier {
    let content: AsyncImageContent
    let width: CGFloat
    let height: CGFloat
    
    func body(content: Content) -> some View {
        switch self.content {
        case .custom1:
            return AnyView(
                content
                    .frame(width: width, height: height)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(20)
            )
        case .custom2:
            return AnyView(
                content
                    .frame(height: height)
                    .overlay {
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                   
            )
        }
    }
}
