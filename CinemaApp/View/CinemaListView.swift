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
//    @State var scrollViewOffset: CGFloat = 0
//    @State var startOffset: CGFloat = 0
    
    @State private var isFilterSheetPresented = false
    
    var body: some View {
        NavigationView {
//            ZStack(alignment: .bottomTrailing) {
                
                VStack {
                    HStack {
                        TextField("Search", text: $vm.searchQuery)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        Button(action: {
                            isFilterSheetPresented.toggle()
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.blue)
                                .font(.title2)
                                .padding(8)
                        }
                        .sheet(isPresented: $isFilterSheetPresented) {
                            CinemaOptionView(vm: vm)
                        }
                    }
                    .padding([.leading, .trailing], 16)
                    
                    content
                        .navigationTitle("Now Playing")
                }
//                
//                Button {
//                    withAnimation(.spring()){
//                        // proxyReader.scroll("SCROLL_TO_TOP", anchor: .top)
//                    }
//                } label: {
//                    Image(systemName: "arrow.up")
//                        .padding(12)
//                        .foregroundColor(.white)
//                        .background(.gray)
//                        .clipShape(Circle())
//                }
                .padding(16)
//                .opacity(
//                    withAnimation(.easeInOut){
//                        -scrollViewOffset > 450 ? 1 : 0
//                    }
//                )
            
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
            ForEach(vm.movies) { cinema in
                NavigationLink(destination: CinemaDetailView(cinemaItem: cinema)) {
                    
                    CinemaCardView(cinemaItem: cinema)
                    
                }
            }
            if !isLoadMoreButtonHidden {
                loadMoreButton
            }
        }
        //        .id("SCROLL_TO_TOP")
        //        .background(
        //            GeometryReader { proxy -> Color in
        //                DispatchQueue.main.async{
        //                    if startOffset == 0 {
        //                        startOffset = proxy.frame(in: .global).minY
        //                    }
        //                    let offset = proxy.frame(in: .global).minY
        //                    scrollViewOffset = offset - startOffset
        //                }
        //                    return Color.clear
        //
        //            }
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



struct CinemaOptionView: View {
    @Environment(\.presentationMode) var presentationMode//for qs
    @ObservedObject var vm: CinemaVM
    
    var body: some View {
        NavigationView{
            Form {
                List{
                    Section("Selected categories") {
                        Toggle("Filter by Title", isOn: $vm.filterByAlphabet)
                        Toggle("Filter by Rate", isOn: $vm.filterByRating)
                    }
                    
                }
            }.navigationTitle("Filter")
                .pickerStyle(.inline)
                .listStyle(.grouped)
                .toolbar {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Done")
                    })
                    .padding(10)
                }
        }
    }
}

#Preview {
    CinemaListView()
}
