//
//  CinemaVM.swift
//  CinemaApp
//
//  Created by Eugene Demenko on 11.11.2023.
//

import Foundation
import Combine

enum NetworkRequestState {
    case idle
    case loading
    case loaded
    case failed(URLError)
}

class CinemaVM: ObservableObject {
    @Published var cinemaItem: [CinemaModel] = []
    @Published var networkRequestState: NetworkRequestState = .idle
    
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
        
        // Update networkRequestState to .loading when the request starts
        networkRequestState = .loading
        
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
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.networkRequestState = .loaded
                    break
                case .failure(let error):
                    if let urlError = error as? URLError {
                        if urlError.code == .notConnectedToInternet {
                            print("Not connected to the internet.")
                        }
                        // Update networkRequestState to .failed with the specific error
                        self?.networkRequestState = .failed(urlError)
                    } else {
                        print("Error: \(error)")
                    }
                }
            }, receiveValue: { [weak self] (cinemaResponse) in
                self?.cinemaItem = cinemaResponse.results
            })
            .store(in: &cancellables)
    }
}

struct GenresConfig{
    static let genres: [String: Int] = [
        "Action": 28,
        "Adventure": 12,
        "Animation": 16,
        "Comedy": 35,
        "Crime": 80,
        "Documentary": 99,
        "Drama": 18,
        "Family": 10751,
        "Fantasy": 14,
        "History": 36,
        "Horror": 27,
        "Music": 10402,
        "Mystery": 9648,
        "Romance": 10749,
        "Science Fiction": 878,
        "TV Movie": 10770,
        "Thriller": 53,
        "War": 10752,
        "Western": 37
    ]
}

struct FormatReleaseData{
    static func formatReleaseDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "d MMM yyyy"
            return dateFormatter.string(from: date)
        }
        
        return "Invalid Date"
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
