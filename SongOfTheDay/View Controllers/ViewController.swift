//
//  ViewController.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-10-12.
//

import UIKit
import CoreData
import AVKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Journal>

    //    weak var delegate : ViewControllerDelegate?
    var passedJournal: Journal?
    
    //MARK: - Properties
    var songs = [Song]()
    var journalEntrys = [Journal]()
    lazy private var coreDataStack = CoreDataStack.coreDataStack
    
    var editMode = false
    
    var passedEntry: Journal!

    let cellIdentifier = "journalCell"
    
    private lazy var collectionViewDataSource = createDataSource()
    
    // MARK: - Outlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var viewEntryButton: UIBarButtonItem!
    
    // MARK: - Actions
    @IBAction func toggleEditButton(_ sender: UIBarButtonItem) {
        toggleEdit(navButton: sender)
        fetchJournalEntrys()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make title large
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchJournalEntrys()
        
    }
    
    func toggleEdit(navButton: UIBarButtonItem) {
        if editMode != true {
            self.title = "Edit Mode"
            navButton.image = UIImage(systemName: "checkmark")
            editMode.toggle()
        } else {
            self.title = "Journal Entries"
            navButton.image = UIImage(systemName: "pencil")
            editMode.toggle()
        }

    }
    
    // MARK: - Datasource Methods
    func createDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, entry in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as? JournalEntryCollectionViewCell
            
            cell?.delegate = self
            
            self.fetchImage(for: entry.song.artworkUrl100 ?? "", for: cell!)
            cell?.songInfo.text = "\(entry.song.artistName ?? "error") • \(entry.song.trackName ?? "error")"
            cell?.journalDate.text = entry.date.description
            
            if entry.goodMood == true {
                cell?.goodDayButton.image = UIImage(systemName: "hand.thumbsup.fill")
                cell?.badDayButton.image = UIImage(systemName: "hand.thumbsdown")
            } else {
                cell?.goodDayButton.image = UIImage(systemName: "hand.thumbsup")
                cell?.badDayButton.image = UIImage(systemName: "hand.thumbsdown.fill")
            }
            
            if self.editMode {
                cell?.viewEntryButtonImage.isHidden = true
            } else {
                cell?.viewEntryButtonImage.isHidden = false
            }
            
            cell?.currentEntry = entry
            
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
        let sorting = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sorting]
        
        do {
            // Put the data into the favourites array
            journalEntrys = try coreDataStack.managedContext.fetch(fetchRequest)
            
            self.createSnapshot()
        } catch  {
            print("Error - could not fetch: \(error.localizedDescription)")
        }
    }
    
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
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Pass the movie that was tapped to the Detail View Controller
//        let entryToPass = passedEntry  //.itemIdentifier(for: index)
        guard let passed = passedJournal else { return }
        
        if segue.identifier == "showSong" {
            let destinationVC = segue.destination as! EntryDetailViewController
            
            destinationVC.passedEntry = passed
            
        }
        
    }


}

extension ViewController: CustomEntryCellDelegate {
    func passEntryData(data: Journal) {
        print("passed entry")
        passedJournal = data
        performSegue(withIdentifier: "showSong", sender: nil)
    }
}

protocol ViewControllerDelegate : NSObjectProtocol{
    func doSomethingWithEntry(data: Journal)
}
