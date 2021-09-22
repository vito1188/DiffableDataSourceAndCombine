//
//  RepoTableViewHeaderView.swift
//  BitbucketRepoMVVM
//
//  Created by Ta, Viet | Vito | MTSD on 2021/09/20.
//

import UIKit

class RepoTableViewHeaderView: UITableViewHeaderFooterView {

    static let identifier = String(describing: self)
    
//    private let displayTitle: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .left
//        return label
//    }()
    
    private let circleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .green
        view.layer.cornerRadius = 25.0
        view.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        view.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        return view
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
//        contentView.addSubview(displayTitle)
//        displayTitle.pin(to: contentView)
        contentView.addSubview(circleView)
        var constraints = [NSLayoutConstraint]()
        constraints.append(circleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16))
        constraints.append(circleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16))
        constraints.append(circleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16))
        NSLayoutConstraint.activate(constraints)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func configure(_ text: String) {
//        displayTitle.text = text
//    }
}
