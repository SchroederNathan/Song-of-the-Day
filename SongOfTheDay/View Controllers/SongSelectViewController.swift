//
//  SongSelectViewController.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-11-01.
//

import UIKit
import AVKit

class SongSelectViewController: UIViewController, UIGestureRecognizerDelegate {
    
    weak var delegate : SongSelectViewControllerDelegate?

    
    typealias DataSource = UITableViewDiffableDataSource<Section, FetchSong>

    // MARK: - properties
    var songs = [FetchSong]()
    private lazy var tableDataSource = createDataSource()
    let cellIdentifier = "songCell"
    
    // Audio properties
    var audioPlayer = AVPlayer()
    var playerItem: AVPlayerItem!
    var isPlaying = false
    var audioButton = UIButton()
    
    var songUrl = ""

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    // MARK: - Data Source Methods
    
    func createDataSource() -> DataSource {
        let dataSource = DataSource(tableView: tableView) { tableView, indexPath, song in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! SongSelectTableViewCell
            
            // Give image and background view corner radius's
            cell.backView.layer.cornerRadius = 15
            cell.songArtwork.layer.cornerRadius = 15
            
            // Set text
            cell.songNameLabel.text = song.trackName
            cell.artistNameLabel.text = song.artistName
            cell.albumNameLabel.text = song.collectionName
            
            // Set text and image for each cell
            self.fetchImage(for: song.artworkUrl100, for: cell)
            
            cell.delegate = self
            
            // Song playback and progress
            cell.playbackUrlString = song.previewUrl
            cell.progressView = cell.progressView
            
            // Song to pass back to previous controller
            cell.currentSong = song
            
            return cell
        }
        
        return dataSource
    }
    
    func createSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, FetchSong>()
        snapshot.appendSections([.main])
        snapshot.appendItems(songs)
        snapshot.reloadItems(songs)
        tableDataSource.apply(snapshot)
    }
    
    //MARK: - Fetch methods
    
    func fetchImage(for path: String, for cell: SongSelectTableViewCell) {
        
        guard let imagePath = URL(string: path) else { return }
        
        let imageFetchTask = URLSession.shared.downloadTask(with: imagePath) {
            url, response, error in
            if error == nil, let url = url, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    // Set the imageView to the current indexed song
                    cell.songArtwork.image = image
                }
            }
        }
            
        imageFetchTask.resume()
    }
    
    func fetchSongInfo(query: String) {
        
        // Create a url including the users searched term
        var apiUrl = "https://itunes.apple.com/search?term="
        apiUrl = apiUrl.appending(query)
        apiUrl = apiUrl.appending("&entity=song")
        
        // turn string into valid URL
        guard let url = URL(string: apiUrl) else {return}
        print(url)
        
        
        let dataTask = URLSession.shared.dataTask(with: url) {
            data, response, error in
            
            if let error = error {
                print("There was a problem - \(error.localizedDescription)")
            } else {
                do {
                    guard let data = data else {
                        print("No data returned")
                        return
                    }
                    
                    // Decode the json to a valid array
                    let decoder = JSONDecoder()
                    let results = try decoder.decode(FetchSongs.self, from: data)
                    
                    // Put all searched songs into the songs array
                    self.songs = results.results
                    
                } catch DecodingError.valueNotFound(let error, let message) {
                    DispatchQueue.main.async {
                        self.errorMessage(error: "Value is missing: \(error)", context: message.debugDescription)
                    }
                } catch DecodingError.typeMismatch(let error, let message) {
                    DispatchQueue.main.async {
                        self.errorMessage(error: "Types do not match: \(error)", context: message.debugDescription)
                    }
                } catch DecodingError.keyNotFound(let error, let message) {
                    DispatchQueue.main.async {
                        self.errorMessage(error: "Incorrect property name: \(error)", context: message.debugDescription)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage(error: "Unknown error has occured", context: String(describing: error))
                    }
                }
                
                DispatchQueue.main.async {
                    self.createSnapshot()
                }
                
            }
        }
        dataTask.resume()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Pauses the audio once song is either selected or view is closed
        audioPlayer.pause()
    }
    
    // Display alert for error messages
    func errorMessage(error: String, context: String) {
        let alert = UIAlertController(title: error, message: context, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}

// MARK: Search bar delegate
extension SongSelectViewController: UISearchBarDelegate {
    
    // Function used when the user taps search or the enter button on the keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Conveert text so it is safe for URL's
        guard let text = searchBar.text, !text.isEmpty, let safeText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        fetchSongInfo(query: safeText)
        
        searchBar.resignFirstResponder()
    }
    
}

// MARK: Audio delegate
extension SongSelectViewController: CustomCellDelegate {
    
    // MARK: - Audio methods
    func playCellSong(forUrl urlString: String, progressView: UIProgressView, button: UIButton) {
        guard let url = URL(string: urlString) else { return }
        playerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
        
        //Toggles audio player to play and stop as well as change the images
        togglePlayer(button: button, progressView: progressView)
        
        
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
    
    func togglePlayer(button: UIButton, progressView: UIProgressView) {
        // Turn off
        if isPlaying {
            isPlaying.toggle()
            // Change image
            button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            progressView.progress = 0.0
            audioPlayer.pause()
        // Turn on
        } else {
            isPlaying.toggle()
            // Change image
            button.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
            audioPlayer.play()
        }
    }
    
    // MARK: - Pass song data
    func passSongData(data: FetchSong) {
        
        // Pass data to previous controller
        if let delegate = delegate{
            delegate.doSomethingWith(data: data)
            print("Worked!")
        }
        
        // Dismiss view controller
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    
}
// MARK: - Protocol
protocol SongSelectViewControllerDelegate : NSObjectProtocol{
    func doSomethingWith(data: FetchSong)

}



