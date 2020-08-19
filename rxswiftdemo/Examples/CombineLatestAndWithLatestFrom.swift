//
//  CombineLatestAndWithLatestFrom.swift
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

class CombineLatestAndWithLatestFromViewController: UIViewController {
    let session = Alamofire.Session(configuration: URLSessionConfiguration.default)
    
    let disposeBag = DisposeBag()
    
    lazy var txtId: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        return field
    }()
    
    lazy var txtPassword: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        return field
    }()
    
    lazy var btnCombineLatest: UIButton = {
        let button = UIButton()
        button.setTitle("CombineLatest", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        return button
    }()
    
    lazy var btnWithLatestFrom: UIButton = {
        let button = UIButton()
        button.setTitle("WithLatestFrom", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
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
        
        title = "CombineLatest & WithLatestFrom"
        view.backgroundColor = .white
        
        let stack = UIStackView(arrangedSubviews: [txtId, txtPassword, btnCombineLatest, btnWithLatestFrom])
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
        
        let credentials = Observable.combineLatest(txtId.rx.text, txtPassword.rx.text)
        
        let isLoginEnabled = credentials.map{ id, password -> Bool in
            guard let id = id, let password = password else { return false }
            
            let validId = !id.isEmpty && !id.contains{ $0.isNewline || $0.isWhitespace }
            let validPassword = password.count >= 6
            return validId && validPassword
        }
        
        isLoginEnabled.bind(to: btnCombineLatest.rx.isEnabled)
            .disposed(by: disposeBag)
        
        isLoginEnabled.bind(to: btnWithLatestFrom.rx.isEnabled)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(btnCombineLatest.rx.tap, credentials)
            .subscribe(onNext: { [unowned self] _, credentials in
                let (id, password) = credentials
                self.append(text: "Logged In CombineLatest\n")
                self.append(text: "Id: \(id ?? "") - Password: \(password ?? "")\n")
            })
            .disposed(by: disposeBag)
        
        btnWithLatestFrom.rx.tap.withLatestFrom(credentials)
            .subscribe(onNext: { [unowned self] credentials in
                let (id, password) = credentials
                self.append(text: "Logged In WithLatestFrom\n")
                self.append(text: "Id: \(id ?? "") - Password: \(password ?? "")\n")
            })
            .disposed(by: disposeBag)
    }
    
    func append(text: String) {
        txtView.text.append(contentsOf: text)
        
        if (txtView.contentOffset.y + txtView.frame.height) < txtView.contentSize.height {
            txtView.setContentOffset(CGPoint(x: 0, y: txtView.contentSize.height - txtView.frame.height), animated: true)
        }
    }
}
