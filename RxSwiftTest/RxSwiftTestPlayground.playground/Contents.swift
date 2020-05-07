import RxSwift
import UIKit
import PlaygroundSupport

// Reactive Extension (Rx) - набор библиотек которые позволяют работать с событиями и асинхронными вызовами, все это организовано на паттерне Observer

// Суть всего Rx это асинхронные операции. Весь наш интерфейс построен на асинхронности. Мы не можем заставить пользователя ждать, он должен нажать кнопку - чтото там делать в телефоне, а мы должны выполнять работу в бэкграунде

// При работе с асинхронными операциями возникают такие проблемы: сложная обработка ошибок, много явных и неявных состояний, которые появляются из-за ошибок, трудности в рефакторинге и поддержке, утечки памяти.

PlaygroundPage.current.needsIndefiniteExecution = true
var str = "Hello, playground"

example("Test") {
    // Observables - это объект который мы наблюдаем, он представлен как поток данных
    
    // ---> RxMarbles <---
     
    // шкала времени
    
    // -1---2---3--|-> здесь используется Int-данные, на этой шкале времени Observable завершился с успехом, это обозначается |
    
    // шкала времени
    
    // ---d---ff--f-x-> здес используются String-данные, на этой шкале времени Observable упал с ошибкой, это обозначается x
    
    // ---> КАК СОЗДАЮТСЯ OBSERVABLE <---
    
    // Observable могут быть COLD и HOT
    
    // Мы будем использовать тут COLD-Observable - они будут выполняться тогда, когда наблюдатель(observer) подпишется на него
    // А HOT-Observable - будет выполняться даже тогда, когда на него ниодин observer не подписан
    
    let intObservable = Observable.just(30)
    let stringObservable = Observable.just("Hello")
    
    // ---> OBSERVER <---
    
    // 1-ый вариант. Observer может подписаться subscription на эти данные и со временем начать отписываться(например когда пользователь перешел на другую страницу)
    
    // 2-ой вариант. Мы привязываем поток данных(binding, байндим) к чему-то с чем он может взаимодействовать
    
}

example("just") {
    // OBSERVABLE
    
    let observable = Observable.just("Hello, RxSwift")
    
    // OBSERVER
    // подписываемся на observable
    
    observable.subscribe { (event) in
        print(event)
    }
}

example("of") {
    // оператор of создает последовательность из переменных
    let observable = Observable.of(1, 2, 3, 4, 5)
    
    observable.subscribe { (event) in
        // читаем последовательность из элементов
        print(event)
    }
    
    // короткая запись
    observable.subscribe {
        print($0)
    }
}

example("create") {
    // оператор create позволяет создавать observable с нуля, полностью контролируя какие элементы когда он будет генерировать
    let items = [1, 2, 3, 4, 5]
    Observable.from(items).subscribe(onNext: { (event) in
        print(event)
    }, onError: { (error) in
        print(error)
    }, onCompleted: {
        print("OK")
    }) {
        print("Disposed")
    }
}

// Каждый observer должен возвращать Disposable

example("Disposable") {
    let sequence = [1, 2, 3]
    Observable.from(sequence).subscribe { (event) in
        print(event)
    }
    // После того как подписчик был создан, надо его освободить
    // этот метод вызывается тогда, когда мы хотим прервать работу нашего подписчика
    Disposables.create()
}

example("dispose") {
    let sequence = [1, 2, 3]
    let subscription = Observable.from(sequence)
    subscription.subscribe { (event) in
        print(event)
        // чтобы прервать вызываем метод dispose
    }.dispose()
}
// Есть 2 пути чтобы корректно освободить ресурсы: использовать disposeBag и оператор takeUntil

example("disposeBag") {
    let disposeBag = DisposeBag()
    let sequence = [1, 2, 3]
    let observable = Observable.from(sequence)
    observable.subscribe { (event) in
        print(event)
    }.disposed(by: disposeBag)
}

// Если время подписки совпадает с временем жизни объекта то можно освободить ресурсы с помощью опаратора takeUntil

example("takeUntil ") {
    
    let sequence = [1, 2, 3]
    let stopSequence = Observable.just(1).delaySubscription(2, scheduler: MainScheduler.instance)
    let observable = Observable.from(sequence).takeUntil(stopSequence)
    observable.subscribe { (event) in
        print(event)
    }
}

// ---> Operators <---

// Это просто операции, которые выполняются между наблюдателем и наблюдаемым

// ---> FILTERING OPERATORS <---

// filter - просто смотрит поток данных и фильтрует все элементы которые больше 10 и создает их на второй шкале времени

example("filter") {
    let sequence = [1, 2, 5, 22, 30, 60]
    let observable = Observable.from(sequence).filter{ $0 > 10 }
    observable.subscribe { (event) in
        print(event)
    }
}

