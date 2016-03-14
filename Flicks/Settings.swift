
//
//  Settings.swift
//  Flicks
//
//  Created by Hieu Rocker on 3/12/16.
//  Copyright © 2016 Hieu Rocker. All rights reserved.
//

import Foundation

class Settings {
    static let apiKey = "575b28f913208485baa95345c3fbbda7"
    static let apiRoot = "http://api.themoviedb.org/3/movie/"
    static let nowPlaying = "now_playing"
    static let topRated = "top_rated"
    static func getImageUrl(path: String, size: Int = 500) -> NSURL {
        return NSURL(string:"http://image.tmdb.org/t/p/w\(size)\(path)")!
    }
}