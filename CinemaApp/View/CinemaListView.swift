//
//  ContentView.swift
//  CinemaApp
//
//  Created by Eugene Demenko on 10.11.2023.
//

import SwiftUI

struct CinemaListView: View {
    
    @StateObject var vm = CinemaVM()
    
    @State private var isLoadMoreButtonHidden = false
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle("Now Playing")
        }
        .refreshable {
            ImageCache.clearCache()
            vm.resetData()
            vm.fetchData()
        }
    }
    
    var content: some View {
        GeometryReader { geometry in
            ScrollView {
                switch vm.networkRequestState {
                case .idle:
                    idleView
                        .frame(width: geometry.size.width)
                        .frame(minHeight: geometry.size.height)
                case .loading:
                    loadingView
                        .frame(width: geometry.size.width)
                        .frame(minHeight: geometry.size.height)
                case .loaded:
                    listCinema
                case .failed(let error):
                    failedView(error: error, geometry: geometry)
                }
            }
        }
    }
    
    var idleView: some View {
        Text("Loading...")
            .padding()
    }
    
    var loadingView: some View {
        VStack{
            ProgressView("Loading...")
                .padding()
        }
    }
    
    var listCinema: some View {
        LazyVStack {
            ForEach(vm.cinemaItem) { cinema in
                NavigationLink(destination: CinemaDetailView(cinemaItem: cinema)) {
                    CinemaCardView(cinemaItem: cinema)
                }
            }
            if !isLoadMoreButtonHidden {
                loadMoreButton
            }
        }
    }
    
    var loadMoreButton: some View {
        Button(action: {
            vm.fetchData()
        }) {
            Text("\(Image(systemName: "chevron.down")) Load More")
                .padding(30)
                .foregroundColor(.gray)
                .cornerRadius(8)
        }
        .padding()
    }
    
    private func failedView(error: URLError, geometry: GeometryProxy) -> some View {
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



#Preview {
    CinemaListView()
}
