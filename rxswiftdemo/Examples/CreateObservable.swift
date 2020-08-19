//
//  CreateObservable.swift
//  rxswiftdemo
//
//  Created by Hoang Lu on 8/19/20.
//  Copyright © 2020 Hoang Lu. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Alamofire

class CreateObservableViewController: UIViewController {
    let session = Alamofire.Session(configuration: URLSessionConfiguration.default)
    
    let disposeBag = DisposeBag()
    
    lazy var btnCreate: UIButton = {
        let button = UIButton()
        button.setTitle("Observable.create()", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var btnDeferred: UIButton = {
        let button = UIButton()
        button.setTitle("Observable.deferred()", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var btnFrom: UIButton = {
        let button = UIButton()
        button.setTitle("Observable.from()", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var btnJust: UIButton = {
        let button = UIButton()
        button.setTitle("Observable.just()", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var btnEmpty: UIButton = {
        let button = UIButton()
        button.setTitle("Observable.empty()", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var btnNever: UIButton = {
        let button = UIButton()
        button.setTitle("Observable.never()", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var btnTimer: UIButton = {
        let button = UIButton()
        button.setTitle("Observable.timer()", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var btnInterval: UIButton = {
        let button = UIButton()
        button.setTitle("Observable.interval()", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var txtView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .darkGray
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return view
    }()
    
    override func loadView() {
        super.loadView()
        
        title = "Create Observables"
        
        view.backgroundColor = .white
        
        let stack = UIStackView(arrangedSubviews: [btnCreate, btnDeferred, btnJust, btnFrom, btnEmpty, btnNever, btnTimer, btnInterval])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        view.addSubview(stack)
        stack.snp.makeConstraints{ make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
        }
        
        view.addSubview(txtView)
        txtView.snp.makeConstraints{ make in
            make.top.equalTo(stack.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnCreate.rx.tap
            .flatMap{ _ in self.dummyHttpRequestCreate() }
            .bind(to: txtView.rx.text)
            .disposed(by: disposeBag)
        
        btnDeferred.rx.tap
            .flatMap{ [unowned self] _ in self.dummyHttpRequestDeferred() }
            .bind(to: txtView.rx.text)
            .disposed(by: disposeBag)
        
        btnJust.rx.tap
            .flatMap{ [unowned self] _ in self.dummyHttpRequestJust() }
            .bind(to: txtView.rx.text)
            .disposed(by: disposeBag)
        
        btnFrom.rx.tap
            .flatMap{ [unowned self] _ in self.dummyHttpRequestFrom() }
            .bind(to: txtView.rx.text)
            .disposed(by: disposeBag)
        
        btnEmpty.rx.tap
            .flatMap{ [unowned self] _ in self.dummyHttpRequestEmpty().debug() }
            .bind(to: txtView.rx.text)
            .disposed(by: disposeBag)
        
        btnNever.rx.tap
            .flatMap{ [unowned self] _ in self.dummyHttpRequestNever().debug() }
            .bind(to: txtView.rx.text)
            .disposed(by: disposeBag)
        
        btnTimer.rx.tap
            .flatMap{ [unowned self] _ in self.dummyHttpRequestTimer() }
            .bind(to: txtView.rx.text)
            .disposed(by: disposeBag)
        
        btnInterval.rx.tap
            .flatMap{ [unowned self] _ in self.dummyHttpRequestInterval() }
            .bind(to: txtView.rx.text)
            .disposed(by: disposeBag)
    }
    
    func dummyHttpRequestCreate() -> Observable<String> {
        return Observable<String>.create{ observer in
            let request = self.session.request(URL(string: "https://www.google.com")!, method: .get)
            request.responseString { response in
                switch response.result {
                case .success(let string): observer.onNext(string)
                case .failure(let error): observer.onError(error)
                }
                observer.onCompleted()
            }
            
            return Disposables.create { request.cancel() }
        }
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
    }
    
    func dummyHttpRequestDeferred() -> Observable<String> {
        return Observable<String>.deferred{
            let request = self.session.request(URL(string: "https://www.google.com")!)
            let semaphore = DispatchSemaphore(value: 0)
            var result: String = ""
            var error: Error? = nil
            request.responseString { response in
                switch response.result {
                case .success(let string): result = string
                case .failure(let err): error = err
                }
                semaphore.signal()
            }
            semaphore.wait()
            if let error = error {
                return Observable.error(error)
            } else {
                return Observable.just(result)
            }
        }
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
    }
    
    func dummyHttpRequestJust() -> Observable<String> {
        return .just("Just Something")
    }
    
    func dummyHttpRequestFrom() -> Observable<String> {
        let fromObs = Observable.from(["Lu", "Lu Duc", "Lu Duc Hoang", "Lu Duc Hoang Dep", "Lu Duc Hoang Dep Trai"])
            
        return Observable.zip(fromObs, Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).startWith(-1))
            .map{ string, _ in string }
    }
    
    func dummyHttpRequestEmpty() -> Observable<String> {
        return .empty()
    }
    
    func dummyHttpRequestNever() -> Observable<String> {
        return .never()
    }
    
    func dummyHttpRequestTimer() -> Observable<String> {
        Observable<Int>.timer(.seconds(3), scheduler: MainScheduler.instance)
            .flatMapLatest{ _ in self.dummyHttpRequestCreate() }
    }
    
    func dummyHttpRequestInterval() -> Observable<String> {
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .flatMapLatest{ _ in self.dummyHttpRequestCreate() }
            .take(3)
    }
}
