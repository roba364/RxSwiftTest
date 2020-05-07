//
//  ViewController.swift
//  RxSwiftTest
//
//  Created by SofiaBuslavskaya on 24/04/2020.
//  Copyright © 2020 Sergey Borovkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    //TapGestureRecognizer
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    
    //Button and Label
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var buttonLabel: UILabel!
    
    //Slider and ProgressView
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var progressView: UIProgressView!
    
    //SegmentedControl and Label
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedControlLabel: UILabel!
    
    //DatePicker and Label
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerLabel: UILabel!
    
    //TextField and Label
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFieldLabel: UILabel!
    
    //TextView and Label
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewLabel: UILabel!
    
    //Switch and ActivityIndicator
    @IBOutlet weak var mySwitch: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Stepper and Label
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var stepperLabel: UILabel!
    
    
    //DisposeBag - в этом примере он объявлен как свойство. Это нужно, чтобы во время вызова системой deinit, происходило освобождение ресурсов для Observable-объектов.
    
    let disposeBag = DisposeBag()
    
    //DateFormatt for DatePicker
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    let textfieldText = BehaviorSubject<String>(value: "")
    let buttonSubject = PublishSubject<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // берем наш объект, привязываемся к нашей переменной
        textField.rx.text
            .orEmpty
            .bind(to: textfieldText)
            .disposed(by: disposeBag)
        
        // преобразовываем это в asObservable и подписываемся
        textfieldText.asObservable()
            .subscribe {
                print($0)
        }.disposed(by: disposeBag)
        
        // по нажатию на кнопку выводим в консоль "Hello"
        button.rx.tap.map({ "Hello" })
            .bind(to: buttonSubject)
            .disposed(by: disposeBag)
        
        buttonSubject.asObservable()
                .subscribe {
                print($0)
        }.disposed(by: disposeBag)
        
        // объект textField привязали к textFieldLabel
        // теперь когда мы набираем текст в textField = текст передается в textFieldLabel
        textField.rx.text.bind(onNext: {
            self.textFieldLabel.rx.text.onNext($0)
            }).disposed(by: disposeBag)
        
        // когда мы нажимаем вне UI-элемента - будем прекращать редактировать и убирать клваиатуру
        
        tapGestureRecognizer.rx.event.asDriver().drive(onNext: { [weak self] _ in
            self?.view.endEditing(true)
            }).disposed(by: disposeBag)
        
        // Считаем поличество символов в textView
        
        textView.rx.text.bind(onNext: { (event) in
            self.textFieldLabel.text = "Character count: \(String(describing: event?.count))"
            }).disposed(by: disposeBag)
        
        // Меняем + добавляем buttonLabel по нажатию на button
        
        button.rx.tap.asDriver().drive(onNext: {
            self.buttonLabel.text! += "Hello, RxSwift"
            self.view.endEditing(true)
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            }).disposed(by: disposeBag)
        
       // двигаем слайдер и меняем progressView
        slider.rx.value.asDriver()
            .drive(progressView.rx.progress)
            .disposed(by: disposeBag)
        
        // Показываем в segmentedControlLabel индекс элемента который выбран
        // оператор skip() начинает отслеживать изменения после того, значения, которое мы зададим
        
        segmentedControl.rx.value.asDriver().skip(5).drive(onNext: {
            self.segmentedControlLabel.text! = "Selected element: \($0)"
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            }).disposed(by: disposeBag)
        
        // передаем выбранную дату в datePickerLabel
        
        datePicker.rx.date.asDriver()
        .map({
            // здесь необходимо дату перевести в строку, куда мы передаем наш элемент
            self.dateFormatter.string(from: $0)
        }).drive(onNext: { (event) in
            self.datePickerLabel.text = "Selected date: \(event)"
            }).disposed(by: disposeBag)
        
        // устанавливаем число кликов по stepper в stepperLabel
        
        stepper.rx.value.asDriver()
        .map({
            String(Int($0))
        }).drive(stepperLabel.rx.text)
        .disposed(by: disposeBag)
        
        // по смене значения mySwitch показываем activityIndicator или скрываем isHidden
        
        mySwitch.rx.value.asDriver().map({
            !$0
        }).drive(activityIndicator.rx.isHidden)
            .disposed(by: disposeBag)
        
        // по смене значения mySwitch начинаем анимировать activityIndicator или останавливаем
        mySwitch.rx.value.asDriver()
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }
    
    

}

