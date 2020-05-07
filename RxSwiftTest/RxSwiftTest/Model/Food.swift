//
//  Food.swift
//  RxSwiftTest
//
//  Created by SofiaBuslavskaya on 29/04/2020.
//  Copyright © 2020 Sergey Borovkov. All rights reserved.
//

import UIKit
import RxDataSources

struct Food {
    let name: String
    let flickrID: String
    var image: UIImage?
    
    init(name: String, flickrID: String) {
        self.name = name
        self.flickrID = flickrID
        image = UIImage(named: flickrID)
    }
}

extension Food: IdentifiableType {
    typealias Identity = String
    
    var identity: Identity { return flickrID }
}
