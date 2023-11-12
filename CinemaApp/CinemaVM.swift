//
//  CinemaVM.swift
//  CinemaApp
//
//  Created by Eugene Demenko on 11.11.2023.
//

import Foundation
import Combine

class CinemaVM: ObservableObject {
    @Published var cinemaItem: [CinemaModel]  = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?language=en-US&page=1") else {
            print("Invalid URL")
            return
        }
        
        // Read API token from Config.plist
        guard let apiToken = Config.readApiToken() else {
            print("API token not found in Config.plist")
            return
        }
        
        let headers = [
            "accept": "application/json",
            "Authorization": "Bearer \(apiToken)"
        ]
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap { (data, response) in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode >= 200 && response.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: CinemaResponse.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    if let urlError = error as? URLError {
                        print("URL Error Code: \(urlError.code.rawValue)")
                    }
                    print("Error here: \(error)")
                }
            }, receiveValue: { [weak self] (cinemaResponse) in
                self?.cinemaItem = cinemaResponse.results
            })
            .store(in: &cancellables)
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



//to work with api_token
struct Config {
    static func readApiToken() -> String? {
        guard let configPath = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let configDict = NSDictionary(contentsOfFile: configPath),
              let apiToken = configDict["api_token"] as? String else {
            return nil
        }
        return apiToken
    }
}
