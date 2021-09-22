//
//  RepoCollectionViewCell.swift
//  BitbucketRepoMVVM
//
//  Created by Ta, Viet | Vito | MTSD on 2021/09/20.
//

import UIKit

class RepoCollectionViewCell: UICollectionViewCell {
    static let identifier = "RepoCollectionViewCell"
    
    private let avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30.0
        var constraints = [NSLayoutConstraint]()
        constraints.append(imageView.widthAnchor.constraint(equalToConstant: 60.0))
        constraints.append(imageView.heightAnchor.constraint(equalToConstant: 60.0))
        NSLayoutConstraint.activate(constraints)
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8.0, leading: 16.0, bottom: 8.0, trailing: 16.0)
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.backgroundColor = .white
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(avatar)
        stackView.addArrangedSubview(nameLabel)
        stackView.pin(to: contentView)
    }
    
    func configure(repo: Repository) {
        avatar.image = nil
        avatar.load(urlString: repo.owner.links.avatar.href, contentMode: .scaleAspectFit)
        nameLabel.text = repo.owner.displayName
    }
}
