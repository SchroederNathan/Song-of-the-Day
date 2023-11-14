//
//  EntryDetailViewController.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-11-04.
//

import UIKit
import CoreData

class EntryDetailViewController: UIViewController, SongSelectViewControllerDelegate {
    
    // Core data stack
    lazy private var coreDataStack = CoreDataStack.coreDataStack
    
    // MARK: - Properties
    var passedEntry: Journal!
    
    var currentSong: Song!
    var currentMood: Bool!
    
    var editMode = false

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
    
    @IBOutlet var selectSongButtonImage: UIButton!
    
    @IBAction func editButton(_ sender: UIBarButtonItem) {
        //navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.accent ]
        toggleEdit(navButton: sender)

    }
    
    func toggleEdit(navButton: UIBarButtonItem) {
        if editMode != true {
            selectSongButtonImage.isHidden = false
            self.title = "Edit Mode"
            navButton.image = UIImage(systemName: "checkmark")
            messageLabel.isEditable = true
            editMode.toggle()
        } else {
            // Save object changes
            passedEntry.song = currentSong
            passedEntry.goodMood = currentMood
            passedEntry.text = messageLabel.text
            coreDataStack.saveContext()
            
            
            selectSongButtonImage.isHidden = true
            self.title = "Entry Details"
            navButton.image = UIImage(systemName: "pencil")
            messageLabel.isEditable = false
            editMode.toggle()
        }

    }
    
    // MARK: - Actions
    @IBAction func goodDayButton(_ sender: UIButton) {
        if editMode {
            moodToggle(mood: true)
            print(currentMood!)
        }
    }
    @IBAction func badDayButton(_ sender: UIButton) {
        if editMode {
            moodToggle(mood: false)
            print(currentMood!)
            
        }
    }
    func moodToggle(mood: Bool) {
        if mood {
            goodDayImage.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            badDayImage.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
            currentMood = true
            
        } else {
            goodDayImage.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            badDayImage.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
            currentMood = false

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectSongButtonImage.isHidden = true
        
        //navigationController?.navigationBar.prefersLargeTitles = false
        
        currentSong = passedEntry.song
        currentMood = passedEntry.goodMood
        
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
    
    func doSomethingWith(data: TempSong) {
        
        // Setup the UI according to the selected song
        songNameLabel.text = data.trackName
        artistNameLabel.text = data.artistName
        albumNameLabel.text = data.collectionName
        fetchImage(for: data.artworkUrl100, for: albumImageView)
        
        currentSong.trackName = data.trackName
        currentSong.artistName = data.artistName
        currentSong.collectionName = data.collectionName
        currentSong.previewUrl = data.previewUrl
        currentSong.artworkUrl100 = data.artworkUrl100
        
        print(currentSong ?? data)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let displayVC = segue.destination as! SongSelectViewController
        displayVC.delegate = self
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if !editMode {
            return false
        }
        return true
    }

}
