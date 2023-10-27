//
//  JournalEntryCollectionViewCell.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-10-27.
//

import UIKit

class JournalEntryCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet var songArtwork: UIImageView!
    @IBOutlet var songInfo: UILabel!
    @IBOutlet var goodDayButton: UIImageView!
    @IBOutlet var badDayButton: UIImageView!
    @IBOutlet var journalDate: UILabel!
}
