//
//  HistoryTableViewCell.swift
//  QRScanReader
//
//  Created by Valluri, Madhuri on 2/19/18.
//  Copyright © 2018 myspe2. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var nextPosLabel: UILabel!
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var currentPosLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
