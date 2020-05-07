//
//  SectionModelFood.swift
//  RxSwiftTest
//
//  Created by SofiaBuslavskaya on 30/04/2020.
//  Copyright © 2020 Sergey Borovkov. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

class SectionModelFood {
    
    let foods = Observable.just([
        SectionModel(model: "B", items: [Food(name: "burger", flickrID: "mens-burget")]),
        SectionModel(model: "P", items: [Food(name: "pizza", flickrID: "parma's pizza")]),
        SectionModel(model: "S", items: [Food(name: "salate", flickrID: "greece-salate")])])
}
