//
//  Song.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-10-26.
//

import Foundation

struct TempSongs: Decodable {
    var results: [TempSong]
}

struct TempSong: Codable, Hashable {
    var artistName: String
    var collectionName: String
    var trackName: String
    var previewUrl: String
    var artworkUrl100: String
}
