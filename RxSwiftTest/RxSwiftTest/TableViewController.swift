//
//  TableViewController.swift
//  RxSwiftTest
//
//  Created by SofiaBuslavskaya on 29/04/2020.
//  Copyright © 2020 Sergey Borovkov. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class TableViewController: UIViewController {
    
    @IBOutlet weak var tableView = UITableView()
    
    let disposeBag = DisposeBag()
    
    // Создаем Observable последовательность вместо food-массива
    
//    let food = Observable.just([Food(name: "burger", flickrID: "mens-burget"),
//                Food(name: "pizza", flickrID: "parma's pizza"),
//                Food(name: "salate", flickrID: "greece-salate")])
    
    let foodsData = SectionModelFood()
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Food>>(configureCell: { (section, tableView, indexPath, foods) in
        let cell = tableView
    })

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Food>>(configureCell: { (section, tableView, indexPath, foods) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = foods.name
            cell.detailTextLabel?.text = foods.flickrID
            cell.imageView?.image = foods.image
            
        })
        
        foodsData.foods.bind(to: (tableView?.rx.items(dataSource: dataSource))!).disposed(by: disposeBag)
        
        // устанавливаем заголовки секций
        
//        dataSource.titleForHeaderInSection = { data, section in
//            data.sectionIndexTitles(for: self)
//        }
        
        // ---> FORWARD DELEGATE <---
        
        // Forward delegate - для простого представления таблицы нам нужно вызвать (tableView?.rx.items(cellIdentifier: "Cell") c клоужером, этот метод уже заботится о нужных нам методах, который требует протокол UITableViewDataSource(numberOfRowsInSection & cellForRowAt)
        
        // НО ЕСЛИ НАМ НУЖНО РЕАЛИЗОВАТЬ МЕТОД ПРОТОКОЛА, которого нет в Rx, то мы можем использовать Forward Delegate, RxSetDelegate, который позволяет нам выйти из Rx и реализовать метод протокола в обычной  форме
        
        // Реализовываем метод heightForRowAt, которого нет в Rx
        
        tableView?.rx.setDelegate(self).disposed(by: disposeBag)

        // необходимо связать элементы последовательности связать с tableView
        // внутри автоматически создается proxy-datasource
        // указываем фабрику для создания ячеек
        
//        food.bind(to: (tableView?.rx.items(cellIdentifier: "Cell"))!) { (row, foods, cell) in
//            cell.textLabel?.text = foods.name
//            cell.detailTextLabel?.text = foods.flickrID
//            cell.imageView?.image = foods.image
//        }.disposed(by: disposeBag)
        
        // обрабатываем события по нажатию
        // Rx modelSelected - это обертка над tableView.didselectRowAtIndexPath
        tableView?.rx.modelSelected(Food.self).subscribe(onNext: {
            print("You selected: \($0)")
            }).disposed(by: disposeBag)
    }


}

extension TableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("You selected foods at: \(food[indexPath.row])")
//    }
}
//
//extension TableViewController: UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return food.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else { return UITableViewCell() }
//
//        let foods = food[indexPath.row]
//
//        cell.textLabel?.text = foods.name
//        cell.detailTextLabel?.text = foods.flickrID
//        cell.imageView?.image = foods.image
//
//        return cell
//    }
//
//
//}
