//
//  ViewController.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-10-12.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - Properties
    var songs = [Song]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after load
        
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
                    let results = try decoder.decode(Songs.self, from: data)
                    
                    self.songs = results.results
                    
                    print(self.songs[3])
                    
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
                
//                DispatchQueue.main.async {
//                    self.createSnapshot()
//                }
                
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

