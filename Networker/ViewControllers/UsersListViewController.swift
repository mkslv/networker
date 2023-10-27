//
//  UsersListViewController.swift
//  Networker
//
//  Created by Max Kiselyov on 10/27/23.
//

import UIKit

class UsersListViewController: UITableViewController {
    // MARK: - Properties
    
    // создаем свойство нетворк менеджер
    private let networkManager = NetworkManager.shared
    // создаем нашу модель данных которую получаем - создаем пустой
    private var users = [User]()

    let identifier = "cell"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // настраиваю табл
        tableView.rowHeight = 80
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier) // make cell reusable
        
        // подтягиваем данные из модели-сети
        fetchUsers()
    }
}


// MARK: - Networking
private extension UsersListViewController {
    func fetchUsers() {
        networkManager.fetchUsers(completion: { [weak self] result in
            switch result {
            case .success(let users):
                self?.users = users
            case .failure(let error):
                print("error in fetch users \(error.localizedDescription)")
            }
            // Обновим табл с пом. встроенного метода TVC
            self?.tableView.reloadData()
        })
    }
}

// MARK: - UITableViewDataSource
extension UsersListViewController {
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // cell adjustments
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        // finding a user
        let user = users[indexPath.row]
        
        // create a content
        var content = cell.defaultContentConfiguration()
        content.text = user.firstName
        content.secondaryText = user.lastName
        content.image = UIImage(systemName: "face.smiling")
        cell.contentConfiguration = content
        
        // fill avatar
        networkManager.fetchAvatar(from: user.avatar) { imageData in
            content.image = UIImage(data: imageData)
            // rounded image
            content.imageProperties.cornerRadius = tableView.rowHeight / 2 
            cell.contentConfiguration = content
        }

        return cell
    }
}
