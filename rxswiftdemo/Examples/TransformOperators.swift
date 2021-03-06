//
//  TransformOperators.swift
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

class TransformOperatorsViewController: UIViewController {
    let session = Alamofire.Session(configuration: URLSessionConfiguration.default)
    
    let disposeBag = DisposeBag()
    
    lazy var btnMap: UIButton = {
        let button = UIButton()
        button.setTitle("map", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var btnFlatMap: UIButton = {
        let button = UIButton()
        button.setTitle("flatMap", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var btnFlatMapLatest: UIButton = {
        let button = UIButton()
        button.setTitle("flatMapLatest", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var btnConcatMap: UIButton = {
        let button = UIButton()
        button.setTitle("concatMap", for: .normal)
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
        
        title = "Transform Operators"
        view.backgroundColor = .white
        
        let stack = UIStackView(arrangedSubviews: [btnMap, btnFlatMap, btnFlatMapLatest, btnConcatMap])
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
        
        btnMap.rx.tap
            .do(onNext: { [unowned self] _ in self.append(text: "-----map-----") })
            .flatMap{ [unowned self] _ in self.map() }
            .subscribe(onNext: { [unowned self] text in self.append(text: text) })
            .disposed(by: disposeBag)
        
        btnFlatMap.rx.tap
            .do(onNext: { [unowned self] _ in self.append(text: "-----flatMap-----") })
            .flatMap{ [unowned self] _ in self.flatMap() }
            .subscribe(onNext: { [unowned self] text in self.append(text: text) })
            .disposed(by: disposeBag)
        
        btnFlatMapLatest.rx.tap
            .do(onNext: { [unowned self] _ in self.append(text: "-----flatMapLatest-----") })
            .flatMap{ [unowned self] _ in self.flatMapLatest() }
            .subscribe(onNext: { [unowned self] text in self.append(text: text) })
            .disposed(by: disposeBag)
        
        btnConcatMap.rx.tap
            .do(onNext: { [unowned self] _ in self.append(text: "-----concatMap-----") })
            .flatMap{ [unowned self] _ in self.concatMap() }
            .subscribe(onNext: { [unowned self] text in self.append(text: text) })
            .disposed(by: disposeBag)
    }
    
    func append(text: String) {
        let start = txtView.text.isEmpty ? "" : "\n"
        txtView.text.append(contentsOf: start + text)
        
        if (txtView.contentOffset.y + txtView.frame.height) < txtView.contentSize.height {
            txtView.setContentOffset(CGPoint(x: 0, y: txtView.contentSize.height - txtView.frame.height), animated: true)
        }
    }
    
    func map() -> Observable<String> {
        let source = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .take(3)
        return source.map { String("\($0) -> \($0*$0)") }
    }
    
    func flatMap() -> Observable<String> {
        let outerObservable = Observable<NSInteger>
            .interval(.milliseconds(500), scheduler: MainScheduler.instance)
            .take(2)

        let combinedObservable = outerObservable.flatMap { value in
            return Observable<Int>
                .interval(.milliseconds(300), scheduler: MainScheduler.instance)
                .take(3)
                .map { innerValue in "Outer Value \(value) Inner Value \(innerValue)" }
        }
        
        return combinedObservable
    }
    
    func flatMapLatest() -> Observable<String> {
        let outerObservable = Observable<NSInteger>
            .interval(.milliseconds(500), scheduler: MainScheduler.instance)
            .take(2)

          let combinedObservable = outerObservable.flatMapLatest { value in
              return Observable<NSInteger>
                  .interval(.milliseconds(300), scheduler: MainScheduler.instance)
                  .take(3)
                  .map { innerValue in "Outer Value \(value) Inner Value \(innerValue)" }
          }

          return combinedObservable
    }
    
    func concatMap() -> Observable<String> {
        let outerObservable = Observable<NSInteger>
            .interval(.milliseconds(500), scheduler: MainScheduler.instance)
            .take(2)

        let combinedObservable = outerObservable.concatMap { value in
            return Observable<NSInteger>
                .interval(.milliseconds(300), scheduler: MainScheduler.instance)
                .take(3)
                .map { innerValue in "Outer Value \(value) Inner Value \(innerValue)" }
        }

        return combinedObservable
    }
}
