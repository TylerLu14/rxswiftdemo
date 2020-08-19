//
//  MultipleSubscribers.swift
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

class MultipleSubscribersViewController: UIViewController {
    let session = Alamofire.Session(configuration: URLSessionConfiguration.default)
    
    let disposeBag = DisposeBag()
    
    lazy var btnNoShare: UIButton = {
        let button = UIButton()
        button.setTitle("Request Without Share", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var btnShare: UIButton = {
        let button = UIButton()
        button.setTitle("Request With Share", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    lazy var txtView1: UITextView = {
        let view = UITextView()
        view.backgroundColor = .darkGray
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return view
    }()
    
    lazy var txtView2: UITextView = {
        let view = UITextView()
        view.backgroundColor = .darkGray
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return view
    }()
    
    lazy var txtView3: UITextView = {
        let view = UITextView()
        view.backgroundColor = .darkGray
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return view
    }()
    
    override func loadView() {
        super.loadView()
        
        title = "Multiple Subscribers"
        
        view.backgroundColor = .white
        
        let stack = UIStackView(arrangedSubviews: [btnNoShare, btnShare])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        view.addSubview(stack)
        stack.snp.makeConstraints{ make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
        }
        
        let stack2 = UIStackView(arrangedSubviews: [txtView1, txtView2, txtView3])
        stack2.axis = .horizontal
        stack2.distribution = .fillEqually
        stack2.alignment = .fill
        view.addSubview(stack2)
        stack2.snp.makeConstraints{ make in
            make.top.equalTo(stack.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let observable1 = btnNoShare.rx.tap
            .flatMap{ _ in self.dummyHttpRequestCreate() }
        
        observable1.bind(to: txtView1.rx.text)
            .disposed(by: disposeBag)
        
        observable1.bind(to: txtView2.rx.text)
            .disposed(by: disposeBag)
        
        observable1.bind(to: txtView3.rx.text)
            .disposed(by: disposeBag)
        
        let observable2 = btnShare.rx.tap
            .flatMap{ _ in self.dummyHttpRequestCreate() }
            .share()
        
        observable2.bind(to: txtView1.rx.text)
            .disposed(by: disposeBag)
        
        observable2.bind(to: txtView2.rx.text)
            .disposed(by: disposeBag)
        
        observable2.bind(to: txtView3.rx.text)
            .disposed(by: disposeBag)
    }
    
    func dummyHttpRequestCreate() -> Observable<String> {
        return Observable<String>.create{ observer in
            let request = self.session.request(URL(string: "https://www.google.com")!, method: .get)
            request.responseString { response in
                print("Network Request")
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
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
}
