//
//  ExampleCell.swift
//  rxswiftdemo
//
//  Created by Hoang Lu on 8/19/20.
//  Copyright © 2020 Hoang Lu. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol ExampleRow {
    var text: String { get }
    var icon: UIImage { get }
    var vc: UIViewController { get }
}

enum ExampleType: CaseIterable {
    case createObservables
    case transformOperators
    case throttleAndDebounce
    case combineLatestAndWithLatestFrom
    case subscribeOnAndObserveOn
    case errorHandling
    case multipleSubscribers
    
    var row: ExampleRow {
        switch self {
        case .createObservables: return CreateObservables()
        case .transformOperators: return TransformOperators()
        case .throttleAndDebounce: return ThrottleAndDebounce()
        case .combineLatestAndWithLatestFrom: return CombineLatestAndWithLatestFrom()
        case .subscribeOnAndObserveOn: return SubscribeOnAndObserveOn()
        case .errorHandling: return ErrorHandling()
        case .multipleSubscribers: return MultipleSubscribers()
        }
    }
    
    struct CreateObservables: ExampleRow {
        var text = "Create Observables"
        var icon: UIImage = #imageLiteral(resourceName: "ic_1")
        var vc: UIViewController = CreateObservableViewController()
    }
    
    struct TransformOperators: ExampleRow {
        var text = "Transform Operators"
        var icon: UIImage = #imageLiteral(resourceName: "ic_2")
        var vc: UIViewController = TransformOperatorsViewController()
    }
    
    struct ThrottleAndDebounce: ExampleRow {
        var text = "Throttle And Debounce"
        var icon: UIImage = #imageLiteral(resourceName: "ic_3")
        var vc: UIViewController = ThrottleAndDebounceViewController()
    }
    
    struct CombineLatestAndWithLatestFrom: ExampleRow {
        var text = "CombineLatest And WithLatestFrom"
        var icon: UIImage = #imageLiteral(resourceName: "ic_4")
        var vc: UIViewController = CombineLatestAndWithLatestFromViewController()
    }
    
    struct SubscribeOnAndObserveOn: ExampleRow {
        var text = "SubscribeOn And ObserveOn"
        var icon: UIImage = #imageLiteral(resourceName: "ic_5")
        var vc: UIViewController = SubscribeOnAndObserveOnViewController()
    }
    
    struct ErrorHandling: ExampleRow {
        var text = "Error Handling"
        var icon: UIImage = #imageLiteral(resourceName: "ic_6")
        var vc: UIViewController = ErrorHandlingViewController()
    }
    
    struct MultipleSubscribers: ExampleRow {
        var text = "Multiple Subscribers"
        var icon: UIImage = #imageLiteral(resourceName: "ic_7")
        var vc: UIViewController = MultipleSubscribersViewController()
    }
    
}

class ExampleCell: UITableViewCell {
    static let identifier: String = "ExampleCell"
    
    var disposeBag = DisposeBag()
    
    lazy var imgLogo: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var lblText: UILabel = {
        let label = UILabel()
        return label
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    func initialize() {
        let stackView = UIStackView(arrangedSubviews: [imgLogo, lblText])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 10
        
        imgLogo.snp.makeConstraints{ make in
            make.width.height.equalTo(60)
        }
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints{ make in
            make.edges.equalToSuperview().inset(10)
        }
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    func visualize(row: ExampleRow) {
        lblText.text = row.text
        imgLogo.image = row.icon
    }
}
