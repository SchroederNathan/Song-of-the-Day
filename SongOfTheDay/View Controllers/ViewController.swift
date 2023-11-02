//
//  ViewController.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-10-12.
//

import UIKit
import CoreData
import AVKit

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



}

