//
//  SongSelectTableViewCell.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-11-01.
//

import UIKit

protocol CustomCellDelegate: AnyObject {
    func playCellSong(forUrl urlString: String, progressView: UIProgressView, button: UIButton)
}

class SongSelectTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var delegate: CustomCellDelegate?
    var playbackUrlString: String!
    var currentProgressView: UIProgressView!
    
    var playing = false
    
    // MARK: - Outlets
    @IBOutlet var songArtwork: UIImageView!
    @IBOutlet var songNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var albumNameLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var backView: UIView!
    
    //Audio
    @IBAction func playSong(_ sender: UIButton) {
        delegate?.playCellSong(forUrl: playbackUrlString, progressView: progressView, button: sender)
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
