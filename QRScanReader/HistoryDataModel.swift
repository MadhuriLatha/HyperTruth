//
//  HistoryDataModel.swift
//  QRScanReader
//
//  Created by Valluri, Madhuri on 2/19/18.
//  Copyright © 2018 myspe2. All rights reserved.
//

import UIKit

class HistoryDataModel {

    var  currentPosition: String!
    var  nextPosition: String!
    var  serialNumber: String!
    var  modelNumber: String!
    var  location: String!
    var counterfeitFlag: String!
    var dateAndtime: String!
    
    init(currentPos: String, nextPos: String, serialNum: String, modelNum: String, location: String, cfFlag: String, dateTime: String) {
        self.currentPosition = currentPos
        self.nextPosition = nextPos
        self.serialNumber = serialNum
        self.modelNumber = modelNum
        self.location = location
        self.counterfeitFlag = cfFlag
        self.dateAndtime = dateTime
    }

}
