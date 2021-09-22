//
//  RepoCollectionViewController.swift
//  BitbucketRepoMVVM
//
//  Created by Ta, Viet | Vito | MTSD on 2021/09/17.
//

import UIKit

class RepoCollectionViewController: UIViewController {

    private var datasource: UICollectionViewDiffableDataSource<Section, Repository>!
    
    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: 120, height: 160)
        
        // for dynamic height cell
        // flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    
    let viewModel: RepoViewModel
    
    init(viewModel: RepoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
        configureCollectionViewDataSource()
        fetchData()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .lightGray
        collectionView.pin(to: view)
        collectionView.register(RepoCollectionViewCell.self, forCellWithReuseIdentifier: RepoCollectionViewCell.identifier)
        collectionView.delegate = self
    }
    
    private func configureCollectionViewDataSource() {
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, repo) -> RepoCollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RepoCollectionViewCell.identifier, for: indexPath) as! RepoCollectionViewCell
            cell.configure(repo: repo)
            return cell
        })
    }
    
    private func fetchData() {
        viewModel.fetchRepo { [weak self] (error) in
            if let _ = error {
                return
            }
            self?.createSnapshot()
        }
    }
    
    private func createSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Repository>()
        let sections: [Section] = [.one]
        snapshot.appendSections(sections)
        snapshot.appendItems(self.viewModel.repositories)
        DispatchQueue.global().async {
            self.datasource.apply(snapshot, animatingDifferences: true, completion: nil)
        }
    }
}

extension RepoCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == collectionView.numberOfSections - 1 &&
            indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 1{
            viewModel.getRepoFromNextPage { [weak self] (error) in
                if let _ = error {
                    return
                }
                self?.createSnapshot()
            }
        }
    }
}

// old way with UICollectionViewDataSource
/*
extension RepoCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.repositories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RepoCollectionViewCell.identifier, for: indexPath) as! RepoCollectionViewCell
        cell.configure(repo: viewModel.repositories[indexPath.item])
        return cell
    }
}
 */
