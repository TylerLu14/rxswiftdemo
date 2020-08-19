//
//  ViewController.swift
//  rxswiftdemo
//
//  Created by Hoang Lu on 8/19/20.
//  Copyright © 2020 Hoang Lu. All rights reserved.
//

import UIKit
import SnapKit



class ViewController: UIViewController {
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .none
        return view
    }()
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ExampleCell.self, forCellReuseIdentifier: ExampleCell.identifier)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ExampleType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExampleCell.identifier, for: indexPath) as! ExampleCell
        cell.visualize(row: ExampleType.allCases[indexPath.row].row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        present(ExampleType.allCases[indexPath.row].row.vc, animated: true) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
}

