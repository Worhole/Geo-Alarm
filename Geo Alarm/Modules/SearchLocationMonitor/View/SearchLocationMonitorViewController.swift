//
//  SearchLocationMonitorViewController.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-05-16.
//

import UIKit

class SearchLocationMonitorViewController: UIViewController {
    
    var presenter:SearchLocationMonitorPresenterProtocol!
    
    lazy var xmarkButton:UIButton = {
        $0.tintColor = .systemGray3
        $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        $0.addTarget(self, action: #selector(tapXmark), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    lazy var addLocationButton:UIButton = {
        $0.setTitle("Wake up here", for: .normal)
        $0.backgroundColor = #colorLiteral(red: 0.09206429869, green: 0.4222652912, blue: 0.9932720065, alpha: 1)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        $0.tintColor = .white
        $0.layer.cornerRadius = 15
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        $0.addTarget(self, action: #selector(addMonitoringLocation), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    lazy var titleLabel:UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "Point on map"
        $0.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    lazy var subtitleLabel:UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .systemGray2
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    lazy var coordLabel:UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .systemGray2
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.text = "Coordinates:"
        return $0
    }(UILabel())
    
    lazy var pointCoordinates:UILabel = {
        $0.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UILabel())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(dismissSheet), name: NSNotification.Name("dismissBottomSheet"), object: nil)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let contentHeight = titleLabel.intrinsicContentSize.height + subtitleLabel.intrinsicContentSize.height + coordLabel.intrinsicContentSize.height + addLocationButton.intrinsicContentSize.height
        preferredContentSize = CGSize(width: view.bounds.width, height: contentHeight + 70)
    }
}

extension SearchLocationMonitorViewController:SearchLocationMonitorViewProtocol{
    func present(title: String?, subtitle: String?, lat: String, lon: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        pointCoordinates.text = "\(lat),\(lon)"
        print("\(title)")
    }
}


private extension SearchLocationMonitorViewController{
    func setupLayout(){
        let barButton = UIBarButtonItem(customView: xmarkButton)
        self.navigationItem.rightBarButtonItem = barButton
        
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(coordLabel)
        view.addSubview(addLocationButton)
        view.addSubview(pointCoordinates)
        
        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor,constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 5),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            coordLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor,constant: 5),
            coordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            
            pointCoordinates.bottomAnchor.constraint(equalTo: coordLabel.bottomAnchor),
            pointCoordinates.leadingAnchor.constraint(equalTo: coordLabel.trailingAnchor,constant: 5),
            
            addLocationButton.topAnchor.constraint(equalTo: coordLabel.bottomAnchor,constant: 20),
            addLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            addLocationButton.heightAnchor.constraint(equalToConstant: 50),
            
        ])
    }
}

private extension SearchLocationMonitorViewController{
    @objc
    func tapXmark(){
        NotificationCenter.default.post(name: NSNotification.Name("removeAnnotation"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("removeOverlays"), object: nil)
        self.dismiss(animated: true)
    }
    @objc
    func dismissSheet(){
        self.dismiss(animated: true)
    }
    @objc
    func addMonitoringLocation(){
        presenter.startMonitoring()
        NotificationCenter.default.post(name: NSNotification.Name("removeLongPress"), object: nil)
        self.dismiss(animated: true)
    }
}

