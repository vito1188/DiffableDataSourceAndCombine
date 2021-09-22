//
//  RepoTableViewCell.swift
//  BitbucketRepoMVVM
//
//  Created by Ta, Viet | Vito | MTSD on 2021/09/19.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func load(urlString: String, contentMode: UIView.ContentMode) {
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
//            print("vietlog use cache")
            self.image = cachedImage
            self.contentMode = contentMode
            return
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.init(configuration: .default).dataTask(with: URLRequest(url: url)) { (data, response, error) in
//            print("vietlog loaded image")
            if let error = error {
                imageCache.setObject(UIImage(), forKey: urlString as NSString)
//                print(error)
                return
            }
            guard let data = data else {
//                print("vietlog no data")
                return
            }
            
            if let image = UIImage(data: data) {
                imageCache.setObject(image, forKey: urlString as NSString)
                DispatchQueue.main.async {
                    self.image = image
                }
            } else {
                imageCache.setObject(UIImage(), forKey: urlString as NSString)
            }
        }.resume()
    }
}

class RepoTableViewCell: UITableViewCell {

    static let identifier = "RepoTableViewCell"
    
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
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = UIColor.black
        return label
    }()
    
    let typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .right
        label.textColor = UIColor.red
        return label
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8.0, leading: 16.0, bottom: 8.0, trailing: 16.0)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isHidden = false
        isSelected = false
        isHighlighted = false
    }
    
    private func setupView() {
        contentView.addSubview(containerStackView)
        containerStackView.pin(to: contentView)
        containerStackView.addArrangedSubview(avatar)
        containerStackView.addArrangedSubview(nameLabel)
        containerStackView.addArrangedSubview(typeLabel)
    }
    
    func configure(repo: Repository) {
        avatar.image = nil
        avatar.load(urlString: repo.owner.links.avatar.href, contentMode: .scaleAspectFit)
        nameLabel.text = repo.owner.displayName
        typeLabel.text = repo.type
    }
}
