//
//  RepoViewModelWithCombine.swift
//  BitbucketRepoMVVM
//
//  Created by Ta, Viet | Vito | MTSD on 2021/09/19.
//

import Foundation
import Combine

class RepoViewModelWithCombine: ObservableObject {
    
    private let service: RepoService
    
//    @Published private (set) var repos = [Repository]()
    
    private (set) var repos = [Repository]()
    private var nextPage: String?

    enum State {
        case isLoading
        case failed(Error)
        //case loaded([Repository])
        case loaded
    }
    
    @Published private(set) var state = State.loaded
    
    init(service: RepoService) {
        self.service = service
    }
    
    func fetchRepo() {
        self.state = State.isLoading
        service.getRepo { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let repoData):
                self.nextPage = repoData.next
                self.repos = repoData.repositories
                self.state = State.loaded
            case .failure(let error):
                self.state = State.failed(error)
            }
        }
    }
    
    func getRepoFromNextPage() {
        self.state = State.isLoading
        guard let nextPage = nextPage else {
            self.state = State.failed(NetworkingError.invalidURL)
            return
        }
        service.getRepo(urlString: nextPage) { [weak self] (result) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let repoData):
                self.nextPage = repoData.next
                self.repos.append(contentsOf: repoData.repositories)
                self.state = State.loaded
            case .failure(let error):
                self.state = State.failed(error)
            }
        }
    }
}
