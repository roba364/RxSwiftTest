//
//  ViewModel.swift
//  RxSwiftNetwork
//
//  Created by SofiaBuslavskaya on 30/04/2020.
//  Copyright © 2020 Sergey Borovkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct ViewModel {
    
    let searchText = BehaviorRelay<String>(value: "")
    let disposeBag = DisposeBag()
    
    let apiProvider: APIProvider
    var data: Driver<[Repository]>
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
        
        // throttle из нашего главного Observable берет лишь элементы, после которых не было новых элементов n-секунд(указываем в первом параметре, таймер), второй параметр показывает в каком потоке выполняем
        data = self.searchText.asObservable()
                              .throttle(0.3, scheduler: MainScheduler.instance)
            // этот метож пропускает все повторяющиеся подряд идущие элементы
        .distinctUntilChanged()
            // каждый элемент главного Observable превращается в отдельный Observable
        .flatMapLatest({
            apiProvider.getRepositories($0)
            // позволяет перехватить ошибку и заменить ее на соответствующий элемент
            // после этого главный Observable вернет нам complete
            }).asDriver(onErrorJustReturn: [])
    }
    
    
}
