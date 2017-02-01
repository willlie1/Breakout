//
//  HighScoresTableViewController.swift
//  BreakOut
//
//  Created by Wilko Zonnenberg on 21-12-16.
//  Copyright © 2016 Wilko Zonnenberg. All rights reserved.
//

import UIKit

class HighScoresTableViewController: UITableViewController {

    var highScores: [Int:[Int:String]] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        highScores = SettingsHelper.getHighScore()
        self.tableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highScores.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HighScoreTableViewCell", for: indexPath) as? HighScoreTableViewCell
        let highScore = highScores[indexPath.row]
        if let score = highScore?.first?.key {
            cell?.setLabels(place: String(indexPath.row.advanced(by: 1)), name: (highScore?.first?.value)!, score: String(score))
        }

        return cell!
    }
 
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "HighScores"
    }
}
