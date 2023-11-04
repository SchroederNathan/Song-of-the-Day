//
//  Song+CoreDataProperties.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-11-03.
//
//

import Foundation
import CoreData


extension Song {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Song> {
        return NSFetchRequest<Song>(entityName: "Song")
    }

    @NSManaged public var artistName: String?
    @NSManaged public var artworkUrl100: String?
    @NSManaged public var collectionName: String?
    @NSManaged public var previewUrl: String?
    @NSManaged public var trackName: String?
    @NSManaged public var journal: Journal?

}

extension Song : Identifiable {

}
