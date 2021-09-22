//
//  RepoListViewControllerWithCombine.swift
//  BitbucketRepoMVVM
//
//  Created by Ta, Viet | Vito | MTSD on 2021/09/19.
//

import UIKit
import Combine

class RepoListViewControllerWithCombine: UIViewController {

    private let tableView = UITableView()
    
    private let viewModel: RepoViewModelWithCombine
    private var cancellables: Set<AnyCancellable> = []
    private var datasource: UITableViewDiffableDataSource<Section, Repository>!
    
    init(viewModel: RepoViewModelWithCombine) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        configureDataSource()
        bindViewModel()
        viewModel.fetchRepo()
    }

    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.pin(to: view)
        tableView.delegate = self
        tableView.register(RepoTableViewCell.self, forCellReuseIdentifier: RepoTableViewCell.identifier)
        tableView.register(RepoTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: RepoTableViewHeaderView.identifier)
    }
    
    private func configureDataSource() {
        datasource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { (tableView, indexPath, repo) -> RepoTableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: RepoTableViewCell.identifier, for: indexPath) as? RepoTableViewCell
            cell?.configure(repo: repo)
            return cell
        })
    }
    
    private func bindViewModel() {
        viewModel.$state.sink { [weak self] (result) in
            self?.handle(state: result)
        }.store(in: &cancellables)
    }
    
    private func handle(state: RepoViewModelWithCombine.State) {
        switch state {
        case .isLoading:
            print("isLoading")
        case .failed(let error):
            print("failed with error: \(error)")
        case .loaded:
            print("loaded")
            createSnapshot()
        }
    }
    
    private func createSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Repository>()
        let sections: [Section] = [.one]
        snapshot.appendSections(sections)
        snapshot.appendItems(self.viewModel.repos)
        DispatchQueue.global().async {
            self.datasource.apply(snapshot, animatingDifferences: true, completion: nil)
        }
    }
}

extension RepoListViewControllerWithCombine: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == tableView.numberOfSections - 1 &&
            indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            viewModel.getRepoFromNextPage()
        }
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Header title section \(section)"
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return "Footer title section \(section)"
//    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: RepoTableViewHeaderView.identifier) as! RepoTableViewHeaderView
//        view.configure("Section footer \(section)")
        return view
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: RepoTableViewHeaderView.identifier) as! RepoTableViewHeaderView
//        view.configure("Section header \(section)")
        return view
    }
}
