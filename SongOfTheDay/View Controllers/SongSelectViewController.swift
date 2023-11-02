//
//  SongSelectViewController.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-11-01.
//

import UIKit
import AVKit

class SongSelectViewController: UIViewController {
    
    typealias DataSource = UITableViewDiffableDataSource<Section, TempSong>

    // MARK: - properties
    var songs = [TempSong]()
    private lazy var tableDataSource = createDataSource()
    let cellIdentifier = "songCell"
    
    // Audio properties
    var audioPlayer: AVPlayer!
    var playerItem: AVPlayerItem!
    var isPlaying = false
    
    var songUrl = ""

    @IBOutlet var tableView: UITableView!
    
    // MARK: - Audio Player methods
    func loadAudioPlayer(with urlString: String) {
        //Play audio
        guard let url = URL(string: urlString) else { return }
        playerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
    }
    
    func togglePlayer() {
        if isPlaying {
            isPlaying.toggle()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - Data Source Properties
    
    func createDataSource() -> DataSource {
        let dataSource = DataSource(tableView: tableView) { tableView, indexPath, song in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! SongSelectTableViewCell
            
            // Give image and background view corner radius's
            cell.backView.layer.cornerRadius = 7.5
            cell.songArtwork.layer.cornerRadius = 7.5
            
            // Set text
            cell.songNameLabel.text = song.trackName
            cell.artistNameLabel.text = song.artistName
            cell.albumNameLabel.text = song.collectionName
            
            // Set text and image for each cell
            self.fetchImage(for: song.artworkUrl100, for: cell)
            
            cell.delegate = self
            cell.playbackUrlString = song.previewUrl
            
            return cell
        }
        
        return dataSource
    }
    
    func createSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, TempSong>()
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
                    // Set the imageView to the current indexed movie
                    cell.songArtwork.image = image
                }
            }
        }
            
        imageFetchTask.resume()
    }
    
    func fetchSongInfo(query: String) {
        
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
                    let results = try decoder.decode(TempSongs.self, from: data)
                    
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
    
    // Display alert for error messages
    func errorMessage(error: String, context: String) {
        
        let alert = UIAlertController(title: error, message: context, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}

extension SongSelectViewController: UISearchBarDelegate {
    
    // Function used when the user taps search or the enter button on the keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Conveert text so it is safe for URL's
        guard let text = searchBar.text, !text.isEmpty, let safeText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        fetchSongInfo(query: safeText)
        print(safeText)
    }
}

// MARK: Audio delegate
extension SongSelectViewController: CustomCellDelegate {
    func playCellSong(forUrl urlString: String) {
        guard let url = URL(string: urlString) else { return }
        playerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
        audioPlayer.play()
    }
}


