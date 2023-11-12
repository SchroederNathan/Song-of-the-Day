//
//  EntryDetailViewController.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-11-04.
//

import UIKit

class EntryDetailViewController: UIViewController {
    
    // MARK: - Properties
    var passedEntry: Journal!

    // MARK: - Outlets
    @IBOutlet var songNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var albumNameLabel: UILabel!
    @IBOutlet var goodDayImage: UIButton!
    @IBOutlet var badDayImage: UIButton!
    @IBOutlet var messageLabel: UITextView!
    
    @IBOutlet var albumImageView: UIImageView!
    @IBOutlet var cardBackround: UIView!
    @IBOutlet var messageBackround: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(passedEntry.text)
        songNameLabel.text = passedEntry.song.trackName
        artistNameLabel.text = passedEntry.song.artistName
        albumNameLabel.text = passedEntry.song.collectionName
        fetchImage(for: passedEntry.song.artworkUrl100!, for: albumImageView)
        
        if passedEntry.goodMood {
            goodDayImage.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            badDayImage.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
        } else {
            goodDayImage.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            badDayImage.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
            
        }
        
        messageLabel.text = passedEntry.text
        
        albumImageView.layer.cornerRadius = 15
        cardBackround.layer.cornerRadius = 15
        messageBackround.layer.cornerRadius = 15
        
        
    }
    
    // MARK: - Fetch Images
    func fetchImage(for path: String, for albumImage: UIImageView) {
        
        guard let imagePath = URL(string: path) else { return }
        
        let imageFetchTask = URLSession.shared.downloadTask(with: imagePath) {
            url, response, error in
            if error == nil, let url = url, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    // Set the imageView to the current indexed movie
                    albumImage.image = image
                }
            }
        }
            
        imageFetchTask.resume()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
