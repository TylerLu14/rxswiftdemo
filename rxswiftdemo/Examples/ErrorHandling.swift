//
//  ErrorHandling.swift
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

class ErrorHandlingViewController: UIViewController {
    let session = Alamofire.Session(configuration: URLSessionConfiguration.default)
    
    let disposeBag = DisposeBag()
    
    lazy var btnNoErrorHandling: UIButton = {
        let button = UIButton()
        button.setTitle("No Error Handling", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        return button
    }()
    
    lazy var btnErrorHandling: UIButton = {
        let button = UIButton()
        button.setTitle("Error Handling", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        return button
    }()
    
    lazy var btnErrorOut: UIButton = {
        let button = UIButton()
        button.setTitle("Error Out: No", for: .normal)
        button.setTitle("Error Out: Yes", for: .selected)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        return button
    }()
    
    lazy var txtView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .darkGray
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return view
    }()
    
    override func loadView() {
        super.loadView()
        
        title = "Error Handling"
        view.backgroundColor = .white
        
        let stack = UIStackView(arrangedSubviews: [btnNoErrorHandling, btnErrorHandling, btnErrorOut])
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
        
        btnNoErrorHandling.rx.tap
            .flatMap{ _ in self.dummyHttpRequest() }
            .subscribe(onNext: { [txtView] html in
                txtView.text = html
            }, onError: { [txtView] error in
                txtView.text = error.localizedDescription
            })
            .disposed(by: disposeBag)
        
        btnErrorHandling.rx.tap
            .flatMap{ _ in self.dummyHttpRequestErrorHandling() }
            .subscribe(onNext: { [txtView] response in
                switch response {
                case .success(let html): txtView.text = html
                case .failure(let error): txtView.text = error.localizedDescription
                }
            }, onError: { [txtView] error in
                txtView.text = "Other Errors"
            })
            .disposed(by: disposeBag)
        
        btnErrorOut.rx.tap
            .subscribe(onNext: { [btnErrorOut] _ in btnErrorOut.isSelected = !btnErrorOut.isSelected })
            .disposed(by: disposeBag)
    }
    
    func append(text: String) {
        DispatchQueue.main.async { [txtView] in
            txtView.text.append(contentsOf: text)
            
            if (txtView.contentOffset.y + txtView.frame.height) < txtView.contentSize.height {
                txtView.setContentOffset(CGPoint(x: 0, y: txtView.contentSize.height - txtView.frame.height), animated: true)
            }
        }
    }
    
    func dummyHttpRequest() -> Observable<String> {
        if btnErrorOut.isSelected {
            return .error(AFError.explicitlyCancelled)
        }
        
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
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    
    func dummyHttpRequestErrorHandling() -> Observable<Result<String, AFError>> {
        let isErrorOut = btnErrorOut.isSelected
        
        return Observable<Result<String, AFError>>.create{ observer in
            let request = self.session.request(URL(string: "https://www.google.com")!, method: .get)
            request.responseString { response in
                if isErrorOut {
                    observer.onNext(Result.failure(AFError.explicitlyCancelled))
                } else {
                    observer.onNext(response.result)
                }
                observer.onCompleted()
            }
            
            return Disposables.create { request.cancel() }
        }
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }
}
