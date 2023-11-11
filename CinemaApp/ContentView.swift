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
        List{
            ForEach(vm.cinemaItem){ cinema in
                Text(cinema.title ?? "not Found")
            }
        }
    }
    
}

#Preview {
    ContentView()
}
