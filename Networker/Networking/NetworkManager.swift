//
//  NetworkManager.swift
//  Networker
//
//  Created by Max Kiselyov on 10/27/23.
//

import Foundation

enum NetworkError: Error {
    case invalidURL, decodingError, noData
}

final class NetworkManager {
    
    static let shared = NetworkManager() // Singletone
    
    private init() {} // forbidden to create NetworkManager from outside
    
    func fetchAvatar(from url: URL, completion: @escaping (Data) -> Void) {
        // переходим из главного потока
        DispatchQueue.global().async {
            // мы используем try? потому что ошибки не обрабатываем
            guard let imageData = try? Data(contentsOf: url) else { return }
            // возвращаемся в глваный поток
            DispatchQueue.main.async {
                // возвращаем нашу переменную в замыкание
                completion(imageData)
            }
        }
    }
    
    func fetchUsers(completion: @escaping (Result<[User], NetworkError>) -> Void) {
        // network request
        URLSession.shared.dataTask(with: Link.allUsers.url) { data, response, error in
            // casting
            if let response = response as? HTTPURLResponse {
                print("response status code: \(response.statusCode)")
            }
            
            guard let data else {
                print(error?.localizedDescription ?? "no error description")
                completion(.failure(.noData))
                return
            }
            
            let decoder = JSONDecoder()
            // Mapping DATA - Response
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let usersQuery = try decoder.decode(UsersQuery.self, from: data) // подписали UsersQuery: Decodable
                DispatchQueue.main.async { // так как все в бекграунде работает 
                    completion(.success(usersQuery.data))
                }
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume() // запускаем URLSession
    }
}

// MARK: - Links
extension NetworkManager {
    enum Link {
        case allUsers
        
        var url: URL {
            switch self {
            case .allUsers:
                return URL(string: "https://reqres.in/api/users")! // делаем форс анврап потому что уверены в каждой букве юрл
            }
        }
    }
    
}
