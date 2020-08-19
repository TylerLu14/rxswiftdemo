//
//  SubscribeOnAndObserveOn.swift
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

class SubscribeOnAndObserveOnViewController: UIViewController {
    let session = Alamofire.Session(configuration: URLSessionConfiguration.default)
    
    let disposeBag = DisposeBag()
    
    lazy var btnObserveOn: UIButton = {
        let button = UIButton()
        button.setTitle("ObserveOn", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        return button
    }()
    
    lazy var btnSubscribeOn: UIButton = {
        let button = UIButton()
        button.setTitle("SubscribeOn", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        return button
    }()
    
    lazy var btnMultipleSubscribeOn: UIButton = {
        let button = UIButton()
        button.setTitle("Multiple SubscribeOn", for: .normal)
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
        
        title = "SubscribeOn & ObserveOn"
        view.backgroundColor = .white
        
        let stack = UIStackView(arrangedSubviews: [btnObserveOn, btnSubscribeOn, btnMultipleSubscribeOn])
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
        
        btnObserveOn.rx.tap
            .subscribe(onNext: observeOn)
            .disposed(by: disposeBag)
        
        btnSubscribeOn.rx.tap
            .subscribe(onNext: subscribeOn)
            .disposed(by: disposeBag)
        
        btnMultipleSubscribeOn.rx.tap
            .subscribe(onNext: multipleSubscribeOn)
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
    
    func currentQueueName() -> String {
        let name = __dispatch_queue_get_label(nil)
        return String(cString: name, encoding: .utf8) ?? "Unknown"
    }
    
    func observeOn() {
        self.append(text: "-----observeOn-----\n")
        Observable.of(1)
            .map{ element -> Int in
                self.append(text: "Element \(element * 2) on \(self.currentQueueName())\n\n")
                return element * 2
            }
            .observeOn(SerialDispatchQueueScheduler(qos: .background))
            .map{ element -> Int in
                self.append(text: "Element \(element * 2) on \(self.currentQueueName())\n\n")
                return element * 2
            }
            .observeOn(MainScheduler.instance)
            .map{ element in element * 2}
            .subscribe(onNext: { element in
                self.append(text: "Subscribed\n")
                self.append(text: "Element \(element) on \(self.currentQueueName())\n\n")
            })
            .disposed(by: disposeBag)
    }
    
    func subscribeOn() {
        self.append(text: "-----subscribeOn-----\n")
        Observable.of(1)
            .map{ element -> Int in
                self.append(text: "Element \(element * 2) on \(self.currentQueueName())\n\n")
                return element * 2
            }
            .map{ element -> Int in
                self.append(text: "Element \(element * 2) on \(self.currentQueueName())\n\n")
                return element * 2
            }
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { element in
                self.append(text: "Subscribed\n")
                self.append(text: "Element \(element) on \(self.currentQueueName())\n\n")
            })
            .disposed(by: disposeBag)
    }
    
    func multipleSubscribeOn() {
        self.append(text: "-----Multiple subscribeOn-----\n")
        Observable.of(1)
            .map{ element -> Int in
                self.append(text: "Element \(element * 2) on \(self.currentQueueName())\n\n")
                return element * 2
            }
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .map{ element -> Int in
                self.append(text: "Element \(element * 2) on \(self.currentQueueName())\n\n")
                return element * 2
            }
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { element in
                self.append(text: "Subscribed\n")
                self.append(text: "Element \(element) on \(self.currentQueueName())\n\n")
            })
            .disposed(by: disposeBag)
    }
}
