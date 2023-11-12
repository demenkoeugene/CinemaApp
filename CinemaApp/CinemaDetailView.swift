//
//  CinemaDetailView.swift
//  CinemaApp
//
//  Created by Eugene Demenko on 12.11.2023.
//

import SwiftUI

struct CinemaDetailView: View {
    var vm: ImageLoader = ImageLoader()
    var cinemaItem: CinemaModel
    
    
    var body: some View {
        ScrollView{
            ZStack(alignment: .bottom){
                posterView()
                HStack(alignment: .center){
                    Text(cinemaItem.title)
                        .fontWeight(.heavy)
                        .foregroundStyle(.white)
                        .font(.title)
                        .frame(width: 350, alignment: .center)
                        .padding(.bottom, 30)
                }
            }
            VStack(alignment: .leading){
                Text("\(Image(systemName: "star.fill")) \(String(format: "%.1f", cinemaItem.voteAverage))")
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                Text("Release date")
                    .fontWeight(.bold)
                    .foregroundStyle(.gray)
                    .padding(.bottom, 10)
                Text(FormatReleaseData.formatReleaseDate(cinemaItem.releaseDate))
                    .padding(.bottom, 10)
                
                Text("Genre")
                    .fontWeight(.bold)
                    .foregroundStyle(.gray)
                    .padding(.bottom, 10)
                Text(GenresConfig.genres.compactMap { (name, id) in
                    cinemaItem.genreIds.contains(id) ? name : nil
                }.joined(separator: ", "))
                .padding(.bottom, 10)
                
                
                Text("Overview")
                    .fontWeight(.bold)
                    .foregroundStyle(.gray)
                    .padding(.bottom, 10)
                Text(cinemaItem.overview)
            }
            .frame(maxWidth: 350)
            .padding(30)
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: CustomBackButton())
        .edgesIgnoringSafeArea(.top)
    }
    
    @ViewBuilder
    func posterView() -> some View {
        if let posterURL = vm.getPosterURL(posterPath: cinemaItem.backdropPath) {
            AsyncImageWithCombineDetail(url: posterURL)
        } else {
            Text("No poster available")
        }
    }
}

struct AsyncImageWithCombineDetail: View {
    let url: URL
    
    var body: some View {
        AsyncImageView(
            url: url,
            content: .custom2,
            width: 350,
            height: 350
        )
    }
}

struct CustomBackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left.circle.fill")
                .foregroundColor(.gray)
                .opacity(0.9)
        }
    }
}




#Preview {
    let cinemaSample = CinemaModel(adult: true,
                                   backdropPath: "/t5zCBSB5xMDKcDqe91qahCOUYVV.jpg",
                                   genreIds: [27, 9648],
                                   identifier: 123,
                                   originalLanguage: "en",
                                   originalTitle: "Five Nights at Freddy's",
                                   overview: "Recently fired and desperate for work, a troubled young man named Mike agrees to take a position as a night security guard at an abandoned theme restaurant: Freddy Fazbear's Pizzeria. But he soon discovers that nothing at Freddy's is what it seems.",
                                   popularity: 85.5,
                                   posterPath: "/j9mH1pr3IahtraTWxVEMANmPSGR.jpg",
                                   releaseDate: "2023-11-12",
                                   title: "Example Movie",
                                   video: true,
                                   voteAverage: 8.5,
                                   voteCount: 1000)
    
    return CinemaDetailView(cinemaItem: cinemaSample)
}

