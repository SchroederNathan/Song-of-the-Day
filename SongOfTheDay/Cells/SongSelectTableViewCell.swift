//
//  SongSelectTableViewCell.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-11-01.
//

import UIKit

class SongSelectTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet var songArtwork: UIImageView!
    @IBOutlet var songNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var albumNameLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var backView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
