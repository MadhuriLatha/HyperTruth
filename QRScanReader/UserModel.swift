//
//  UserModel.swift
//  QRScanReader
//
//  Created by myspe2 on 2/7/18.
//  Copyright © 2018 myspe2. All rights reserved.
//

import Foundation

class UserDataModel {
    
    var userType: String!
    var isSelected: Bool
    var imageNmae: String!
    
    init(user: String, isSelect: Bool, image: String) {
        self.userType = user
        self.isSelected = isSelect
        self.imageNmae = image
    }
}
