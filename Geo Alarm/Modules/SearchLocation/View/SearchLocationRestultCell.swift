//
//  UISearchLocationRestultCell.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-05-15.
//

import UIKit

class XmarkButton:UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.insetBy(dx: -15, dy: -15)
        return expandedBounds.contains(point)
    }
}

class SearchLocationRestultCell: UITableViewCell {
    
    static let reuseId = "SideMenuCell"
    
    lazy var xmarkButton:XmarkButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .gray
        $0.addTarget(self, action: #selector(xmarkAction), for: .touchUpInside)
        return $0
    }(XmarkButton(type: .system))
    
    lazy var searchImageView:UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = .gray
        $0.image = UIImage(systemName: "magnifyingglass")
        return $0
    }(UIImageView())
    
    lazy var titleLabel:UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .boldSystemFont(ofSize: 15)
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    var xmarkTapped:(()->())?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SearchLocationRestultCell{
    func setupLayout(){
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(xmarkButton)
        contentView.addSubview(searchImageView)
        
        NSLayoutConstraint.activate([
            
            searchImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 20),
            searchImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            searchImageView.widthAnchor.constraint(equalToConstant: 20),
            searchImageView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.leadingAnchor.constraint(equalTo: searchImageView.trailingAnchor,constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: xmarkButton.trailingAnchor, constant: -20),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
    
            xmarkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            xmarkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            xmarkButton.widthAnchor.constraint(equalToConstant: 12),
            xmarkButton.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    @objc
    func xmarkAction(){
        xmarkTapped?()
    }
}

extension SearchLocationRestultCell{
    func configue(title:String){
        titleLabel.text = title
    }
    func isXmarkButtonHidden(_ isHidden:Bool){
        xmarkButton.isHidden = isHidden
    }
}
