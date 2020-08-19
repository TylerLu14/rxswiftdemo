//
//  ThrottleAndDebounce.swift
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

class ThrottleAndDebounceViewController: UIViewController {
    let session = Alamofire.Session(configuration: URLSessionConfiguration.default)
    
    let disposeBag = DisposeBag()
    
    lazy var btnThrottle: UIButton = {
        let button = UIButton()
        button.setTitle("Throttle", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var btnDebounce: UIButton = {
        let button = UIButton()
        button.setTitle("Debounce", for: .normal)
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
        
        title = "Throttle & Debounce"
        view.backgroundColor = .white
        
        let stack = UIStackView(arrangedSubviews: [btnThrottle, btnDebounce])
        stack.axis = .horizontal
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
        
        btnThrottle.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in self.append(text: "Tap") })
            .disposed(by: disposeBag)
        
        btnDebounce.rx.tap
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in self.append(text: "Tap") })
            .disposed(by: disposeBag)
        
        Observable<Int>.interval(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in self.append(text: "-")})
            .disposed(by: disposeBag)
    }
    
    func append(text: String) {
        txtView.text.append(contentsOf: text)
        
        if (txtView.contentOffset.y + txtView.frame.height) < txtView.contentSize.height {
            txtView.setContentOffset(CGPoint(x: 0, y: txtView.contentSize.height - txtView.frame.height), animated: true)
        }
    }
}
