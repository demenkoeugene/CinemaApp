//
//  ContentView.swift
//  CinemaApp
//
//  Created by Eugene Demenko on 10.11.2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = CinemaVM()
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(vm.cinemaItem) { cinema in
                    NavigationLink(destination: CinemaDetailView(cinemaItem: cinema)) {
                        CinemaView(cinemaItem: cinema)
                    }
                }
            }
            .navigationTitle("Now Playing")
        }
        .refreshable {
            vm.fetchData()
        }
    }
}


struct CinemaView: View {
    var vm: ImageLoader = ImageLoader()
    var cinemaItem: CinemaModel
    
    var body: some View {
        ZStack {
            if let posterURL = vm.getPosterURL(posterPath: cinemaItem.posterPath) {
                AsyncImageWithCombine(url: posterURL)
            } else {
                Text("No poster available")
            }
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
    
  
}




struct AsyncImageWithCombine: View {
    let url: URL

    var body: some View {
        AsyncImageView(
            url: url,
            content: .custom1,
            width: 350,
            height: 200
        )
    }
}


#Preview {
    ContentView()
}
