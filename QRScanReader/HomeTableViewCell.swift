//
//  HomeTableViewCell.swift
//  QRScanReader
//
//  Created by Valluri, Madhuri on 2/16/18.
//  Copyright © 2018 myspe2. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var homeImageView: UIImageView!
    
    @IBOutlet weak var homeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
