//
//  ContentView.swift
//  CinemaApp
//
//  Created by Eugene Demenko on 10.11.2023.
//

import SwiftUI

struct CinemaListView: View {
    @ObservedObject var vm = CinemaVM()
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    switch vm.networkRequestState {
                    case .idle:
                        Text("Loading...")
                            .padding()
                            .frame(width: geometry.size.width)
                            .frame(minHeight: geometry.size.height)
                    case .loading:
                        VStack{
                            ProgressView("Loading...")
                                .padding()
                        }
                        .frame(width: geometry.size.width)
                        .frame(minHeight: geometry.size.height)
                    case .loaded:
                        ForEach(vm.cinemaItem) { cinema in
                            NavigationLink(destination: CinemaDetailView(cinemaItem: cinema)) {
                                CinemaCardView(cinemaItem: cinema)
                            }
                        }
                    case .failed(let error):
                        VStack{
                            if error.code == .notConnectedToInternet {
                                Text("No internet connection🥲")
                                    .frame(height: 500)
                                    .padding()
                                Spacer(minLength: 300)
                            } else {
                                Text("\(error.localizedDescription)🥲")
                                    .padding()
                                    .frame(maxHeight: .infinity)
                            }
                        }
                        .frame(width: geometry.size.width)
                        .frame(minHeight: geometry.size.height)
                    }
                }
                .navigationTitle("Now Playing")
            }
        }
        .refreshable {
            ImageCache.clearCache()
            vm.fetchData()
        }
    }
}


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


#Preview {
    CinemaListView()
}
