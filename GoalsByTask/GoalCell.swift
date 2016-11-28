//
//  GoalCell.swift
//  GoalsByTask
//
//  Created by David Fierstein on 11/27/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit

class GoalCell: UITableViewCell {

    @IBOutlet weak var priority: UILabel!
    @IBOutlet weak var goalname: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
