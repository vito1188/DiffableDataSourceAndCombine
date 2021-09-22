//
//  RepoListViewController.swift
//  BitbucketRepoMVVM
//
//  Created by Ta, Viet | Vito | MTSD on 2021/09/17.
//

import UIKit

protocol NextPage {
    func nextPageAction()
}

enum Section {
    case one
    case two
    case three
}

class RepoListViewController: UIViewController, UITableViewDelegate {

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        return tableView
    }()
    
    private var datasource: UITableViewDiffableDataSource<Section, Repository>!
    private let viewModel: RepoViewModel
    
    init(viewModel: RepoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        configureTableView()
        configureDataSource()
        fetchData()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        
        // set delegate
        tableView.delegate = self
        
        // register cells
        tableView.register(RepoTableViewCell.self, forCellReuseIdentifier: RepoTableViewCell.identifier)
        
        // setup refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadMore), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // layout constraints
        tableView.pin(to: view)
    }
    
    @objc private func loadMore() {
        fetchNextPage()
    }
    
    private func configureDataSource() {
        datasource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { (tableView, indexPath, repo) -> RepoTableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: RepoTableViewCell.identifier, for: indexPath) as! RepoTableViewCell
            cell.configure(repo: repo)
            return cell
        })
    }
    
    private func fetchData() {
        viewModel.fetchRepo { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
//                print(error)
                return
            }
            self.createSnapshot()
        }
    }
    
    private func fetchNextPage() {
        viewModel.getRepoFromNextPage { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
//                print(error)
                return
            }
            self.createSnapshot()
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func createSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Repository>()
        let sections: [Section] = [.one, .two, .three]
        snapshot.appendSections(sections)
        
        for section in sections {
            snapshot.appendItems(self.reposForSection(section), toSection: section)
        }
        DispatchQueue.global().async {
            self.datasource.apply(snapshot, animatingDifferences: true, completion: nil)
        }
    }
    
    private func reposForSection(_ section: Section) -> [Repository] {
        let n = viewModel.repositories.count
        switch section {
        case .one:
            return Array(viewModel.repositories[0..<n/3])
        case .two:
            return Array(viewModel.repositories[n/3..<2*n/3])
        case .three:
            return Array(viewModel.repositories[2*n/3..<n])
        }
    }
}

extension UIView {
    func pin(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        constraints.append(leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(trailingAnchor.constraint(equalTo: view.trailingAnchor))
        constraints.append(topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(bottomAnchor.constraint(equalTo: view.bottomAnchor))
        NSLayoutConstraint.activate(constraints)
    }
}
