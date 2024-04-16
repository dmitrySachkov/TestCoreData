//
//  ViewController.swift
//  TestCoreData
//
//  Created by Dmitry Sachkov on 16.04.2024.
//

import UIKit
import SnapKit
import Combine

class ViewController: UIViewController {
    
    private var coreDataManager = CoreDataManager()
    private var cancelable = Set<AnyCancellable>()
    private var newUser: PersonFromDataBase?
    
    @Published var users = [PersonFromDataBase]()
    
    private lazy var tableView: UITableView = {
       let tableView = UITableView()
        return tableView
    }()
    
    private(set) lazy var addUserButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        binding()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(addUserButton)
        
        addUserButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.top.equalTo(view.snp.topMargin).offset(16)
            make.width.height.equalTo(48)
        }
        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(addUserButton.snp.bottom)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserCell.self, forCellReuseIdentifier: "cell")
        
        users = coreDataManager.fetchUserData()
    }
    
    private func binding() {
        $users
            .sink { [weak self] users in
                guard let self = self  else { return }
                self.tableView.reloadData()
            }
            .store(in: &cancelable)
    }
    
    @objc
    private func handleTap(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add new user", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter shared session link"
        }
        let action = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            guard let self = self, let name = alert.textFields?.first?.text else { return }
            let newUser = PersonFromDataBase(name: name)
            self.coreDataManager.saveUserData(newUser)
            self.users = self.coreDataManager.fetchUserData()
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.configureCell(by: user.name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let name = users[indexPath.row]
        let viewController = UserDataViewController(by: name)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