// ---> TRANSFORMATION OPERATORS <---

// Трансформирующие операторы по сути из одного observable делают другой observable

// map - умножаем элементы на 10

example("map") {
    let sequence = [1, 2, 3]
    let observable = Observable.from(sequence).map { $0 * 10 }
    observable.subscribe { (event) in
        print(event)
    }
}

// ---> COMBINE OPERATORS <---

// комбинируем 2 потока данных

// merge делаем слияние двух потоков данных

example("merge") {
    let disposeBag = DisposeBag()

    let oldXmenMovies = PublishSubject<String>()
    let newXmenMovies = PublishSubject<String>()
    
    let xmenMovies = Observable.of(oldXmenMovies, newXmenMovies)

    xmenMovies.merge()
      .subscribe(onNext: { movie in
        print(movie)
      })
      .disposed(by: disposeBag)

    oldXmenMovies.onNext("X-Men")
    oldXmenMovies.onNext("X-Men United")
    newXmenMovies.onNext("First Class")
    oldXmenMovies.onNext("The Last Stand")
    newXmenMovies.onNext("Days of Future Past")
}

//             --------------------> SUBJECT <--------------------

// Subject - являются расширением Observable, и одновременно реализуют интерфейс Observer'a. Subject'ы могут принимать сообщения о событиях как observer и сообщать о них своим подписчикам как listener. Когда у нас есть данные поступающие извне - вы можете передать их в subject, превращая их таким образом в Observable. Существует несколько реализация Subject

//                           ---> Publish Subject <---

// Самая простая реализация Subject. Когда данные передаются в PublishSubject - он выдает их всем подписчикам, которые подписаны на него в данный момент

example("PublishSubject") {
    let disposeBag = DisposeBag()
    
    let subject = PublishSubject<String>()
    
    // создаем 1ого observer'a
    subject.subscribe {
        print("First subscriber:", $0)
    }.disposed(by: disposeBag)
    
    // начинаем эмитить элементы, первый
    subject.on(Event<String>.next("Hello"))
    
    // ---> ОСОБЕННОСТЬ <---
    // Одной из важных особенностей PublisherSubject'a является невозможность выдать события, после того как последовательность завершена(onComleted) или получена ошибка(error)
    
    enum RxSwiftError: Error {
        case forceError
    }
    
//    subject.onCompleted()
//    subject.onError(RxSwiftError.forceError)
    
    // второй
    subject.onNext("RxSwift")
    
    // создаем 2ого observer'a
    // при создании нового обсервера мы получаем события только те, которые приходят после того как подписка стартовала
    subject.subscribe(onNext: {
        print("Second subscriber:", $0)
        }).disposed(by: disposeBag)
    
    subject.onNext("Hi")
    subject.onNext("Sereja")
}

//                           ---> Behavior Subject <---

// Behavior Subject - хранит только последнее значение. Хранит все в буфере, размером 1. Во время создания, ему может быть присвоено начальное значение, таким образом гарантируя, что данные будут доступны новым подписчикам. Роль Behavior Subject заключается в том, что ему нужно иметь доступные данные

