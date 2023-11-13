//
//  CinemaCardView.swift
//  CinemaApp
//
//  Created by Eugene Demenko on 13.11.2023.
//

import SwiftUI

struct CinemaCardView: View {
    var vm: ImageLoader = ImageLoader()
    var cinemaItem: CinemaModel
    
    var body: some View {
        ZStack {
            posterView()
            VStack(alignment: .leading){
                Text("\(Image(systemName: "star.fill")) \(String(format: "%.1f", cinemaItem.voteAverage))")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                    .padding(.leading, 30)
                    .offset(y: 40)
                
                HStack(alignment: .center) {
                    Text(cinemaItem.title)
                        .font(.system(size: 24))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(10)
                    Spacer()
                    Text(FormatReleaseData.formatReleaseDate(cinemaItem.releaseDate))
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(10)
                }
                .padding(20)
            }
            .offset(y: 45)
        }
    }
    
    @ViewBuilder
    func posterView() -> some View {
        if let posterURL = vm.getPosterURL(posterPath: cinemaItem.posterPath) {
            AsyncImageView(
                url: posterURL,
                content: .custom1,
                width: 350,
                height: 200
            )
        } else {
            Text("No poster available")
        }
    }
}

