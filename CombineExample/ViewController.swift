//
//  ViewController.swift
//  CombineExample
//
//  Created by Sergei on 04.11.2023.
//

import Combine
import UIKit

class CustomTableViewCell: UITableViewCell {
    static let identifier = "CustomTableViewCell"
    
    let action = PassthroughSubject<String, Never>()
    
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemMint
        button.addTarget(self, action: #selector(didTabButton(_:)), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(button)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        button.frame = CGRect(
            x: 10,
            y: 3,
            width: contentView.frame.width - 20,
            height: contentView.frame.height - 6
        )
    }
    
    @objc
    private func didTabButton(_ sender: UIButton) {
        action.send("Cool button was tapped!: \(sender.currentTitle ?? "")")
    }
    
    public func configure(_ buttonTitle: String) {
        button.setTitle(buttonTitle, for: .normal)
    }
}

class ViewController: UIViewController {
    var observers: [AnyCancellable] = []
    
    var models: [String] = []
    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(CustomTableViewCell.self,
                      forCellReuseIdentifier: CustomTableViewCell.identifier)
        
        return view
    }()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = view.bounds
        
        APICaller.shared.fetchCompanies()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        print("finished")
                    case .failure(let error):
                        print(error.localizedDescription)
                }
        }, receiveValue: { [weak self] value in
            self?.models = value
            self?.tableView.reloadData()
        })
            .store(in: &observers)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as? CustomTableViewCell else {
            fatalError()
        }
        cell.configure(models[indexPath.row])
        cell.action.sink { string in
            print(string)
        }
        .store(in: &observers)
        
        return cell
    }
    
    
}
