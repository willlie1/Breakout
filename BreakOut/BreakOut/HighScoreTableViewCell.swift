//
//  HighScoreTableViewCell.swift
//  BreakOut
//
//  Created by Wilko Zonnenberg on 21-12-16.
//  Copyright © 2016 Wilko Zonnenberg. All rights reserved.
//

import UIKit

class HighScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!

    func setLabels(place: String, name: String, score: String){
        placeLabel.text = place
        nameLabel.text = name
        scoreLabel.text = score
    }

}
