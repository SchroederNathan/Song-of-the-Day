//
//  ViewController.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-10-12.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Journal>

    
    //MARK: - Properties
    var songs = [Song]()
    var journalEntrys = [Journal]()
    lazy private var coreDataStack = CoreDataStack.coreDataStack


    let cellIdentifier = "journalCell"
    
    private lazy var collectionViewDataSource = createDataSource()
    
    //MARK: - Outlets
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after load
        //fetchTempEntrys()
        
        // Make title large
        navigationController?.navigationBar.prefersLargeTitles = true

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchJournalEntrys()

    }
    
    // MARK: - Datasource Methods
    
    func createDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, entry in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as? JournalEntryCollectionViewCell
            self.fetchImage(for: entry.song!.artworkUrl100 ?? "", for: cell!)
            cell?.songInfo.text = "\(entry.song?.artistName ?? "error") • \(entry.song?.artistName ?? "error")"
            cell?.journalDate.text = entry.date?.description
            
            // Give each cell a corner radius
            cell?.layer.cornerRadius = 15
            cell?.songArtwork.layer.cornerRadius = 15
            
            return cell
        }
        return dataSource
    }
    
    func createSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Journal>()
        snapshot.appendSections([.main])
        snapshot.appendItems(journalEntrys)
        snapshot.reloadItems(journalEntrys)
        collectionViewDataSource.apply(snapshot)
    }
    
    func fetchJournalEntrys() {
        let fetchRequest: NSFetchRequest<Journal> = Journal.fetchRequest()
        
        // Sort data by date of journal entry
        let sorting = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sorting]
        
        do {
            // Put the data into the favourites array
            journalEntrys = try coreDataStack.managedContext.fetch(fetchRequest)
            
            self.createSnapshot()
        } catch  {
            print("Error - could not fetch: \(error.localizedDescription)")
        }
    }
    
//    func fetchTempEntrys() {
//        fetchSongInfo(query: "Prince")
//        
//    }
    
    // MARK: - Fetch Images
    func fetchImage(for path: String, for cell: JournalEntryCollectionViewCell) {
        
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
    
//    func fetchSongInfo(query: String) {
//        
//        var apiUrl = "https://itunes.apple.com/search?term="
//        apiUrl = apiUrl.appending(query)
//        apiUrl = apiUrl.appending("&entity=song")
//        // turn string into valid URL
//        guard let url = URL(string: apiUrl) else {return}
//        print(url)
//        
//        
//        let dataTask = URLSession.shared.dataTask(with: url) {
//            data, response, error in
//            
//            if let error = error {
//                print("There was a problem - \(error.localizedDescription)")
//            } else {
//                do {
//                    guard let data = data else {
//                        print("No data returned")
//                        return
//                    }
//                    
//                    // Decode the json to a valid array
//                    let decoder = JSONDecoder()
//                    let results = try decoder.decode(Songs.self, from: data)
//                    
//                    self.songs = results.results
//                    
////                    var newEntry = Journal(song: self.songs.first, goodMood: true, text: "This is an entry", Date: Date.now)
////
////                    var newEntry1 = Journal(song: self.songs[1], goodMood: true, text: "This is an entry", Date: Date.now)
////                    var newEntry2 = Journal(song: self.songs[2], goodMood: true, text: "This is an entry", Date: Date.now)
////                    var newEntry3 = Journal(song: self.songs[3], goodMood: true, text: "This is an entry", Date: Date.now)
////                    var newEntry4 = Journal(song: self.songs[4], goodMood: true, text: "This is an entry", Date: Date.now)
////                    var newEntry5 = Journal(song: self.songs[5], goodMood: true, text: "This is an entry", Date: Date.now)
////
////
////                    self.journalEntrys.append(newEntry)
////                    self.journalEntrys.append(newEntry1)
////                    self.journalEntrys.append(newEntry2)
////                    self.journalEntrys.append(newEntry3)
////                    self.journalEntrys.append(newEntry4)
////                    self.journalEntrys.append(newEntry5)
//
//
//                    
//                } catch DecodingError.valueNotFound(let error, let message) {
//                    DispatchQueue.main.async {
//                        self.errorMessage(error: "Value is missing: \(error)", context: message.debugDescription)
//                    }
//                } catch DecodingError.typeMismatch(let error, let message) {
//                    DispatchQueue.main.async {
//                        self.errorMessage(error: "Types do not match: \(error)", context: message.debugDescription)
//                    }
//                } catch DecodingError.keyNotFound(let error, let message) {
//                    DispatchQueue.main.async {
//                        self.errorMessage(error: "Incorrect property name: \(error)", context: message.debugDescription)
//                    }
//                } catch {
//                    DispatchQueue.main.async {
//                        self.errorMessage(error: "Unknown error has occured", context: String(describing: error))
//                    }
//                }
//                
//                DispatchQueue.main.async {
//                    self.createSnapshot()
//                }
//                
//            }
//        }
//        dataTask.resume()
//    }
    
    // Display alert for error messages
    func errorMessage(error: String, context: String) {
        
        let alert = UIAlertController(title: error, message: context, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }


}

