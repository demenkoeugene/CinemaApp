//
//  CinemaModel.swift
//  CinemaApp
//
//  Created by Eugene Demenko on 11.11.2023.
//

import Foundation

struct CinemaResponse: Decodable {
    let dates: DateRange
    let page: Int
    let results: [CinemaModel]
    let totalPages: Int
    let totalResult: Int
    
    enum CodingKeys: String, CodingKey {
        case dates, page, results, totalPages = "total_pages", totalResult = "total_results"
    }
}

struct DateRange: Decodable {
    let maximum: String
    let minimum: String
}

struct CinemaModel: Identifiable, Decodable {
    var id = UUID()
    let adult: Bool
    let backdropPath: String
    let genreIds: [Int]
    let identifier: Int
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let popularity: Double
    let posterPath: String
    let releaseDate: String
    let title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIds = "genre_ids"
        case identifier = "id"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview
        case popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
