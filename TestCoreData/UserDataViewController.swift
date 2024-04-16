//
//  UserDataViewController.swift
//  TestCoreData
//
//  Created by Dmitry Sachkov on 16.04.2024.
//

import UIKit
import Combine

class UserDataViewController: UIViewController {
    
    private let user: PersonFromDataBase
    private var coreDataManager = CoreDataManager()
    private var cancelable = Set<AnyCancellable>()
    
    @Published var runningData = [RunningEvent]()
    
    private lazy var tableView: UITableView = {
       let tableView = UITableView()
        return tableView
    }()
    
    private(set) lazy var addButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return button
    }()

    init(by person: PersonFromDataBase) {
        self.user = person
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTableView()
        self.navigationItem.title = user.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        binding()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.top.equalTo(view.snp.topMargin).offset(16)
            make.width.height.equalTo(48)
        }
        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(addButton.snp.bottom)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserCell.self, forCellReuseIdentifier: "cell")
        
        runningData = coreDataManager.fetchRunningData(forUser: user)
    }
    
    private func binding() {
        $runningData
            .sink { [weak self] runningData in
                guard let self = self  else { return }
                self.tableView.reloadData()
            }
            .store(in: &cancelable)
    }
    
    @objc
    private func handleTap(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add new", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter name"
        }
        let action = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            guard let self = self, let name = alert.textFields?.first?.text else { return }
            let newData = RunningEvent(name: name, date: Date())
            self.coreDataManager.saveRunningData(newData, forUser: user)
            self.runningData = self.coreDataManager.fetchRunningData(forUser: user)
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}

extension UserDataViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runningData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserCell
        let user = runningData[indexPath.row]
        cell.configureCell(by: user.name)
        return cell
    }
}
