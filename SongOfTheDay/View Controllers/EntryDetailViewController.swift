//
//  EntryDetailViewController.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-11-04.
//

import UIKit
import CoreData
import AVKit

class EntryDetailViewController: UIViewController, SongSelectViewControllerDelegate {
    
    // Core data stack
    lazy private var coreDataStack = CoreDataStack.coreDataStack
    
    // MARK: - Properties
    var passedEntry: Journal!
    
    var currentSong: Song!
    var currentMood: Bool!
    
    var editMode = false
    
    // Audio properties
    var audioPlayer = AVPlayer()
    var playerItem: AVPlayerItem!
    var isPlaying = false
    var audioButton = UIButton()

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
    
    // Audio outlets
    @IBOutlet var selectSongButtonImage: UIButton!
    @IBOutlet var playButtonImage: UIButton!
    @IBOutlet var progressView: UIProgressView!
    
    // MARK: Actions
    @IBAction func editButton(_ sender: UIBarButtonItem) {
        toggleEdit(navButton: sender)
    }

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
    
    @IBAction func playAudioButton(_ sender: UIButton) {
        playSong(forUrl: currentSong.previewUrl!, progressView: progressView, button: sender)

    }
    
    // MARK: Toggle methods
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
        
        // Looks for single or multiple taps and dismiss's keyboard
         let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        // Doesn't interdere with other tap gestures now
        tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Pauses the audio once song is either selected or view is closed
        audioPlayer.pause()
    }
    
    // MARK: - Fetch Images
    func fetchImage(for path: String, for albumImage: UIImageView) {
        
        guard let imagePath = URL(string: path) else { return }
        
        let imageFetchTask = URLSession.shared.downloadTask(with: imagePath) {
            url, response, error in
            if error == nil, let url = url, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    // Set the imageView to the current song
                    albumImage.image = image
                }
            }
        }
            
        imageFetchTask.resume()
    }
    
    // Use data that was passed to the view controller
    func doSomethingWith(data: FetchSong) {
        
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
    }
    
    // MARK: - Audio methods
    func playSong(forUrl urlString: String, progressView: UIProgressView, button: UIButton) {
        guard let url = URL(string: urlString) else { return }
        playerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
        
        togglePlayer(button: button)
        
        audioButton = button
        
        // Triggers when preview song is done playing
        NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayer.currentItem)
        
        let interval = CMTimeMake(value: 1, timescale: 10)
        
        // Updates progressView
        audioPlayer.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { _ in
            if self.audioPlayer.status == .readyToPlay {
                // run the update to the progress
                self.updateProgress(for: self.playerItem, progressView: progressView)
            }
        }
        
    }
    
    // Calculates and displays progress of songs on the progressView in tableview cells
    func updateProgress(for item: AVPlayerItem, progressView: UIProgressView) {
        let duration = CMTimeGetSeconds(item.duration)
        let currentTime = CMTimeGetSeconds(item.currentTime())
        
        progressView.progress = Float(currentTime/duration)
        
        if progressView.progress >= 1.0 {
            progressView.progress = 0.0
        }
        
    }
    
    // Reset to play button image when preview song is done playing
    @objc func finishedPlaying() {
        audioButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
    }
    
    func togglePlayer(button: UIButton) {
        if isPlaying {
            isPlaying.toggle()
            // Change image
            button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            progressView.progress = 0.0
            audioPlayer.pause()
        } else {
            isPlaying.toggle()
            // Change image
            button.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
            audioPlayer.play()
        }
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let displayVC = segue.destination as! SongSelectViewController
        displayVC.delegate = self
        togglePlayer(button: playButtonImage)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if !editMode {
            return false
        }
        return true
    }
    
    // Dissmiss's keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}
