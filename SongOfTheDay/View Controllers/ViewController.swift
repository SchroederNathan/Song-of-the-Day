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
    
    //MARK: - Properties
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Journal>

    // Journal to be passed to next detail view controller
    var passedJournal: Journal?
    
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
        
        // Set custom font to title
        if let customFont = UIFont(name: "Open Sans Regular Condensed Bold", size: 40) {
            navigationController?.navigationBar.largeTitleTextAttributes =
            [NSAttributedString.Key.font: customFont]
        }
        
        
        // Make title large
        navigationController?.navigationBar.prefersLargeTitles = true
        setupLongGestureRecognizerOnCollection()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchJournalEntrys()
        
    }
    
    // Long press gesture to delete journal entries in edit mode
    func setupLongGestureRecognizerOnCollection() {
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        collectionView?.addGestureRecognizer(longPressedGesture)
    }
    
    // Delete the items from core data and array when long press is triggered
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .began) {
            return
        }
        
        if editMode {
            let location = gestureRecognizer.location(in: collectionView)
            
            guard let indexPath = collectionView?.indexPathForItem(at: location) else { return }
            
            // Find the selected cell
            let selectedEntry = journalEntrys[indexPath.row]
            // Delete from core data stack
            coreDataStack.managedContext.delete(selectedEntry)
            // Delete from array
            journalEntrys.remove(at: indexPath.row)
            
            // Save core data and reload the collection view
            coreDataStack.saveContext()
            fetchJournalEntrys()
        }
    }
    
    func toggleEdit(navButton: UIBarButtonItem) {
        // Edit mode on
        if editMode != true {
            self.title = "Long Press to Delete"
            navButton.image = UIImage(systemName: "checkmark")
            editMode.toggle()
        // Edit mode off
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
            
            // Disable detail view buttons if edit mode is enabled
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
                    // Set the imageView to the current song
                    cell.songArtwork.image = image
                }
            }
        }
        imageFetchTask.resume()
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Pass the entry that was tapped to the Detail View Controller
        guard let passed = passedJournal else { return }
        
        // Pass the entry to the detail view controller
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
