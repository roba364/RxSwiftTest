//
//  ViewController.swift
//  RxSwiftNetwork
//
//  Created by SofiaBuslavskaya on 30/04/2020.
//  Copyright © 2020 Sergey Borovkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar { return searchController.searchBar }
    let disposeBag = DisposeBag()
    var repositoriesViewModel: ViewModel?
    var apiProvider = APIProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        
        repositoriesViewModel = ViewModel(apiProvider: apiProvider)
        if let viewModel = repositoriesViewModel {
            // начинаем следить
            viewModel.data
                .drive(tableView.rx.items(cellIdentifier: "Cell")) {_, repository, cell in
                    cell.textLabel?.text = repository.name
                    cell.detailTextLabel?.text = repository.url
            }.disposed(by: disposeBag)
            
            searchBar.rx.text.orEmpty.bind(to: viewModel.searchText).disposed(by: disposeBag)
            searchBar.rx.cancelButtonClicked.map({""}).bind(to: viewModel.searchText).disposed(by: disposeBag)
            
            viewModel.data.asDriver()
                .map({
                    "\($0) Repositories"
                })
                .drive(navigationItem.rx.title)
                .disposed(by: disposeBag)
        }
    }
    
    func configureSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchBar.showsCancelButton = true
        searchBar.text = "yoba364"
        searchBar.placeholder = "Search user..."
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
    }

}

