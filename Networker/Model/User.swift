//
//  User.swift
//  Networker
//
//  Created by Max Kiselyov on 10/27/23.
//

import Foundation

struct User: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let avatar: URL
    
    static let example = User(
        id: 2,
        firstName: "Timothy",
        lastName: "Cook",
        avatar: URL(string: "https://reqres.in/img/faces/1-image.jpg")! // тк юрл из строки дает опциональное значение. Применяем форс анврапинг
    )
}

struct UsersQuery: Decodable { // because Network Manager
    let data: [User]
}
