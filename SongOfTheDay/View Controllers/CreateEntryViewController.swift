//
//  CreateEntryViewController.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-10-12.
//

import UIKit
import AVKit

class CreateEntryViewController: UIViewController, SongSelectViewControllerDelegate, UIGestureRecognizerDelegate {

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
    @IBOutlet var audioButtonImage: UIButton!
    
    // MARK: - Actions
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
    
    @IBAction func goodDayButton(_ sender: UIButton) {
        moodToggle(mood: true)
        print(currentMood!)
    }
    @IBAction func badDayButton(_ sender: UIButton) {
        moodToggle(mood: false)
        print(currentMood!)
    }
    
    func moodToggle(mood: Bool) {
        // If good mood
        if mood {
            goodDayButtonImage.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            badDayButtonImage.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
            currentMood = true
            
        // If bad mood
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
            
            // Save to core data
            coreDataStack.saveContext()
            
            print(newJournalEntry)
            
            createdEntryMessage()
            
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

        // Create corner radius for the views
        messageBackground.layer.cornerRadius = 15
        songBackground.layer.cornerRadius = 15
        albumImageView.layer.cornerRadius = 15
        
        messageBox.delegate = self
        
        // Looks for single or multiple taps and dismiss's keyboard
         let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        // Doesn't interdere with other tap gestures now
        tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        
        // Adds a swipe gesture to delete current selected song
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        
        // Add the gesture to the card background
        songBackground.addGestureRecognizer(swipeRight)
        
        // Long press gesture on album image to scale image 2X
        let longPressGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        albumImageView.isUserInteractionEnabled = true
        albumImageView.addGestureRecognizer(longPressGestureRecognizer)
        
        // Long press properties
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.delaysTouchesBegan = true
        
        for fontFamilyName in UIFont.familyNames{
            for fontName in UIFont.fontNames(forFamilyName: fontFamilyName){
                print("Family: \(fontFamilyName)     Font: \(fontName)")
            }
        }
        
        // Set custom font to title
        if let customFont = UIFont(name: "Open Sans Regular Condensed Bold", size: 40) {
            navigationController?.navigationBar.largeTitleTextAttributes =
            [NSAttributedString.Key.font: customFont]            
        }

    }
    
    // MARK: Gesture recognizer methods
    
    // Long press gesture to scale image
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {

           let tappedImage = tapGestureRecognizer.view as! UIImageView

           // get existing width and height of image and double it

           UIView.animate(withDuration: 1) {

               //transform the image to 1.5 x its size

               tappedImage.transform = CGAffineTransform(scaleX: 1.23, y: 1.23)

           } completion: { _ in

                 //when the animation is completed – return it back to its original size

               UIView.animate(withDuration: 2.5) {

                   tappedImage.transform = .identity

               }
           }
       }
    
    // Swipe gessture to delete current selected song
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if swipeGesture.direction == UISwipeGestureRecognizer.Direction.right {
                // Make current song empty
                currentSong = nil
                
                // Reset song card UI
                self.songNameLabel.text = "Song Name"
                self.artistNameLabel.text = "Artist Name"
                self.albumNameLabel.text = "Album Name"
                self.albumImageView.image = UIImage(systemName: "questionmark.app.fill")
                
                togglePlayer(button: audioButtonImage)
                progressView.progress = 0.0
                
            }
        }
    }
    
    // Use data that was passed to the view controller
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
        
        // toggles audio off
        if isPlaying {
            isPlaying.toggle()
            // Change image
            if button.imageView?.image != UIImage(systemName: "play.circle.fill") {
                button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            }
            
            progressView.progress = 0.0
            audioPlayer.pause()
            
        // Toggles audio on
        } else {
            isPlaying.toggle()
            // Change image
            if button.imageView?.image != UIImage(systemName: "stop.circle.fill") {
                button.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
            }
            audioPlayer.play()
        }
    }
    
    // MARK: - Alert methods
    func errorMessage(error: String, context: String) {
        let alert = UIAlertController(title: error, message: context, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: Animation methods
    func createdEntryMessage() {
        // Start custom animation
        let customAnimation = CustomAnimation()
        customAnimation.frame = view.bounds
        customAnimation.isOpaque = false
        
        // Apply some visual effects for the animation
        let blurryBackground = UIBlurEffect(style: .regular)
        let blurryView = UIVisualEffectView(effect: blurryBackground)
        blurryView.frame = view.bounds
        
        // Add the animation and its effects to the subview
        view.addSubview(blurryView)
        view.addSubview(customAnimation)
        
        // Disable user interactivity
        view.isUserInteractionEnabled = false
        
        // Play the animation
        customAnimation.showDialog()
        
        // How long until it switches to the other view controller
        let delay = 1.25
        
        DispatchQueue.main.asyncAfter(deadline: .now()+delay, execute:  {
            // Change back to viewcontroller.swift
            self.tabBarController?.selectedIndex = 0
            
            // Get rid of the visual effects from animation
            for subview in self.view.subviews {
                if subview is UIVisualEffectView {
                    subview.removeFromSuperview()
                }
            }
            
            // Reset objects
            self.currentMood = nil
            self.messageBox.text = ""
            self.currentSong = nil
            
            // Reset the mood button images
            self.goodDayButtonImage.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            self.badDayButtonImage.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
            
            // Reset song card UI
            self.songNameLabel.text = "Song Name"
            self.artistNameLabel.text = "Artist Name"
            self.albumNameLabel.text = "Album Name"
            self.albumImageView.image = UIImage(systemName: "questionmark.app.fill")
            
            self.view.isUserInteractionEnabled = true
        })

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

// MARK: Text Field Delegate
extension CreateEntryViewController: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}


