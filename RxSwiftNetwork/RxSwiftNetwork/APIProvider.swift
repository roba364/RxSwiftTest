//
//  APIProvider.swift
//  RxSwiftNetwork
//
//  Created by SofiaBuslavskaya on 30/04/2020.
//  Copyright © 2020 Sergey Borovkov. All rights reserved.
//

import Foundation
import RxSwift

class APIProvider {
    
    func getRepositories(_ githubID: String) -> Observable<[Repository]> {
        guard
            !githubID.isEmpty,
            let url = URL(string: "https://api.github.com/users/\(githubID)/repos")
            else { return Observable.just([])}
        
        // создаем запрос, retry() позволяет перехватить генерированную ошибку из главного Observable, если ошибка пришла, он попытается повторить действие нужное нам количество раз (3)
        return URLSession.shared
            .rx
            .json(request: URLRequest(url: url))
            .retry(3)
            .map({
                var repositories = [Repository]()
                
                if let items = $0 as? [[String: AnyObject]] {
                    items.forEach({
                        guard
                            let name = $0["name"] as? String,
                            let url = $0["html_url"] as? String
                            else { return }
                        repositories.append(Repository(name: name, url: url))
                    })
                }
                
                return repositories 
            })
    }
}
