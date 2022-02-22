//
//  Movie.swift
//  MoviesApp
//
//  Created by Ahmed Soultan on 02/02/2022.
//

import Foundation

class Movie: Codable {
    var title:String = ""
    var image:String = ""
    var rating:Double = 0.0
    var releaseYear:Int = 0
    var genre:[String] = [""]
    
    init() {
        self.title = ""
        self.image = ""
        self.rating = 0.0
        self.releaseYear = 0
        self.genre = [""]
    }
    
    init(title: String, image: String, rating: Double, releaseYear: Int, genre: [String]) {
        self.title = title
        self.image = image
        self.rating = rating
        self.releaseYear = releaseYear
        self.genre = genre
    }
    
}
