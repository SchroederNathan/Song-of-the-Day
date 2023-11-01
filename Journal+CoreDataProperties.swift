//
//  Journal+CoreDataProperties.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-11-01.
//
//

import Foundation
import CoreData


extension Journal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Journal> {
        return NSFetchRequest<Journal>(entityName: "Journal")
    }
    

    @NSManaged public var goodMood: Bool
    @NSManaged public var text: String?
    @NSManaged public var date: Date?
    @NSManaged public var song: Song?

}

extension Journal : Identifiable {

}
