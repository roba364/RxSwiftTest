//
//  CollectionViewController.swift
//  RxSwiftTest
//
//  Created by SofiaBuslavskaya on 29/04/2020.
//  Copyright © 2020 Sergey Borovkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

extension String {
    public typealias Identity = String
    
    var identity: Identity {
        return self
    }
}

struct AnimatedSectionModel {
    let title: String
    var data: [String]
}

extension AnimatedSectionModel: AnimatableSectionModelType {
    typealias Item = String
    
    typealias Identity = String
    
    var identity: String {
        return title
    }
    
    var items: [String] {
        return data
    }
    
    init(original: AnimatedSectionModel, items: [String]) {
        self = original
        data = items
    }
}

class CollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var longPressGR: UILongPressGestureRecognizer!
    
    let disposeBag = DisposeBag()
    
    // cell for row at
    
    let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatedSectionModel>(configureCell: {_, collectionView, indexPath, title in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        cell.titleLabel.text = title
        return cell
    }, configureSupplementaryView: {dataSource, collectionView, kind, indexPath in
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! CollectionReusableView
        header.titleLabel.text = "Section: \(indexPath.section)"
        return header
    }, canMoveItemAtIndexPath: { _, _ in true })
    
    let data = BehaviorRelay<[AnimatedSectionModel]>(value: [AnimatedSectionModel(title: "Section: 0", data: ["0-0"])])
    
    override func viewDidLoad() {
        super.viewDidLoad()

       dataSource.configureSupplementaryView = { (dataSource, collectionView, kind, indexPath) in
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! CollectionReusableView
        
        // надо подписаться на передачу данных, чтобы следить
        data.asDriver().drive(collectionView.rx.items(dataSource: dataSource!)).disposed(by: disposeBag)
        
        
            
            header.titleLabel.text = "Section: \(self.data.value.count)"
            return header
        }
        
        // по тапу на addBarButtonItem(+) создаем рандомное количество ячеек
        
        addBarButtonItem.rx.tap.asDriver().drive(onNext: {
            let section = self.data.value.count
            let items: [String] = {
                var items = [String]()
                let random = Int(arc4random())
                (0...random).forEach({
                    items.append("\(section) - \($0)")
                })
                return items
            }()
            
            self.data.value += [AnimatedSectionModel(title: "Section: \(section)", data: items)]
            }).disposed(by: disposeBag)
        
        longPressGR.rx.event.subscribe(onNext: { (event) in
            // проходимся по состояниям
            switch event.state {
            case .began:
                // находим положение сильно нажатой клетки
                guard let selectedIndex = self.collectionView.indexPathForItem(at: event.location(in: self.collectionView)) else { break }
                // добавляем анимации движения
                self.collectionView.beginInteractiveMovementForItem(at: selectedIndex)
            case .changed: self.collectionView.updateInteractiveMovementTargetPosition(event.location(in: event.view!))
            case .ended:
                self.collectionView.endInteractiveMovement()
            case default:
                self.collectionView.cancelInteractiveMovement()
            }
        })
    }
 
}
