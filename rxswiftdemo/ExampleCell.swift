//
//  ExampleCell.swift
//  rxswiftdemo
//
//  Created by Hoang Lu on 8/19/20.
//  Copyright © 2020 Hoang Lu. All rights reserved.
//

import Foundation
import UIKit

protocol ExampleRow {
    var text: String { get }
    var vc: UIViewController { get }
}

enum ExampleType: CaseIterable {
    case createObservables
    case transformOperators
    
    var row: ExampleRow {
        switch self {
        case .createObservables: return CreateObservables()
        case .transformOperators: return TransformOperators()
        }
    }
    
    struct CreateObservables: ExampleRow {
        var text = "Create Observables"
        var vc: UIViewController = CreateObservableViewController()
    }
    
    struct TransformOperators: ExampleRow {
        var text = "Transform Operators"
        var vc: UIViewController = TransformOperatorsViewController()
    }
}

class ExampleCell: UITableViewCell {
    static let identifier: String = "ExampleCell"
    
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
    
    func visualize(row: ExampleRow) {
        lblText.text = row.text
    }
}
