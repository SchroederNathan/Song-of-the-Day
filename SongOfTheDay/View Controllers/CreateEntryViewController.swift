//
//  CreateEntryViewController.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-10-12.
//

import UIKit

class CreateEntryViewController: UIViewController {
    
    // MARK: - Properties
    
    var newJournalEntry = Journal()
    // true = good day
    // false = bad day
    var dayStatus = true
    
    // MARK: - Actions
    @IBAction func goodDayButton(_ sender: UIButton) {
        sender.imageView?.image = UIImage(named: "face.smiling.inverse")
    }
    @IBAction func badDayButton(_ sender: UIButton) {
        if dayStatus == true {
            sender.imageView?.image = UIImage(named: "face.smiling.inverse")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
