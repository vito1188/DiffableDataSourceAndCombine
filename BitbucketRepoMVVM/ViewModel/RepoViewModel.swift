//
//  RepoViewModel.swift
//  BitbucketRepoMVVM
//
//  Created by Ta, Viet | Vito | MTSD on 2021/09/17.
//

import Foundation

enum NetworkingError: Error {
    case invalidURL
    case invalidResponse
    case unknown
}

protocol Networking {
    func fetchData<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void)
}

class Client: Networking {
    func fetchData<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        let session = URLSession.init(configuration: .default)
        let request = URLRequest(url: url)
        session.dataTask(with: request) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkingError.invalidResponse))
                return
            }
            let decoder = JSONDecoder()
            let result = Result(catching: {
                try decoder.decode(T.self, from: data)
            })
            completion(result)
        }.resume()
    }
}

class RepoService {

    let network: Networking
    
    init(network: Networking) {
        self.network = network
    }
    
    // https://api.bitbucket.org/2.0/repositories
    func getRepo(completion: @escaping (Result<RepoData, Error>) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.bitbucket.org"
        urlComponents.path = "/2.0/repositories"
        let url = urlComponents.url
        print(url?.absoluteString)
        getRepo(urlString: url?.absoluteString ?? "", completion: completion)
    }
    
    // next page
    func getRepo(urlString: String, completion: @escaping (Result<RepoData, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkingError.invalidURL))
            return
        }
        network.fetchData(url: url, completion: completion)
    }
}

// fetch repo
// store cache load repo if needed
class RepoViewModel {
    private let service: RepoService
    private (set) var repositories = [Repository]()
    private (set) var nextPage: String?
    
    init(service: RepoService) {
        self.service = service
    }
    
    func fetchRepo(completion: @escaping (Error?) -> Void) {
        service.getRepo { [weak self] (result) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let repoData):
                self.repositories = repoData.repositories
                self.nextPage = repoData.next
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func getRepoFromNextPage(completion: @escaping (Error?) -> Void) {
        guard let nextPage = nextPage else { return }
        service.getRepo(urlString: nextPage) { [weak self] (result) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let repoData):
                self.repositories.append(contentsOf: repoData.repositories)
                self.nextPage = repoData.next
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}