example("BehaviorSubject") {
    let disposeBag = DisposeBag()
    let subject = BehaviorSubject(value: 1) // [1] - в буфере находится единица, она доступна еще до того, как появился подписчик
    
    let firstSubscription = subject.subscribe(onNext: {
        print(#line, $0)
        }).disposed(by: disposeBag)
    
    // эмитим элементы
    subject.onNext(2) //[1,2]
    subject.onNext(3) //[1,2,3]
    
    let secondSubscription = subject.subscribe(onNext: {
        print(#line, $0) // [3]
        }).disposed(by: disposeBag)
    
    // при создании нового обсервера мы получаем события только те, которые приходят после того как подписка стартовала и последний элемент из буфера
}

//                           ---> Replay Subject <---

// Replay Subject - имеет возможность кэшировать все поступившие в него данные. То есть когда у него появляется новый подписчик, последовательность, выданная ему начинается сначала

example("ReplaySubject: v.1") {
    let disposeBag = DisposeBag()
    
    // Subject будет принимать одно предыдущее значение после подписки(если размер буфера 1)
    let subject = ReplaySubject<Int>.create(bufferSize: 1) // создаем с размером буфера 1
    
    subject.subscribe { (event) in
        print("First observer", event)
    }.disposed(by: disposeBag)
    
    subject.onNext(1) // [1]
    subject.onNext(2) // [1,2]
    
    subject.subscribe { (event) in
        print("Second observer", event)
    }.disposed(by: disposeBag)
    
    subject.onNext(3)
    subject.onNext(4)
    
//    First observer next(1)
//    First observer next(2)
//    Second observer next(2)
//    First observer next(3)
//    Second observer next(3)
//    First observer next(4)
//    Second observer next(4)
    
    // До того как получить следующее значение, observer получает все пропущенные, то есть порядок последовательностей подписчика не нарушен
    
}

example("ReplaySubject: v.2") {
    let disposeBag = DisposeBag()
    
    let subject = ReplaySubject<Int>.create(bufferSize: 3)
    
    subject.onNext(10)
    subject.onNext(20)
    subject.onNext(30)
    subject.onNext(40)
    
    subject.subscribe(onNext: {
        print($0)
        }).disposed(by: disposeBag)
    
    // получаем 3 последних события
    
//    20
//    30
//    40
}

//                           ---> Variables Subject <---

// Variables - базируется на слое Behavior Subject(обертка над BehaviorSubject) . Variables - представляют некоторое наблюдаемое состояние. Variables - не может не содержать какое-то значение, она всегда должна быть проинициализирована.


example("Variables") {
    let disposeBag = DisposeBag()
    
    let variable = Variable("A")
    
    variable.asObservable().subscribe(onNext: {
        print($0)
        }).disposed(by: disposeBag)
    
    // Variable - предоставляет нам value-interface. Variables никогда не может прекратить свою работу, а будет транслировать свое текущее состояние, после того как мы подпишемся
    
    // задаем состояние
    variable.value = "B"
    
    // транслируем
//    A
//    B
}

//             --------------------> SIDE EFFECT <--------------------

// Side effect - это когда наш поток вычислений зависит от окружающей его среды и меняет ее.
// Side effect - применяется при логировании юзера, или показе UIActivityIndicator во время подгрузки данных с интернета

// -----1-----2-----3----|---> Source Observable
//      |     |     |
// doOn{_ in action() } - Operator
//      |     |     |
// -----1-----2-----3----|---> Result Observable
// doOnNext
// doOnError
// doOnComplete

// У нас есть Result Observable, который полностью дублирует Source Observable, но между ними мы встраиваем какой-то перехватчик событий ( doOn{_ in action() } - Operator ). Мы вклиниваемся между выполнением последовательностей Observable и совершаем некоторые действия. Совершаем действия с помощью оператора doOn{} для реализации Side Effect'a

example("SideEffect") {
    
    let disposeBag = DisposeBag()
    let sequence = [0, 32, 100, 300]
    
    let tempSequence = Observable.from(sequence)
    
    tempSequence.do(onNext: {
        print("\($0)F = ", terminator: " ")
    }).map({
        Double($0 - 32) * 5/9.0
    }).subscribe(onNext: {
        print(String(format: "%.1f", $0))
        }).disposed(by: disposeBag)
    
//    0F =  -17.8
//    32F =  0.0
//    100F =  37.8
//    300F =  148.9
}

//             --------------------> SCHEDULERS (планировщики) <--------------------

// Основная проблема, что берет на себя Rx - это управление потоками. Например загрузить что-то из сети и показать это. Наш девайс не даст выполнять нам это в главном потоке(UI-Thread). Обычно Observable и операторы будут работать и отправлять уведомления в том же потоке, на который подписан наблюдатель. Поэтому мы можем на каждый оператор который у нас есть, указывать ему на каком потоке что-то выполнять(либо это UI-Thread(main), либо это поток вычислений). Поэтому нам на помощь приходит абстрактный механизм для выполнения работы который называется SCHEDULER

// Обычно у наблюдателя задачи такие: получать данные и отобразить эти данные. Мы можем сказать один раз ГДЕ НАБЛЮДАТЬ(observeOn) и на каждую операцию сказать ГДЕ ЕЕ ВЫПОЛНЯТЬ(subscribeOn). Всё это можно чередовать, добиваясь работы с многопоточностью и быстродействия

// Наиболее связанные операторы, связанные с schedulers(планировщиками) - observeOn и subscribeOn

// observeOn - указывает на каком потоке нужно наблюдать за данными. Самый распространенный scheduler оператор

// subscribeOn - указывает на каком потоке нужно выполнить начало подписки, может менять поток или очередь на котором scheduler будет выполнять работу

example("without observeOn") {
    let _ = Observable.of(1, 2, 3).subscribe(onNext: { (event) in
        print("\(Thread.current): ", event)
    }, onError: { (error) in
        print(error)
    }, onCompleted: {
        print("Completed")
    }, onDisposed: nil)
    
    // Всё выполнилось в главном потоке
    
//    <NSThread: 0x600001fc29c0>{number = 1, name = main}:  1
//    <NSThread: 0x600001fc29c0>{number = 1, name = main}:  2
//    <NSThread: 0x600001fc29c0>{number = 1, name = main}:  3
//    Completed
    
}

example("observeOn") {
    let _ = Observable.of(1, 2, 3)
        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { (event) in
            print("\(Thread.current): ", event)
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            print("Completed")
        }, onDisposed: nil)
    
    // Применяя многопоточность, выводим всё в 5 и 4 потоках
    
//    <NSThread: 0x60000394b8c0>{number = 5, name = (null)}:  1
//    <NSThread: 0x60000394b8c0>{number = 5, name = (null)}:  2
//    <NSThread: 0x600003965140>{number = 4, name = (null)}:  3
//    Completed
}

example("subscribeOn + observeOn") {
    let queue1 = DispatchQueue.global(qos: .default)
    let queue2 = DispatchQueue.global(qos: .default)
    
    // Изначально мы инициализируемся на потоке 1
    print("Init in thread : \(Thread.current)")
    
    let _ = Observable<Int>.create { (observer) -> Disposable in
        
        // код отсюда выполняется уже в другом потоке
        // за счет оператора observeOn мы переносим действия на другой поток (queue2 - 7ой поток), если бы мы не применяли observeOn, то действия выполнялись на другом потоке за счет оператора subscribeOn (queue1 - 5ый поток)
        observer.on(.next(10))
        observer.on(.next(20))
        observer.on(.next(30))
        
        print("Observable thread: \(Thread.current)")
        return Disposables.create()
        }.subscribeOn(SerialDispatchQueueScheduler(internalSerialQueueName: "queue1")).observeOn(SerialDispatchQueueScheduler(internalSerialQueueName: "queue2"))
    .subscribe(onNext: { (event) in
        print("Observable thread: \(Thread.current)", event )
    }, onError: { (error) in
        print(error)
    }, onCompleted: {
        print("Completed")
    }, onDisposed: nil)
}

//                           ---> Units <---

// Юниты это часть библиотеки RxCocoa. Это по сути структура, которая оборачивает наблюдаемую последовательность. Чтобы получить доступ к юнит, наблюдаемой последовательности нужно вызвать метод asObservable().

// Юниты являются полностью опциональными и предоставляют ряд удобных характеристик: работа в основном потоке и то что не будет сгенерировано никаких ошибок. Эти характеристики делают Юниты особенно полезными при работе с UI-элементами(например отобразить самое последнее изменение UILabel и при этом не будет никаких ошибок)

// Существует несколько типов Юнитов:

//                         ---> Driver Unit <---

// Драйвер-юнит - его цель состоит в том чтобы обеспечить интуитивно понятный способ написать реактивный UI-код. Предполагаемый вариант его использования был в моделировании последовательности для управления приложением. То есть например управлять UI-элементами, используя значения других UI-элементов. В случае если есть какие-то ошибки в последовательности, то наше приложение перестанет отвечать на ввод новых данных юзера. Также очень важно что эти элементы наблюдаются в основном потоке, потому что UI-элементы и бизнес-логика непотокобезоспасны.

//                         ---> UIBindingObserver Unit <---

// UIBindingObserver — generic класс помощник, позволяющий создавать привязку переданного в замыкание параметра (в нашем случае location) к изменениям свойства/свойств переданного объекта (в нашем случае свойство text). UIBindingObserver параметризуется классом объекта (в нашем случае UILabel, т.к. extension UILabel), в замыкание в качестве параметров будут передаваться как сам объект (label) так и значение с помощью которого мы будем менять состояние объекта (location)

//                         ---> ControlEvent Unit <---

// Чтобы в Rx окружении обрабатывать target-event паттерн ввели структуру ControlEvent<>
// Она обладает следующими свойствами:
// — ее код никогда не упадет
// — при подписке не будет отправляться никакого изначального значения
// — при освобождении памяти контролом будет сгенерировано .Completed
// — наружу никогда не выйдет никаких ошибок
// — все события будут выполняться на MainScheduler

// Так же мы можем в любой момент при необходимости получить из ControlEvent — Observable с помощью .asObservable() или Driver с помощью .asDriver()

//                         ---> ControlProperty Unit <---

// Чтобы сделать двустороннюю привязку к свойствам UI элемента на помощь приходит структура ControlProperty<> обладающая следующими свойствами

// — её код никогда не упадет
// — на последовательности элементов применен shareReplay(1)
// — при осовобождении контролом памяти будет сгенерировано .Completed
// — наружу никогда не выйдет никаких ошибок
// — все события будут выполняться на MainScheduler

//                         ---> DelegateProxy Unit <---

//  краеугольный камень архитектуры Cocoa — делегаты. Но обычно предполагается — один делегат на один объект, поэтому в Rx добавили класс DelegateProxy, который позволяет одновременно использовать как обычный делегат, так и Rx последовательности.

// С точки зрения пользователя существующего API ничего вроде особо сложного и нет.
// Возьмем к примеру UISearchBar, мы хотим как то реагировать на нажатие кнопки Cancel. Для нас в расширении для класса UISearchBar создана переменная
