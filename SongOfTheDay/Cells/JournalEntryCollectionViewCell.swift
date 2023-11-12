//
//  JournalEntryCollectionViewCell.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-10-27.
//

import UIKit

protocol CustomEntryCellDelegate: AnyObject {
    func passEntryData(data: Journal)
}

class JournalEntryCollectionViewCell: UICollectionViewCell {
    
    var delegate: CustomEntryCellDelegate?
    var currentEntry: Journal!
    
    // MARK: Outlets
    @IBOutlet var songArtwork: UIImageView!
    @IBOutlet var songInfo: UILabel!
    @IBOutlet var goodDayButton: UIImageView!
    @IBOutlet var badDayButton: UIImageView!
    @IBOutlet var journalDate: UILabel!
    
    // MARK: Actions
    @IBAction func detailButton(_ sender: UIButton) {
        delegate?.passEntryData(data: currentEntry)
    }
}
