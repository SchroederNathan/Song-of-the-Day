//
//  CreateEntryViewController.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-10-12.
//

import UIKit
import AVKit

class CreateEntryViewController: UIViewController, SongSelectViewControllerDelegate {

    // MARK: - Properties
    
    // Core data properties
    lazy private var coreDataStack = CoreDataStack.coreDataStack
    
    // Entry properties
    var currentSong: FetchSong!
    var currentMood: Bool!
    var message: String!
    
    // Audio properties
    var audioPlayer = AVPlayer()
    var playerItem: AVPlayerItem!
    var isPlaying = false
    var audioButton = UIButton()
    
    // MARK: - Outlets
    @IBOutlet var songNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var albumNameLabel: UILabel!
    @IBOutlet var albumImageView: UIImageView!
    @IBOutlet var songBackground: UIView!
    @IBOutlet var messageBackground: UIView!
    
    @IBOutlet var goodDayButtonImage: UIButton!
    @IBOutlet var badDayButtonImage: UIButton!
    @IBOutlet var messageBox: UITextView!
    
    
    @IBAction func addEntryButton(_ sender: UIBarButtonItem) {
        gatherEntryData()
    }
    
    // Audio action and outlet
    @IBAction func playAudioButton(_ sender: UIButton) {
        if currentSong != nil {
            playSong(forUrl: currentSong.previewUrl, progressView: progressView, button: sender)
        }

    }
    
    @IBOutlet var progressView: UIProgressView!
    
    
    // MARK: - Actions
    @IBAction func goodDayButton(_ sender: UIButton) {
        moodToggle(mood: true)
        print(currentMood!)
    }
    @IBAction func badDayButton(_ sender: UIButton) {
        moodToggle(mood: false)
        print(currentMood!)
    }
    
    func moodToggle(mood: Bool) {
        if mood {
            goodDayButtonImage.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            badDayButtonImage.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
            currentMood = true
            
        } else {
            goodDayButtonImage.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            badDayButtonImage.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
            currentMood = false

        }
    }
    
    func gatherEntryData() {
        // Make sure objects are not nil
        if currentMood != nil && messageBox.text != nil && currentSong != nil {
            // Create new journal object
            let newJournalEntry = Journal(context: self.coreDataStack.managedContext)
            
            newJournalEntry.date = Date()
            newJournalEntry.goodMood = currentMood
            newJournalEntry.text = messageBox.text!

            // Create new song object
            let newSong = Song(context: self.coreDataStack.managedContext)
            newSong.artistName = currentSong.artistName
            newSong.artworkUrl100 = currentSong.artworkUrl100
            newSong.collectionName = currentSong.collectionName
            newSong.previewUrl = currentSong.previewUrl
            newSong.trackName = currentSong.trackName
            
            newJournalEntry.song = newSong
            
            coreDataStack.saveContext()
            
            print(newJournalEntry)
        } else {
            if currentMood == nil && currentSong == nil && messageBox.text == "" {
               errorMessage(error: "You forgot something!", context: "Please dont forget to select a song, choose a mood and write a message.")
            } else if currentMood == nil && messageBox.text == "" {
                errorMessage(error: "You forgot something!", context: "Please dont forget to choose a mood and write a message.")
            } else if currentMood == nil && currentSong == nil {
                errorMessage(error: "You forgot something!", context: "Please dont forget to select a song and choose a mood.")
            } else if currentSong == nil && messageBox.text == "" {
                errorMessage(error: "You forgot something!", context: "Please dont forget to select a song and write a message.")
            } else if currentSong == nil {
                errorMessage(error: "You forgot something!", context: "Please dont forget to choose a song.")
            } else if currentMood == nil {
                errorMessage(error: "You forgot something!", context: "Please dont forget to choose a mood.")
            } else if messageBox.text == "" {
                errorMessage(error: "You forgot something!", context: "Please dont forget to write a message.")
            }
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true

        
        messageBackground.layer.cornerRadius = 15
        songBackground.layer.cornerRadius = 15
        albumImageView.layer.cornerRadius = 15
        
        messageBox.delegate = self
        
        // Looks for single or multiple taps and dismiss's keyboard
         let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        // Doesn't interdere with other tap gestures now
        tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)

    }
    
    func doSomethingWith(data: FetchSong) {
        
        // Setup the UI according to the selected song
        songNameLabel.text = data.trackName
        artistNameLabel.text = data.artistName
        albumNameLabel.text = data.collectionName
        fetchImage(for: data.artworkUrl100, imageView: albumImageView)
        
        currentSong = data
        
        print(data)
    }
    
    // MARK: - Fetch image
    func fetchImage(for path: String, imageView: UIImageView) {
        
        guard let imagePath = URL(string: path) else { return }
        
        let imageFetchTask = URLSession.shared.downloadTask(with: imagePath) {
            url, response, error in
            if error == nil, let url = url, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    // Set the imageView to the selected song
                    imageView.image = image
                }
            }
        }
            
        imageFetchTask.resume()
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
    
    // MARK: - Error functions
    func errorMessage(error: String, context: String) {
        let alert = UIAlertController(title: error, message: context, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let displayVC = segue.destination as! SongSelectViewController
        displayVC.delegate = self
    }
    
    // Dissmiss's keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }


}

extension CreateEntryViewController: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}


